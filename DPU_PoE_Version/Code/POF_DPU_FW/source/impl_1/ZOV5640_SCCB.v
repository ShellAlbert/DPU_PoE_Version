`include "ZPortableDefine.v"
//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZOV5640_SCCB(
    input wire iClk,
    input wire iRstN,
    input wire iEn,

    //Operation Request.
    //[2:0]=3'b000, Hardware Reset.
    //[2:0]=3'b001, Read Registers.
    //[2:0]=3'b010, Write Registers.
    //[2:0]=3'b011, Read Memory.
    //[2:0]=3'b100, Write Memory.
    input wire [2:0] iOpReq,
    input wire [15:0] iRegAddr, //Which register do you want to read? 
    input wire [7:0] iWrData, //data that writes to register.
    output reg [7:0] oRdData, //Data read back from register.
    output reg oOpDone,

    //SCCB Interface.
    output reg oDVP_SCL,
    inout wire ioDVP_SDA,

    output reg oDVP_RST,
    output reg oDVP_PWDN
);
//Ov5640 I2C Slave Address.
//Phase-1: [7:1], salve address. [0]: 0:write, 1:read.
localparam I2C_ADDR_READ=8'h79;
localparam I2C_ADDR_WRITE=8'h78;


//Tri-State for SCCB_SDA.
reg output_En_SDA_i;
wire SDA_In_i;
reg SDA_Out_i;
assign SDA_In_i=ioDVP_SDA;
assign ioDVP_SDA=(output_En_SDA_i)?(SDA_Out_i):(1'bz);
/////////////////////////////////////////////////////////////////
//Slow down 50MHz to 400KHz.
//50Mhz/400KHz=125.
//100MHz/400KHz=250.
reg [15:0] cnt_SCL;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    cnt_SCL<=0; 
end
else begin 
    if(iEn) begin
        if(cnt_SCL==16'd500-1) begin cnt_SCL<=0; end         
        else begin cnt_SCL<=cnt_SCL+1; end
    end
    else begin 
        cnt_SCL<=0;
    end
end
wire clk_SCL;
assign clk_SCL=(cnt_SCL==16'd500-1)?(1):(0);
///////////////////////////////////////////////////////////////////

//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt1_i; 
reg [7:0] temp_DR; //temporary data register.
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt1_i<=0; 
    //PWDN: power down (active high with internal pull-down resistor)
    oDVP_PWDN<=0; 
    //RESETB: reset (active low with internal pull-up resistor)
    oDVP_RST<=1;
    //Default is output.
    output_En_SDA_i<=1; SDA_Out_i<=1; 
end
else begin
    if(iEn) begin
        case(iOpReq)
            3'b000: //[2:0]=3'b000, Hardware Reset.
                case(step_i)
                `STEP_00: //Pull down RESETB.
                    if(cnt1_i==32768-1) begin cnt1_i<=0; step_i<=step_i+1; end
                    else begin oDVP_RST<=0; cnt1_i<=cnt1_i+1; end
                `STEP_01: //Pull up RESETB.
                    if(cnt1_i==32768-1) begin cnt1_i<=0; step_i<=step_i+1;end
                    else begin oDVP_RST<=1; cnt1_i<=cnt1_i+1; end
                `STEP_02: //Must delay for a while before operating.
                    //CAUTION!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    //No adequate time will cause ChipID read failed.
                    if(cnt1_i==32768-1) begin cnt1_i<=0; step_i<=step_i+1;end
                    else begin cnt1_i<=cnt1_i+1; end
                `STEP_03:
                    begin oOpDone<=1; step_i<=step_i+1; end
                `STEP_04:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b001: //[2:0]=3'b001, Read Registers.
                case(step_i)
                `STEP_00: //Start.
                    if(clk_SCL) begin oDVP_SCL<=1; output_En_SDA_i<=1; SDA_Out_i<=1; step_i<=step_i+1; end
                `STEP_01: //Start.
                    if(clk_SCL) begin SDA_Out_i<=0; step_i<=step_i+1; end
                `STEP_02://2-Phase Write Transmission Cycle.(ID Address)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=I2C_ADDR_WRITE; step_i<=step_i+1; end
                `STEP_03:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_04: 
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_05: 
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_06: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_07: //2-Phase Write Transmission Cycle.(Sub Address - High 8bits.)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=iRegAddr[15:8]; step_i<=step_i+1; end
                `STEP_08:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_09:
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_10:
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_11: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_12: //2-Phase Write Transmission Cycle.(Sub Address - Low 8bits.)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=iRegAddr[7:0]; step_i<=step_i+1; end
                `STEP_13:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_14:
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_15:
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_16: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_17:
                    if(clk_SCL) begin oDVP_SCL<=0; output_En_SDA_i<=1; SDA_Out_i<=0; step_i<=step_i+1; end
                `STEP_18: //Stop.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end 
                `STEP_19: //Stop.
                    if(clk_SCL) begin SDA_Out_i<=1; step_i<=step_i+1; end 
                /////////////////////////////////////////////////////////////////////////////////////////
                `STEP_20: //Start.
                    if(clk_SCL) begin oDVP_SCL<=1; output_En_SDA_i<=1; SDA_Out_i<=1; step_i<=step_i+1; end
                `STEP_21: //Start.
                    if(clk_SCL) begin SDA_Out_i<=0; step_i<=step_i+1; end
                `STEP_22://2-Phase Read Transmission Cycle.(ID Address)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=I2C_ADDR_READ; step_i<=step_i+1; end
                `STEP_23:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_24: 
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_25: 
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_26: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_27: //2-Phase Read Transmission Cycle.(Read Data)
                    if(clk_SCL) begin oDVP_SCL<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                `STEP_28:
                    if(clk_SCL) begin oDVP_SCL<=1; temp_DR<={temp_DR[6:0],SDA_In_i}; step_i<=step_i+1; end
                `STEP_29:
                    if(clk_SCL) begin
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=1; SDA_Out_i<=1; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; step_i<=step_i-2; end
                    end
                `STEP_30: //the 9th bit, master must drive this NA bit at logic 1.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_31: 
                    if(clk_SCL) begin oDVP_SCL<=0; output_En_SDA_i<=1; SDA_Out_i<=0; step_i<=step_i+1; end
                `STEP_32: //Stop.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end 
                `STEP_33: //Stop.
                    if(clk_SCL) begin SDA_Out_i<=1; step_i<=step_i+1; end 
                `STEP_34:
                    begin oOpDone<=1; oRdData<=temp_DR; step_i<=step_i+1; end
                `STEP_35:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b010: //[2:0]=3'b010, Write Registers.
                case(step_i)
                `STEP_00: //Start.
                    if(clk_SCL) begin oDVP_SCL<=1; output_En_SDA_i<=1; SDA_Out_i<=1; step_i<=step_i+1; end
                `STEP_01: //Start.
                    if(clk_SCL) begin SDA_Out_i<=0; step_i<=step_i+1; end
                `STEP_02://2-Phase Write Transmission Cycle.(ID Address)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=I2C_ADDR_WRITE; step_i<=step_i+1; end
                `STEP_03:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_04: 
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_05: 
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_06: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                ////////////////////////////////////////////////////////////////////////////////////////
                `STEP_07: //2-Phase Write Transmission Cycle.(Sub Address - High 8bits.)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=iRegAddr[15:8]; step_i<=step_i+1; end
                `STEP_08:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_09:
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_10:
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_11: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                /////////////////////////////////////////////////////////////////////////////////////////
                `STEP_12: //2-Phase Write Transmission Cycle.(Sub Address - Low 8bits.)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=iRegAddr[7:0]; step_i<=step_i+1; end
                `STEP_13:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_14:
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_15:
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_16: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                ////////////////////////////////////////////////////////////////////////////////////////
                `STEP_17: //3-Phase Write Transmission Cycle.(Write Data.)
                    if(clk_SCL) begin oDVP_SCL<=0; temp_DR<=iWrData; step_i<=step_i+1; end
                `STEP_18:
                    if(clk_SCL) begin output_En_SDA_i<=1; SDA_Out_i<=temp_DR[7]; step_i<=step_i+1; end
                `STEP_19:
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_20:
                    if(clk_SCL) begin 
                        oDVP_SCL<=0; 
                        if(cnt1_i==7) begin cnt1_i<=0; output_En_SDA_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1; temp_DR<=temp_DR<<1; step_i<=step_i-2; end
                    end
                `STEP_21: //the 9th bit, don't care.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end
                `STEP_22: 
                    if(clk_SCL) begin oDVP_SCL<=0; output_En_SDA_i<=1; SDA_Out_i<=0; step_i<=step_i+1; end
                `STEP_23: //Stop.
                    if(clk_SCL) begin oDVP_SCL<=1; step_i<=step_i+1; end 
                `STEP_24: //Stop.
                    if(clk_SCL) begin SDA_Out_i<=1; step_i<=step_i+1; end 
                `STEP_25:
                    begin oOpDone<=1; step_i<=step_i+1; end
                `STEP_26:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b011: //[2:0]=3'b011, Read Memory.
                begin step_i<=`STEP_00; end
            3'b100: //[2:0]=3'b100, Write Memory.
                begin step_i<=`STEP_00; end
            default: 
                begin step_i<=`STEP_00; end
        endcase
    end
end

// reg [1:0] RWDS0_Sync;
// always @(negedge iClk or negedge iRstN)
// if(!iRstN) begin
//     RWDS0_Sync<=2'b00;
// end
// else begin
//         if (!output_En_RWDS0 & !output_En_RWDS1 & iRWDS0 & iRWDS1) begin 
//             RWDS0_Sync[0]<=iRWDS0;
//             RWDS0_Sync[1]<=RWDS0_Sync[0];
//         end
// end



//use falling edge of iClk to capture RWDS and Data.
// reg [31:0] DDR_Data_In;
// reg [7:0] step_i_rwds;
// always @(negedge iClk or negedge iRstN)
// if(!iRstN) begin 
//     step_i_rwds<=0;
// end
// else begin
//     if(iEn) begin 
//         case(step_i_rwds)
//             `STEP_00:
//                 if (output_En_RWDS0 & output_En_RWDS1 & iRWDS0 & iRWDS1) begin 
//                     step_i_rwds<=step_i_rwds+1;
//                 end
//             `STEP_01:
//                 begin DDR_Data_In<={DQ_In_Falling, DQ_In_Rising}; end
//         endcase
        
            
//         end
//     end
// end
endmodule
