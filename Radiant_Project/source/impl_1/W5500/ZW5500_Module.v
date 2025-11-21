`include "ZPortableDefine.v"

module ZW5500_Module(
    input wire iClk,
    input wire iRstN,
    input wire iEn,

    output reg oLED,

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

    //[1:0]=2'b00, Read/Write Single Register.
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
reg [7:0] step_i_return;
reg [31:0] cnt_1;
reg [7:0] tmpDR;
//Rx Received Size.
reg [15:0] RxReceivedSize;
//Rx Read Pointer.
reg [15:0] RxReadPointer;
//Tx Free Size.
reg [15:0] TxFreeSize;
//Tx Read Pointer.
reg [15:0] TxReadPointer;
//Tx Write Pointer.
reg [15:0] TxWritePointer;

//How many bytes to Tx.
reg [7:0] txBytes;
reg [15:0] txWrPtr;

//reg [47:0] PHY_MAC={8'h00,8'h08,8'hDC,8'h12,8'h22,8'h12};
reg [143:0] rxBuffer; //Gateway(4)+Subnet Mask(4)+MAC(6)+IP(4)=18. 18*8-bits=144-bits.
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; step_i_return<=0; cnt_1<=0; 
    oW5500_RSTN<=1; En_SPI<=0; VDMBytes_SPI<=0; oUART_Tx_En<=0; 
    txBytes<=0;
    oLED<=0;
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
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_VERR; //VERSIONR, Chip Version Register.
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_COMMON_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_03: //Tx VERSIONR, if not expected, retry until getting correct version number.
            if(iUART_Tx_Done) begin oUART_Tx_En<=0; step_i<=(tmpDR==VERSION_W5500)?(step_i+1):(step_i-1); end
            else begin oUART_Tx_En<=1; oUART_Tx_Data<=tmpDR; end
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_04: //PHY Link Check.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_PHYCFGR; //PHYCFGR, PHY Configuration Register.
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_COMMON_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_05: //Tx PHYCFG, if link is down, retry until it's link up. PHYCFG[0]:Link Status,1:Link Up,0:Link Down.
            if(iUART_Tx_Done) begin oUART_Tx_En<=0; step_i<=(tmpDR[0])?(step_i+2):(step_i+1); end
            else begin oUART_Tx_En<=1; oUART_Tx_Data<=tmpDR; end
        `STEP_06: //Recheck after 1s.
            if(cnt_1==32'h5F5E100-1) begin cnt_1<=0; step_i<=step_i-2; end
            else begin cnt_1<=cnt_1+1; end
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_07: //Write Gateway-Subnet Mask-MAC-IP Address. 
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_GAR0; //Gateway Address. (GAR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_COMMON_REG, CP_RWB_WR, CP_OM_VDM}; 
                VDMBytes_SPI<=18; //Gateway(4)+Subnet Mask(4)+MAC(6)+IP(4)=18.
                case(cnt_1)
                0: begin InDataPhase_SPI<=192; end //Gateway Address: 192.168.1.1
                1: begin InDataPhase_SPI<=168; end //Gateway Address: 192.168.1.1
                2: begin InDataPhase_SPI<=1; end
                3: begin InDataPhase_SPI<=1; end
                4: begin InDataPhase_SPI<=255; end //Subnet Mask Address: 255.255.255.0
                5: begin InDataPhase_SPI<=255; end
                6: begin InDataPhase_SPI<=255; end
                7: begin InDataPhase_SPI<=0; end 
                8: begin InDataPhase_SPI<=8'h00; end //MAC Address: 00-08-55-12-22-87
                9: begin InDataPhase_SPI<=8'h08; end
                10:begin InDataPhase_SPI<=8'h55; end
                11:begin InDataPhase_SPI<=8'h12; end
                12:begin InDataPhase_SPI<=8'h22; end
                13:begin InDataPhase_SPI<=8'h87; end
                14:begin InDataPhase_SPI<=192; end //IP Address: 192.168.1.66
                15:begin InDataPhase_SPI<=168; end
                16:begin InDataPhase_SPI<=1; end
                17:begin InDataPhase_SPI<=66; end
                default: begin InDataPhase_SPI<=0; end
                endcase
                cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
            end
        `STEP_08:
            if(cnt_1==20) begin cnt_1<=0; step_i<=step_i+1; end
            else begin cnt_1<=cnt_1+1; end
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_09: //Read Gateway-Subnet Mask-MAC-IP Address. 
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_GAR0; //Gateway Address. (GAR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_COMMON_REG, CP_RWB_RD, CP_OM_VDM}; 
                InDataPhase_SPI<=0; //Random data.
                VDMBytes_SPI<=18; //Gateway(4)+Subnet Mask(4)+MAC(6)+IP(4)=18.
                if(doneVDM_SPI) begin cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0: begin rxBuffer[143:136]<=OutDataPhase_SPI; end
                    1: begin rxBuffer[135:128]<=OutDataPhase_SPI; end
                    2: begin rxBuffer[127:120]<=OutDataPhase_SPI; end
                    3: begin rxBuffer[119:112]<=OutDataPhase_SPI; end
                    4: begin rxBuffer[111:104]<=OutDataPhase_SPI; end
                    5: begin rxBuffer[103:96]<=OutDataPhase_SPI; end
                    6: begin rxBuffer[95:88]<=OutDataPhase_SPI; end
                    7: begin rxBuffer[87:80]<=OutDataPhase_SPI; end
                    8: begin rxBuffer[79:72]<=OutDataPhase_SPI; end                            
                    9: begin rxBuffer[71:64]<=OutDataPhase_SPI; end
                    10:begin rxBuffer[63:56]<=OutDataPhase_SPI; end
                    11:begin rxBuffer[55:48]<=OutDataPhase_SPI; end
                    12:begin rxBuffer[47:40]<=OutDataPhase_SPI; end
                    13:begin rxBuffer[39:32]<=OutDataPhase_SPI; end
                    14:begin rxBuffer[31:24]<=OutDataPhase_SPI; end
                    15:begin rxBuffer[23:16]<=OutDataPhase_SPI; end
                    16:begin rxBuffer[15:8]<=OutDataPhase_SPI; end
                    17:begin rxBuffer[7:0]<=OutDataPhase_SPI; end
                    default: begin rxBuffer<=0; end
                    endcase
                end
            end
        `STEP_10: //Tx Gateway-Subnet Mask-MAC-IP Address. 
            if(cnt_1==18) begin cnt_1<=0; step_i<=step_i+1; end
            else begin
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; cnt_1<=cnt_1+1; end
                else begin 
                    oUART_Tx_En<=1; 
                    case(cnt_1)
                    0: begin oUART_Tx_Data<=rxBuffer[143:136]; end
                    1: begin oUART_Tx_Data<=rxBuffer[135:128]; end
                    2: begin oUART_Tx_Data<=rxBuffer[127:120]; end
                    3: begin oUART_Tx_Data<=rxBuffer[119:112]; end
                    4: begin oUART_Tx_Data<=rxBuffer[111:104]; end
                    5: begin oUART_Tx_Data<=rxBuffer[103:96]; end
                    6: begin oUART_Tx_Data<=rxBuffer[95:88]; end
                    7: begin oUART_Tx_Data<=rxBuffer[87:80]; end
                    8: begin oUART_Tx_Data<=rxBuffer[79:72]; end                            
                    9: begin oUART_Tx_Data<=rxBuffer[71:64]; end
                    10:begin oUART_Tx_Data<=rxBuffer[63:56]; end
                    11:begin oUART_Tx_Data<=rxBuffer[55:48]; end
                    12:begin oUART_Tx_Data<=rxBuffer[47:40]; end
                    13:begin oUART_Tx_Data<=rxBuffer[39:32]; end
                    14:begin oUART_Tx_Data<=rxBuffer[31:24]; end
                    15:begin oUART_Tx_Data<=rxBuffer[23:16]; end
                    16:begin oUART_Tx_Data<=rxBuffer[15:8]; end
                    17:begin oUART_Tx_Data<=rxBuffer[7:0]; end
                    default: begin oUART_Tx_Data<=0; end
                    endcase
                end   
            end
        //////////////////////////////////////////////////////////////////////////////
        `STEP_11: //Set Socket0 Keepalive to 6*5s=30s.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_KPALVTR; //KeepAliveTimer.
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=6; //6*5s=30s.
            end
        ///////////////////////////////////////////////////////////////////////////////////////////
        //Check Socket n Status Register controlled by Sn_CR Command Register or Packet Send/Recv Status.
        `STEP_12: //Read Socket n Status Register.(Sn_SR)
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_SR; //Socket n Status.(Sn_SR)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                    InDataPhase_SPI<=8'd0; //random data here.
                end
        `STEP_13: //Tx Sn_SR.
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; step_i<=step_i+1; end
                else begin oUART_Tx_En<=1; oUART_Tx_Data<=tmpDR; end
        `STEP_14: //Check Socket n Status.
            begin
                /////////////////////////////////////////////
                step_i_return<=step_i+1;
                /////////////////////////////////////////////
                case(tmpDR)
                SOCK_ESTABLISHED: begin step_i<=`STEP_20; end //SR=0x17.
                SOCK_CLOSE_WAIT: begin step_i<=`STEP_40; end
                SOCK_INIT: begin step_i<=`STEP_60; end //SR=0x13.
                SOCK_CLOSED: begin step_i<=`STEP_80; end //SR=0x00.
                default: begin step_i<=step_i+1; end
                endcase
            end
        `STEP_15: //Loop to check Socket n Status Register.
            if(cnt_1==32'h5F5E100-1) begin cnt_1<=0; oLED<=~oLED; step_i<=step_i-3; end
            else begin cnt_1<=cnt_1+1; end
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        //SOCK_ESTABLISHED Processing Here.
        `STEP_20: //Read Socket n Interrupt Register (Sn_IR)
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                    InDataPhase_SPI<=8'd0; //random data here.
                end
        `STEP_21: //if IR_CON is set, then write 1 to clear it.
            if(tmpDR & IR_CON) begin 
                if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
                else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                    InDataPhase_SPI<=IR_CON; //Write 1 to clear it.
                end
            end
            else begin step_i<=step_i+1; end
        ////////////////////////////////////////////////////////////////////////////////////////////
        //Data Transaction Parts - Receive Buffer Handler Here.
        //Sn_Rx_RSR indicates the data size received and saved in Socket n Rx Buffer.
        `STEP_22: //Read Rx-Received-Size(0x0026,0x0027) and Rx-Read-Pointer(0x0028,0x0029) registers.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_RX_RSR0; //Socket n Rx Received Size. (Sn_RX_RSR0, Sn_RX_RSR1)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG,CP_RWB_RD,CP_OM_VDM}; 
                InDataPhase_SPI<=0; //Random data.
                VDMBytes_SPI<=4; //Sn_RX_RSR0+Sn_RX_RSR1+Sn_RX_RD0+Sn_RX_RD1=4 Bytes.
                if(doneVDM_SPI) begin cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0:begin RxReceivedSize[15:8]<=OutDataPhase_SPI; end
                    1:begin RxReceivedSize[7:0]<=OutDataPhase_SPI; end
                    2:begin RxReadPointer[15:8]<=OutDataPhase_SPI; end
                    3:begin RxReadPointer[7:0]<=OutDataPhase_SPI; end
                    default: begin RxReceivedSize<=0; RxReadPointer<=0; end
                    endcase
                end
            end
        `STEP_23: //Tx Rx-Received-Size and Rx-Read-Pointer.
            if(cnt_1==4) begin cnt_1<=RxReceivedSize; step_i<=step_i+1; end
            else begin
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; cnt_1<=cnt_1+1; end
                else begin oUART_Tx_En<=1; 
                    case(cnt_1)
                    0:begin oUART_Tx_Data<=RxReceivedSize[15:8]; end
                    1:begin oUART_Tx_Data<=RxReceivedSize[7:0]; end
                    2:begin oUART_Tx_Data<=RxReadPointer[15:8]; end
                    3:begin oUART_Tx_Data<=RxReadPointer[7:0]; end
                    default: begin oUART_Tx_Data<=0; end
                    endcase
                end   
            end
        `STEP_24: //Read all data back.
            if(cnt_1>0) begin
                if(OpDone_SPI) begin En_SPI<=0; rxBuffer[7:0]<=OutDataPhase_SPI; cnt_1<=cnt_1-1; end
                else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_RX_RD0; //Socket n Rx Read Pointer. (Sn_RX_RD0, Sn_RX_RD1)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_RX, CP_RWB_RD, CP_OM_1}; 
                    InDataPhase_SPI<=0; //Random data.
                end
            end
            else begin RxReadPointer<=RxReadPointer+RxReceivedSize; step_i<=(RxReceivedSize>0)?(step_i+1):(step_i+2); end
        `STEP_25: //After Reading, update Rx-Read-Pointer.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_RX_RD0; //Socket n Rx Read Pointer. (Sn_RX_RD0, Sn_RX_RD1)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_VDM}; 
                VDMBytes_SPI<=2; //Rx-Read-Pointer is 2 bytes.
                case(cnt_1)
                0: begin InDataPhase_SPI<=RxReadPointer[15:8]; end
                1: begin InDataPhase_SPI<=RxReadPointer[7:0]; end
                default: begin InDataPhase_SPI<=0; end
                endcase
                cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
            end
        `STEP_26: //Order RECV command is for notifying the updated Sn_Rx_RD to W5500.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=CMD_RECV;
            end
        `STEP_27: //After W5500 accepts the command, Sn_CR register is automatically cleared to 0x00.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_28: //Retry to check until W5500 executed the command. timeout(1s) to quit.
            if((!tmpDR) || (cnt_1=32'h5F5E100-1)) begin cnt_1<=0; step_i<=step_i+1; end
            else begin cnt_1<=cnt_1+1; step_i<=step_i-1; end
        ////////////////////////////////////////////////////////////////////////////////////////////
        //Data Transaction Parts - Transmit Buffer Handler Here.
        `STEP_29: //Read IR.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                    InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_30: //if IR_SEND_OK is set, then write 1 to clear it.
            if(tmpDR & IR_SEND_OK) begin
                if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
                else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                    InDataPhase_SPI<=IR_SEND_OK; //Write 1 to clear it.
                end
            end
            else begin step_i<=step_i+1; end
        `STEP_31: //Read Tx-Free-Size(0x0020,0x0021),Tx-Read-Pointer(0x2022,0x2023) and TX-Write-Pointer(0x0024,0x0025) registers.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_TX_FSR0; //Socket n TX Free Size. (Sn_TX_FSR0, Sn_TX_FSR1)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG,CP_RWB_RD,CP_OM_VDM}; 
                InDataPhase_SPI<=0; //Random data.
                VDMBytes_SPI<=6; //From 0x0020~0x0025, 6 bytes totally.
                if(doneVDM_SPI) begin cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0:begin TxFreeSize[15:8]<=OutDataPhase_SPI; end
                    1:begin TxFreeSize[7:0]<=OutDataPhase_SPI; end
                    2:begin TxReadPointer[15:8]<=OutDataPhase_SPI; end
                    3:begin TxReadPointer[7:0]<=OutDataPhase_SPI; end
                    4:begin TxWritePointer[15:8]<=OutDataPhase_SPI; end
                    5:begin TxWritePointer[7:0]<=OutDataPhase_SPI; end
                    default: begin TxFreeSize<=0; TxReadPointer<=0; TxWritePointer<=0; end
                    endcase
                end
            end
        `STEP_32: //Tx Tx-Free-Size, Tx-Read-Pointer and TX-Write-Pointer. strlen(ILoveChina=10)
            if(cnt_1==6) begin cnt_1<=0; step_i<=(TxFreeSize>10)?(step_i+1):(step_i+3); end
            else begin
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; cnt_1<=cnt_1+1; end
                else begin oUART_Tx_En<=1; 
                    case(cnt_1)
                    0:begin oUART_Tx_Data<=TxFreeSize[15:8]; end
                    1:begin oUART_Tx_Data<=TxFreeSize[7:0]; end
                    2:begin oUART_Tx_Data<=TxReadPointer[15:8]; end
                    3:begin oUART_Tx_Data<=TxReadPointer[7:0]; end
                    4:begin oUART_Tx_Data<=TxWritePointer[15:8]; end
                    5:begin oUART_Tx_Data<=TxWritePointer[7:0]; end
                    default: begin oUART_Tx_Data<=0; end
                    endcase
                end   
            end
        `STEP_33: //Write data to TxBufferBlock TxWritePointer Position if TxFreeSize>0.
                if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; TxWritePointer<=TxWritePointer+10; step_i<=step_i+1; end
                else begin 
                    En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                    AddrPhase_SPI<=TxWritePointer; 
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_TX, CP_RWB_WR, CP_OM_VDM}; 
                    VDMBytes_SPI<=10; //maximum 4 bytes each time.
                    case(cnt_1)
                    0: begin InDataPhase_SPI<=8'h49; end //I
                    1: begin InDataPhase_SPI<=8'h4C; end //L
                    2: begin InDataPhase_SPI<=8'h6F; end //o
                    3: begin InDataPhase_SPI<=8'h76; end //v
                    4: begin InDataPhase_SPI<=8'h65; end //e
                    5: begin InDataPhase_SPI<=8'h43; end //C
                    6: begin InDataPhase_SPI<=8'h68; end //h
                    7: begin InDataPhase_SPI<=8'h69; end //i
                    8: begin InDataPhase_SPI<=8'h6E; end //n
                    9: begin InDataPhase_SPI<=8'h61; end //a
                    default: begin InDataPhase_SPI<=0; end
                    endcase
                    cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
                end
        `STEP_34: //After writing, update TxWritePointer.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_TX_WR0; //Socket n Tx Write Pointer. (Sn_TX_WR0, Sn_TX_WR1)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_VDM}; 
                VDMBytes_SPI<=2; //Rx-Read-Pointer is 2 bytes.
                case(cnt_1)
                0: begin InDataPhase_SPI<=TxWritePointer[15:8]; end
                1: begin InDataPhase_SPI<=TxWritePointer[7:0]; end
                default: begin InDataPhase_SPI<=0; end
                endcase
                cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
            end
        `STEP_35: //Order SEND Command.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=CMD_SEND;
            end
        `STEP_36: //After W5500 accepts the command, Sn_CR register is automatically cleared to 0x00.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_37: //Retry to check until W5500 executed the command.timeout(1 second) to quit.
            if((!tmpDR) || (cnt_1=32'h5F5E100-1)) begin cnt_1<=0; step_i<=step_i_return; end
            else begin cnt_1<=cnt_1+1; step_i<=step_i-1; end
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        //SOCK_CLOSE_WAIT Processing Here.
        `STEP_40: //Write Socket n Command Register to DISCON.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=CMD_DISCON;
            end
        `STEP_41: //After W5500 accepts the command, Sn_CR register is automatically cleared to 0x00.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_42: //Retry to check until W5500 executed the command.
            begin step_i<=(!tmpDR)?(step_i+1):(step_i-1); end
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_43: //Read Socket n Status Register. (Sn_SR)
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_SR; //Socket n Status.(Sn_SR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_44: //Retry to check until socket state is SOCK_CLOSED. timeout(1 second) to quit.
            if((tmpDR==SOCK_CLOSED)||(cnt_1==32'h5F5E100-1)) begin cnt_1<=0; step_i<=step_i_return; end
            else begin cnt_1<=cnt_1+1; step_i<=step_i-1; end
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        //SOCK_INIT Processing Here.
        `STEP_60: //Destination IP Address: 192.168.1.86
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_DIPR0; //Socket n Destination IP Address. (Sn_DIPR0,Sn_DIPR1,Sn_DIPR2,Sn_DIPR3)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_VDM}; 
                VDMBytes_SPI<=4; //IP Address is 4 bytes.
                case(cnt_1)
                0: begin InDataPhase_SPI<=192; end
                1: begin InDataPhase_SPI<=168; end
                2: begin InDataPhase_SPI<=1; end
                3: begin InDataPhase_SPI<=86; end
                default: begin InDataPhase_SPI<=0; end
                endcase
                cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
            end
        `STEP_61: //Set Destination Port: 0x1234.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_DPORT0; //Socket n Destination Port. (Sn_DPORT0, Sn_DPORT1)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_VDM}; 
                VDMBytes_SPI<=2; //TCP Port=0x1234. 2 bytes.
                case(cnt_1)
                0: begin InDataPhase_SPI<=8'h12; end
                1: begin InDataPhase_SPI<=8'h34; end
                default: begin InDataPhase_SPI<=0; end
                endcase
                cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
            end
        `STEP_62: //Read back Destination IP Address and Destination Port. 
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_DIPR0; //Socket n Destination IP Address. (Sn_DIPR0,Sn_DIPR1,Sn_DIPR2,Sn_DIPR3)
                CtrlPhase_SPI<={BSB40_SOCKET0_REG,CP_RWB_RD,CP_OM_VDM}; 
                InDataPhase_SPI<=0; //Random data.
                VDMBytes_SPI<=6; //Destination IP(4)+Destination Port(2)=6.
                if(doneVDM_SPI) begin cnt_1<=cnt_1+1;
                    case(cnt_1)
                    0:begin rxBuffer[47:40]<=OutDataPhase_SPI; end
                    1:begin rxBuffer[39:32]<=OutDataPhase_SPI; end
                    2:begin rxBuffer[31:24]<=OutDataPhase_SPI; end
                    3:begin rxBuffer[23:16]<=OutDataPhase_SPI; end
                    4:begin rxBuffer[15:8]<=OutDataPhase_SPI; end
                    5:begin rxBuffer[7:0]<=OutDataPhase_SPI; end
                    default: begin rxBuffer<=0; end
                    endcase
                end
            end
        `STEP_63: //Tx Destination IP Address and Destination Port. 
            if(cnt_1==6) begin cnt_1<=0; step_i<=step_i+1; end
            else begin
                if(iUART_Tx_Done) begin oUART_Tx_En<=0; cnt_1<=cnt_1+1; end
                else begin 
                    oUART_Tx_En<=1; 
                    case(cnt_1)
                    0:begin oUART_Tx_Data<=rxBuffer[47:40]; end
                    1:begin oUART_Tx_Data<=rxBuffer[39:32]; end
                    2:begin oUART_Tx_Data<=rxBuffer[31:24]; end
                    3:begin oUART_Tx_Data<=rxBuffer[23:16]; end
                    4:begin oUART_Tx_Data<=rxBuffer[15:8]; end
                    5:begin oUART_Tx_Data<=rxBuffer[7:0]; end
                    default: begin oUART_Tx_Data<=0; end
                    endcase
                end   
            end
        `STEP_64: //Write Socket n Command Register to CONNECT.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=CMD_CONNECT;
            end
        `STEP_65: //Read Socket n Command Register to ensure W5500 receives this command.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_66: //After W5500 accepts the command, Sn_CR register is automatically cleared to 0x00.
            begin step_i<=(!tmpDR)?(step_i+1):(step_i-1); end
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_67: //Read Socket n Status Register. (Sn_SR)
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_SR; //Socket n Status.(Sn_SR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_68: //Retry to issue CONNECT command until socket state is SOCK_ESTABLISHED.
            begin step_i<=(tmpDR==SOCK_ESTABLISHED)?(step_i+3/*68+3=71*/):(step_i+1); end
        `STEP_69: //Clear Timeout Interrupt in IR.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_70: //If [3]=1, Sn_IR(TIMEOUT) Interrupt occurs, write 1 to clean it. otherwise retry to issue CONNECT.
            if(tmpDR[3]) begin 
                if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i-10;/*70-10=60*/ end
                else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                    //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                    InDataPhase_SPI<=8'h08; //write [3]=1 to clear TIMEOUT interrupt.
                end
            end
            else begin step_i<=step_i-10;/*70-10=60*/ end
        `STEP_71: //SOCK_ESTABLISHED is okay.
            begin step_i<=step_i_return; end
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //SOCK_CLOSED Processing Here.
        `STEP_80: //Write Socket n Command Register to CLOSE.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=CMD_CLOSE;
            end
        `STEP_81: //Read Socket n Command Register to ensure W5500 receives this command.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_82: //After W5500 accepts the command, Sn_CR register is automatically cleared to 0x00.
            begin step_i<=(!tmpDR)?(step_i+1):(step_i-1); end
        `STEP_83: //Clear all interrupt of the socket.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_IR; //Socket n Interrupt Register. (Sn_IR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=8'hFF; //Write 1 to clear interrupt flags.
            end
        `STEP_84: //Check Status Register to ensure socket state changes to SOCK_CLOSED.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_SR; //Socket n Status.(Sn_SR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_85: //Retry to check until socket state is SOCK_CLOSED.
            begin step_i<=(tmpDR==SOCK_CLOSED)?(step_i+1):(step_i-1); end
        `STEP_86: //Set Socket n Mode Register (Sn_MR).
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_MR; //Socket n Mode. (Sn_MR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                //[7]:0, don't care in TCP mode.
                //[6]:0, don't care in TCP mode.
                //[5]:1, Enable No Delayed ACK option.
                //[4]:0, don't care in TCP mode.
                //[3:0]=0001, TCP.
                InDataPhase_SPI<={1'b0,1'b0,1'b1,1'b0,PRO_MODE_TCP};
            end
        `STEP_87: //Set Socket n Source Port. (Sn_PORT0, Sn_PORT1).TCP Port=0x1234.
            if(OpDone_SPI) begin En_SPI<=0; cnt_1<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b01; //[1:0]=2'b01, Variable Length Read/Write.
                AddrPhase_SPI<=ADDR_Sn_PORT0; //Socket n Source Port. (Sn_PORT0, Sn_PORT1)
                //[7-3]: Block Select Bits.5'b00000,Selects Common Register.
                //[2]:R/W,0:Read,1:Write. 
                //[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:Fixed Data length, 1 byte data length.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_VDM}; 
                VDMBytes_SPI<=2; //TCP Port=0x1234. 2 bytes.
                case(cnt_1)
                0: begin InDataPhase_SPI<=8'h12; end //First Byte.
                1: begin InDataPhase_SPI<=8'h34; end //Second Byte.
                default: begin InDataPhase_SPI<=0; end
                endcase
                cnt_1<=(doneVDM_SPI)?(cnt_1+1):(cnt_1);
            end
        `STEP_88: //Set Socket n Command Register to OPEN.
            if(OpDone_SPI) begin En_SPI<=0; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits. [2]:R/W,0:Read,1:Write. [1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_WR, CP_OM_1}; 
                InDataPhase_SPI<=CMD_OPEN;
            end
        `STEP_89: //Read Socket n Command Register to ensure W5500 receives this command.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                AddrPhase_SPI<=ADDR_Sn_CR; //Socket n Command Register. (Sn_CR)
                //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                InDataPhase_SPI<=8'd0; //random data here.
            end
        `STEP_90: //After W5500 accepts the command, Sn_CR register is automatically cleared to 0x00.
            begin step_i<=(!tmpDR)?(step_i+1):(step_i-1); end
        `STEP_91: //Check Sn_SR to ensure socket state is changed, not SOCK_CLOSED.
            if(OpDone_SPI) begin En_SPI<=0; tmpDR<=OutDataPhase_SPI; step_i<=step_i+1; end
            else begin 
                    En_SPI<=1; OpReq_SPI<=2'b00; //[1:0]=2'b00, Read/Write Single Register.
                    AddrPhase_SPI<=ADDR_Sn_SR; //Socket n Status.(Sn_SR)
                    //[7-3]: Block Select Bits.[2]:R/W,0:Read,1:Write.[1-0]:OP Mode,2'b00:Variable data length mode, 2'b01:1 bytes, 2'b10: 2 bytes. 2'b11: 4 bytes.
                    CtrlPhase_SPI<={BSB40_SOCKET0_REG, CP_RWB_RD, CP_OM_1}; 
                    InDataPhase_SPI<=8'd0; //random data here.
                end
        `STEP_92: //Retry until Socket state is not SOCK_CLOSED. timeout(1 second) to quit.
            if((tmpDR!=SOCK_CLOSED) || (cnt_1==32'h5F5E100-1)) begin cnt_1<=0; step_i<=step_i+1; end
            else begin cnt_1<=cnt_1+1; step_i<=step_i-1; end
        `STEP_93:
            begin step_i<=step_i_return; end
        //////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_100: //Never Reach Here.
            begin step_i<=step_i; end
        default:
            begin step_i<=`STEP_00; end
        endcase
    end
    else begin
        step_i<=`STEP_00; 
    end
end
endmodule