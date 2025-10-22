`include "ZPortableDefine.v"

//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZOV5640_Cfg(
    input wire iClk,
    input wire iRstN,
    input wire iEn,
    output reg oCfgDone,

    //DVP SCCB Interface.
    output wire oDVP_SCL,
    inout wire ioDVP_SDA,

    output wire oDVP_RST,
    output wire oDVP_PWDN,

    //Debug UART.
    output reg oTxEn,
    output reg [7:0] oTxData,
    input wire iTxDone
);

`include "ZOV5640_RegAddr.v"

///////////////////////////////////////////////////////
//OV5640 registers tables.
localparam REG_ADDR_CHIPID_HIGH=16'h300A;
localparam REG_ADDR_CHIPID_LOW=16'h300B;

//How many registers need to be configured. 
parameter CFG_REG_MAX_NUM=312;
reg [15:0] Cfg_Index_i;
wire [15:0] Cfg_Reg_Addr_i;
wire [7:0] Cfg_Reg_Data_i;
ZOV5640_RegSet myOV5640_RegSet(
    .iClk(iClk),
    .iEn(iEn),
    .iRstN(iRstN),

    .iIndex(Cfg_Index_i),
    .oRegAddr(Cfg_Reg_Addr_i),
    .oRegData(Cfg_Reg_Data_i)
);

reg enSCCB_i;
reg [2:0] OpReq_i;
reg [15:0] OpRegAddr_i;
reg [7:0] OpWrData_i;
wire [7:0] OpRdData_i;
wire OpDone_i;
ZOV5640_SCCB myOV5640_SCCB(
    .iClk(iClk),
    .iEn(enSCCB_i),
    .iRstN(iRstN),

    //Operation Request.
    //[2:0]=3'b000, Hardware Reset.
    //[2:0]=3'b001, Read Registers.
    //[2:0]=3'b010, Write Registers.
    //[2:0]=3'b011, Read Memory.
    //[2:0]=3'b100, Write Memory.
    .iOpReq(OpReq_i),
    .iRegAddr(OpRegAddr_i), //Which register do you want to read? 
    .iWrData(OpWrData_i), //data that writes to register. 
    .oRdData(OpRdData_i), //Data read back from register.
    .oOpDone(OpDone_i),

    //SCCB Interface.
    .oDVP_SCL(oDVP_SCL),
    .ioDVP_SDA(ioDVP_SDA),

    .oDVP_RST(oDVP_RST),
    .oDVP_PWDN(oDVP_PWDN)
);

//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt_i; 
reg [15:0] tempDR_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt_i<=0; Cfg_Index_i<=0; oCfgDone<=0;
    oTxEn<=0; oTxData<=0; tempDR_i<=0;
end
else begin
    if(iEn) begin
        case(step_i)
        `STEP_00: //100uS after POR.
            if(cnt_i==32768-1) begin cnt_i<=0; step_i<=step_i+1; end
            else begin cnt_i<=cnt_i+1; end
        `STEP_01: //[2:0]=3'b000, Hardware Reset.
            if(OpDone_i) begin enSCCB_i<=0; step_i<=step_i+1; end
            else begin OpReq_i<=3'b000; enSCCB_i<=1; end
        `STEP_02: //[2:0]=3'b010, Read Registers.
                if(OpDone_i) begin enSCCB_i<=0; tempDR_i[15:8]<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; OpRegAddr_i<=REG_ADDR_CHIPID_HIGH; enSCCB_i<=1; end
        `STEP_03:
                if(OpDone_i) begin enSCCB_i<=0; tempDR_i[7:0]<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; OpRegAddr_i<=REG_ADDR_CHIPID_LOW; enSCCB_i<=1; end 
        `STEP_04: //UART TX. Default Value is 0x5640.
                if(cnt_i==2) begin cnt_i<=0; step_i<=step_i+1; end
                else begin 
                        if(iTxDone) begin oTxEn<=0; tempDR_i<=tempDR_i<<8; cnt_i<=cnt_i+1; end
                        else begin oTxEn<=1; oTxData<=tempDR_i[15:8]; end
                end
        `STEP_05: //prepare configure register address & data.
                begin Cfg_Index_i<=0; step_i<=step_i+1; end
        `STEP_06: //[2:0]=3'b010, Write Registers.
                if(OpDone_i) begin enSCCB_i<=0; step_i<=step_i+1; end
                else begin OpReq_i<=3'b010; OpRegAddr_i<=Cfg_Reg_Addr_i; OpWrData_i<=Cfg_Reg_Data_i; enSCCB_i<=1; end 
        `STEP_07: //Loop to write all registers.
                if(Cfg_Index_i==CFG_REG_MAX_NUM) begin Cfg_Index_i<=0; step_i<=step_i+1; end
                else begin Cfg_Index_i<=Cfg_Index_i+1; step_i<=step_i-1; end
        `STEP_08: //Read back register OV5640_POLARITY_CTRL
                if(OpDone_i) begin enSCCB_i<=0; tempDR_i[15:8]<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; OpRegAddr_i<=OV5640_POLARITY_CTRL; enSCCB_i<=1; end
        `STEP_09: //Read back register OV5640_FORMAT_CTRL00
                if(OpDone_i) begin enSCCB_i<=0; tempDR_i[7:0]<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; OpRegAddr_i<=OV5640_FORMAT_CTRL00; enSCCB_i<=1; end 
        `STEP_10:
                if(cnt_i==2) begin cnt_i<=0; step_i<=step_i+1; end
                else begin 
                        if(iTxDone) begin oTxEn<=0; tempDR_i<=tempDR_i<<8; cnt_i<=cnt_i+1; end
                        else begin oTxEn<=1; oTxData<=tempDR_i[15:8]; end
                end
        `STEP_11: //Read back register OV5640_CLOCK_ENABLE02
                if(OpDone_i) begin enSCCB_i<=0; tempDR_i[15:8]<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; OpRegAddr_i<=OV5640_CLOCK_ENABLE02; enSCCB_i<=1; end
        `STEP_12: //Read back register OV5640_SYSREM_RESET02
                if(OpDone_i) begin enSCCB_i<=0; tempDR_i[15:8]<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; OpRegAddr_i<=OV5640_SYSREM_RESET02; enSCCB_i<=1; end
        `STEP_13:
                if(cnt_i==2) begin cnt_i<=0; step_i<=step_i+1; end
                else begin 
                        if(iTxDone) begin oTxEn<=0; tempDR_i<=tempDR_i<<8; cnt_i<=cnt_i+1; end
                        else begin oTxEn<=1; oTxData<=tempDR_i[15:8]; end
                end     
        `STEP_14:
                begin oCfgDone<=1; step_i<=step_i+1; end
        `STEP_15:
                begin oCfgDone<=0; step_i<=`STEP_00;  end
        default:
                begin step_i<=`STEP_00; end
        endcase
    end
end
endmodule
