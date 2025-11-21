`include "ZPortableDefine.v"

module ZW5500_Module(
    input wire iClk,
    input wire iRstN,
    input wire iEn,

    //W5500 Physical Pins.
    output wire oW5500_CSN, //SPI_CS.
    output wire oW5500_SCLK, //SPI_SCLK.
    output wire oW5500_MOSI, //SPI_MISO.
    input wire iW5500_MISO, //SPI_MISO.
    output reg oW5500_RSTN, //Reset.
    input wire iW5500_INTN, //Interrupt Signal.

    //UART_Tx Interface used to output debug information.
    output reg oUART_Tx_En,
    output reg [7:0] oUART_Tx_Data,
    input wire iUART_Tx_Done
);

//include here to avoid error "root scope declaration is not allowed in Verilog 95/2K mode."
`include "ZW5500_Address.v"
parameter SUCCESS_FLAG = 8'h66;
parameter FAIL_FLAG = 8'h11;


//W5500 Physical SPI Layer Instance.
reg En_SPI;
reg [1:0] OpReq_SPI;
reg [15:0] AddrPhase_SPI;
reg [7:0] CtrlPhase_SPI;
reg [7:0] InDataPhase_SPI;
wire [7:0] OutDataPhase_SPI;
wire OpDone_SPI;

//In Variable Length Data Mode.
reg [7:0] VDMBytes_SPI;
wire doneVDM_SPI;
ZW5500_SPI myW5500_SPI(
    .iClk(iClk),
    .iRstN(iRstN),
    .iEn(En_SPI),

    //[1:0]=2'b00, Read/Write Register.
    //[1:0]=2'b01, Variable Length Read/Write.
    .iOpReq(OpReq_SPI),
    .iAddrPhase(AddrPhase_SPI),
    .iCtrlPhase(CtrlPhase_SPI),
    .iDataPhase(InDataPhase_SPI),
    .oDataPhase(OutDataPhase_SPI),
    .oOpDone(OpDone_SPI),

    //In Variable Length Data Mode.
    //iVDMByte[7:0] indicates how many bytes could be written. 
    //update iDataPhase[7:0] once oVDMDone is valid.
    .iVDMByte(VDMBytes_SPI),
    .oVDMDone(doneVDM_SPI),

    //W5500 Physical Pins.
    .oW5500_CSN(oW5500_CSN),
    .oW5500_SCLK(oW5500_SCLK),
    .oW5500_MOSI(oW5500_MOSI),
    .iW5500_MISO(iW5500_MISO)
);

//driven by step_i.
reg [7:0] step_i;
reg [31:0] cnt_1;
reg [7:0] tmpDR;
reg [7:0] txBuffer;
//reg [47:0] PHY_MAC={8'h00,8'h08,8'hDC,8'h12,8'h22,8'h12};
reg [47:0] rxBuffer;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt_1<=0; 
    oW5500_RSTN<=1; En_SPI<=0; VDMBytes_SPI<=0; oUART_Tx_En<=0; 
    txBuffer<=0;
end
else begin
    if(iEn) begin
        case(step_i)
        `STEP_00: //Reset W5500.
            if(cnt_1=='hFFFF-1) begin cnt_1<=0; oW5500_RSTN<=1; step_i<=step_i+1; end
            else begin cnt_1<=cnt_1+1; oW5500_RSTN<=0; end
        `STEP_01: //Delay 10mS at least before operating W5500.
            if(cnt_1=='hFFFF-1) begin cnt_1<=0; step_i<=step_i+1; end
            else begin cnt_1<=cnt_1+1; end
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_02: //Version Check.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; 
                AddrPhase_SPI<=ADDR_VERR; //VERSIONR, Chip Version Register.
                //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                //[2]:R/W,0:Read,1:Write. 
                //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                CtrlPhase_SPI<={5'd0,1'b0,2'b01}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_03: //Tx VERSIONR, if not expected, retry until getting correct version number.
            if(iUART_Tx_Done) begin oUART_Tx_En<=0; step_i<=(tmpDR==VERSION_W5500)?(step_i+1):(step_i-1); end
            else begin oUART_Tx_En<=1; oUART_Tx_Data<=tmpDR; end
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_04: //PHY Link Check.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; 
                AddrPhase_SPI<=ADDR_PHYCFGR; //PHYCFGR, PHY Configuration Register.
                //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                //[2]:R/W,0:Read,1:Write. 
                //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                CtrlPhase_SPI<={5'd0,1'b0,2'b01}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_05: //Tx PHYCFG, if link is down, retry until it's link up. PHYCFG[0]:Link Status,1:Link Up,0:Link Down.
            if(iUART_Tx_Done) begin 
                oUART_Tx_En<=0; txBuffer<=8'h00; //first byte of MAC address.
                step_i<=(tmpDR[0])?(step_i+2):(step_i+1); 
            end
            else begin oUART_Tx_En<=1; oUART_Tx_Data<=tmpDR; end
        `STEP_06: //Recheck after 1s.
            if(cnt_1==32'h5F5E100-1) begin cnt_1<=0; step_i<=step_i-2; end
            else begin cnt_1<=cnt_1+1; end
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_07: //Set MAC Address. 00-08-55-12-22-87
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_SHA0; //Source Hardware Address. (MAC)
                //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                //[2]:R/W,0:Read,1:Write. 
                //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                CtrlPhase_SPI<={5'd0,1'b1,2'b00}; 
                InDataPhase_SPI<=txBuffer; //first byte of MAC.
                VDMBytes_SPI<=6; //MAC has 6 bytes.
                if(doneVDM_SPI) begin 
                    cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0: begin txBuffer<=8'h08; end
                    1: begin txBuffer<=8'h55; end
                    2: begin txBuffer<=8'h12; end
                    3: begin txBuffer<=8'h22; end
                    4: begin txBuffer<=8'h87; end
                    default: begin txBuffer<=8'h00; end
                    endcase
                end
            end
        `STEP_08:
            if(cnt_1==20) begin cnt_1<=0; step_i<=step_i+1; end
            else begin cnt_1<=cnt_1+1; end
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_09: //Read MAC address.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_SHA0; //Source Hardware Address. (MAC)
                //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                //[2]:R/W,0:Read,1:Write. 
                //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                CtrlPhase_SPI<={5'd0,1'b0,2'b00}; 
                InDataPhase_SPI<=0; //Random data.
                VDMBytes_SPI<=6; //MAC has 6 bytes.
                if(doneVDM_SPI) begin 
                    cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0: begin rxBuffer[47:40]<=OutDataPhase_SPI; end
                    1: begin rxBuffer[39:32]<=OutDataPhase_SPI; end
                    2: begin rxBuffer[31:24]<=OutDataPhase_SPI; end
                    3: begin rxBuffer[23:16]<=OutDataPhase_SPI; end
                    4: begin rxBuffer[15:8]<=OutDataPhase_SPI; end
                    5: begin rxBuffer[7:0]<=OutDataPhase_SPI; end
                    default: begin rxBuffer<=0; end
                    endcase
                end
            end
        `STEP_10: //Tx MAC.
            if(cnt_1==6) begin 
                cnt_1<=0; txBuffer<=192; //first byte of Gateway Address.
                step_i<=step_i+1;
            end
            else begin
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; cnt_1<=cnt_1+1; end
                else begin 
                    oUART_Tx_En<=1; 
                    case(cnt_1)
                    0: begin oUART_Tx_Data<=rxBuffer[47:40]; end
                    1: begin oUART_Tx_Data<=rxBuffer[39:32]; end
                    2: begin oUART_Tx_Data<=rxBuffer[31:24]; end
                    3: begin oUART_Tx_Data<=rxBuffer[23:16]; end
                    4: begin oUART_Tx_Data<=rxBuffer[15:8]; end
                    5: begin oUART_Tx_Data<=rxBuffer[7:0]; end
                    default: begin oUART_Tx_Data<=rxBuffer[47:40]; end
                    endcase
                end   
            end
        //////////////////////////////////////////////////////////////////////////////
        `STEP_11: //Set Gateway Address, 192.168.1.1
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_GAR0; //Gateway Address. (GAR)
                //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                //[2]:R/W,0:Read,1:Write. 
                //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                CtrlPhase_SPI<={5'd0,1'b1,2'b00}; 
                InDataPhase_SPI<=txBuffer; //first byte of MAC.
                VDMBytes_SPI<=4; //Gateway has 4 bytes.
                if(doneVDM_SPI) begin 
                    cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0: begin txBuffer<=168; end
                    1: begin txBuffer<=1; end
                    2: begin txBuffer<=1; end
                    default: begin txBuffer<=192; end
                    endcase
                end
            end
        /////////////////////////////////////////////////////////////////////////////////////////
        `STEP_12: //Read Gateway Address.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
                else begin 
                    En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                    AddrPhase_SPI<=ADDR_GAR0; //Gateway Address. (GAR)
                    //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                    //[2]:R/W,0:Read,1:Write. 
                    //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                    CtrlPhase_SPI<={5'd0,1'b0,2'b00}; 
                    InDataPhase_SPI<=0; //Random data.
                    VDMBytes_SPI<=4; //Gateway has 4 bytes.
                    if(doneVDM_SPI) begin 
                        cnt_1<=cnt_1+1;
                        case(cnt_1)
                        0: begin rxBuffer[31:24]<=OutDataPhase_SPI; end
                        1: begin rxBuffer[23:16]<=OutDataPhase_SPI; end
                        2: begin rxBuffer[15:8]<=OutDataPhase_SPI; end
                        3: begin rxBuffer[7:0]<=OutDataPhase_SPI; end
                        default: begin rxBuffer<=0; end
                        endcase
                    end
                end
        `STEP_13: //Tx Gateway.
            if(cnt_1==4) begin cnt_1<=0; step_i<=step_i+1; end
            else begin
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; cnt_1<=cnt_1+1; end
                else begin 
                    oUART_Tx_En<=1; 
                    case(cnt_1)
                    0: begin oUART_Tx_Data<=rxBuffer[31:24]; end
                    1: begin oUART_Tx_Data<=rxBuffer[23:16]; end
                    2: begin oUART_Tx_Data<=rxBuffer[15:8]; end
                    3: begin oUART_Tx_Data<=rxBuffer[7:0]; end
                    default: begin oUART_Tx_Data<=rxBuffer[31:24]; end
                    endcase
                end   
            end
        `STEP_14:
            if(cnt_1==32'h5F5E100-1) begin cnt_1<=0; step_i<=step_i-2; end
            else begin cnt_1<=cnt_1+1; end
        default:
            begin step_i<=`STEP_00; end
        endcase
    end
    else begin
        step_i<=`STEP_00; 
    end
end
endmodule