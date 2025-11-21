`include "ZPortableDefine.v"

//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module POF_DPU_TOP(
    input wire iClk_25MHz,

    //HyperRAM-1#.
    output wire oH1_RSTN,
    output wire oH1_CSN,
    output wire oH1_CKP,
    //output wire oH1_CKN,
    inout wire ioH1_RWDS0,
    inout wire ioH1_RWDS1,
    inout wire[15:0] ioH1_D,

    //HyperRAM-2#.
    output wire oH2_RSTN,
    output wire oH2_CSN,
    output wire oH2_CKP,
    //output wire oH2_CKN,
    inout wire ioH2_RWDS0,
    inout wire ioH2_RWDS1,
    inout wire [15:0] ioH2_D,

    //IR Image Sensor.
    input iIR_PCLK,
    input iIR_VSYNC,
    input iIR_HSYNC,
    input [13:0] iIR_Data,
    output oIR_PWR_EN,
    input iIR_UART_RX,
    output oIR_UART_TX,

    //UV Image Sensor.
    input iBT1120_CLK,
    input iSYNC_O,
    input [7:0] iBT1120_D,

    input iUV_UART_RX,
    output oUV_UART_TX,

    output oUV_PWR_EN,

    //OV5640 Image Sensor.
    input wire iDVP_PCLK,
    input wire iDVP_HSYNC,
    input wire iDVP_VSYNC,
    input wire [7:0] iDVP_D,

    output wire oDVP_SCL,
    inout wire ioDVP_SDA,

    output wire oDVP_RST,
    output wire oDVP_PWDN,


    //CAT25512 EEPROM.
    output wire oSPI_CS,
    output wire oSPI_SCK,
    output wire oSPI_SO,
    input wire iSPI_SI,

    //VersionID*2.
    input [1:0] iVersion_ID,

    //Debug LED*3.
    output wire oLED1,
    output reg oLED2,
    output reg oLED3,

    //UART UPLOAD IF.
    input wire iDPU_RX,
    output wire oDPU_TX,

    output wire oLD_PWR_EN,
    output wire oIAM_ALIVE,
    output wire oIO_P5V0_SHDN,

    //Laser Diode.
    output oTX_EN,
    output oUART_T_LD,
    output oUART_T,

    //Aux.
    output oClkUsed,

    //W5500 Physical Pins.
    output wire oW5500_CSN, //SPI_CS.
    output wire oW5500_SCLK, //SPI_SCLK.
    output wire oW5500_MOSI, //SPI_MISO.
    input wire iW5500_MISO, //SPI_MISO.
    output wire oW5500_RSTN, //Reset.
    input wire iW5500_INTN //Interrupt Signal.
);

assign oLD_PWR_EN=1;
assign oIAM_ALIVE=1;
assign oIO_P5V0_SHDN=1;


//On-board Oscillator 25.0MHz -> PLL -> 100.0MHz (Phase Shift Degree 0)
//                                   -> 100.0MHz (Phase Shift Degree 90)
wire clk_100MHz_i;
wire clk_100MHz_Shift90_i;
wire clk_8MHz_Sample;
wire rst_n_i;
ZPLL myPLL(
    .clki_i(iClk_25MHz),
    .clkop_o(clk_100MHz_i),
    .clkos_o(clk_100MHz_Shift90_i),
    .clkos2_o(clk_8MHz_Sample),
    .lock_o(rst_n_i));
//Expand reset to 1 second.
//100MHz,hex(100000000)=0x5F5E100
reg rst_n_long;
reg [26:0] cnt_rst;
always @(posedge clk_100MHz_i or negedge rst_n_i)
if(!rst_n_i) begin cnt_rst<=0; rst_n_long<=0; end
else begin
    if(cnt_rst==32'h5F5E100) begin rst_n_long<=1; end
    else begin cnt_rst<=cnt_rst+1; rst_n_long<=0; end
end
GSR #(.SYNCMODE ("ASYNC")) myGSR(
  .GSR_N (rst_n_long),  // I
  .CLK   (clk_100MHz_i)   // I
);

//This UART is used to output debug information.
//It is shared by many modules, so a multiplexer is used here.
//It outputs data at UART_T_LD pin.
//TX_EN pin must be driven to HIGH.
assign oTX_EN=1;
//100MHz/1MHz=100.
//100MHz/100KHz=1000.
wire enUART;
wire [7:0] txDataUART;
wire doneUART;
//When using Laser diode, add a NOT gate here.
wire txdUART;
assign txdUART=oUART_T;
ZUART_Tx #(.Freq_divider(100)) myUART_Tx 
(
	.iClk(clk_100MHz_i),
	.iRstN(rst_n_long),
    .iEn(enUART),
	
	.iData(txDataUART),
	.oDone(doneUART),
	.oTxD(txdUART)
);

//Instance for W5500 Module.
ZW5500_Module myW5500(
    .iClk(clk_100MHz_i),
    .iRstN(rst_n_long),
    .iEn(1'b1),

    //W5500 Physical Pins.
    .oW5500_CSN(oW5500_CSN), //SPI_CS.
    .oW5500_SCLK(oW5500_SCLK), //SPI_SCLK.
    .oW5500_MOSI(oW5500_MOSI), //SPI_MISO.
    .iW5500_MISO(iW5500_MISO), //SPI_MISO.
    .oW5500_RSTN(oW5500_RSTN), //Reset.
    .iW5500_INTN(iW5500_INTN), //Interrupt Signal.

    //UART_Tx Interface used to output debug information.
    .oUART_Tx_En(enUART),
    .oUART_Tx_Data(txDataUART),
    .iUART_Tx_Done(doneUART)
);

endmodule

/*
//On-Chip Oscillator, Not Accurate.
//HF: configured to 225.0MHz.
//LF: 32.0KHz.
wire clk_HF_i;
wire clk_LF_i;
ZOSC myOSC(.hf_out_en_i(1'b1),
.hf_clk_out_o(clk_HF_i),
.lf_clk_out_o(clk_LF_i));

// wire clk_270MHz;
// ZPLL2 myPLL2(.clki_i(clk_HF_i),
//         .clkop_o(clk_270MHz),
//         .lock_o( ));

//DDR Clock is same as System Clock.
// ODDRX1
// #(
// .GSR ("ENABLED")
// )H1_CLK (
// .D0   (1'b1),  // I
// .D1   (1'b0),  // I
// .SCLK (clk_50MHz_i),  // I
// .RST  (~iRstN),  // I
// .Q    (oH1_CKP)   // O
// );

// ODDRX1
// #(
// .GSR ("ENABLED")
// )H2_CLK (
// .D0   (1'b1),  // I
// .D1   (1'b0),  // I
// .SCLK (clk_50MHz_i),  // I
// .RST  (~iRstN),  // I
// .Q    (oH2_CKP)   // O
// );

assign oIR_PWR_EN=1;
///////////////////////////////////////////////////////////////////
//Write Port.
// wire wr_EnFIFO;
// wire [15:0] wr_DataFIFO;
// wire full_FIFO;
// //Read Port.
// wire rd_EnFIFO;
// wire [15:0] rd_DataFIFO;
// wire empty_FIFO;
// wire AlmostEmpty, AlmostFull;
// //reset after one frame.
reg rst_fifo;
// pmi_fifo #(
//   .pmi_data_width        (16), // integer       
//   .pmi_data_depth        (40960), // integer       
//   .pmi_almost_full_flag  (40958), // integer (pmi_almost_full_flag MUST be LESS than pmi_data_depth)       
//   .pmi_almost_empty_flag (16), // integer		
//   .pmi_regmode           ("reg"), // "reg"|"noreg"    	
//   .pmi_fwft				 ("disable"), // "enable" | "disable" 
//   .pmi_family            ("LIFCL"), // "LIFCL"|"LFD2NX"|"LFCPNX"|"LFMXO5"|"UT24C"|"UT24CP"|"common"
//   .pmi_implementation    ("EBR")  // "LUT"|"EBR"|"HARD_IP"
// ) myPMI_FIFO (         
//   .Data        (wr_DataFIFO), // I:      
//   .Clock       (clk_100MHz_i), // I:
//   .WrEn        (wr_EnFIFO), // I:
//   .RdEn        (rd_EnFIFO), // I:
//   .Reset       ((~rst_n_long) | rst_fifo), // I: 1:Reset, 0: Normal.
//   .Q           (rd_DataFIFO), // O:
//   .Empty       (empty_FIFO), // O:
//   .Full        (full_FIFO), // O:
//   .AlmostEmpty (AlmostEmpty), // O:
//   .AlmostFull  (AlmostFull)  // O:
// );

////////////////////////////////////////////////////////
//Configure OV5640 to JPEG mode.
reg enOV5640Cfg_i;
// wire OV5640CfgDone_i;
reg Cfg_UART_TxEn_i;
reg [7:0] Cfg_UART_TxData_i;
reg Cfg_UART_TxDone_i;
// ZOV5640_Cfg myOV5640_Cfg(
//     .iClk(clk_100MHz_i),
//     .iRstN(rst_n_long),
//     .iEn(enOV5640Cfg_i),
//     .oCfgDone(OV5640CfgDone_i),

//     //DVP SCCB Interface.
//     .oDVP_SCL(oDVP_SCL),
//     .ioDVP_SDA(ioDVP_SDA),

//     .oDVP_RST(oDVP_RST),
//     .oDVP_PWDN(oDVP_PWDN),

//     //Debug UART.
//     .oTxEn(Cfg_UART_TxEn_i),
//     .oTxData(Cfg_UART_TxData_i),
//     .iTxDone(Cfg_UART_TxDone_i)
// );
////////////////////////////////////////////////////////////////////////////
reg enDVP_i;
// wire wrFrm2FIFODone;
// wire [31:0] wrFrmBytes;
// ZOV5640_DVP myOV5640_DVP(
//     .iClk(clk_100MHz_i), //100MHz.
//     .iRstN(rst_n_long),
//     .iEn(enDVP_i),

//     //OV5640 Image Sensor.
//     .iDVP_PCLK(iDVP_PCLK), //24MHz,12MHz.
//     .iDVP_HSYNC(iDVP_HSYNC),
//     .iDVP_VSYNC(iDVP_VSYNC),
//     .iDVP_D(iDVP_D),


//     //Dual-Port FIFO, Write Port.
//     .iFull_FIFO(full_FIFO),
//     .oWrEn_FIFO(wr_EnFIFO),
//     .oWrData_FIFO(wr_DataFIFO),

//     //Already write one frame into FIFO.
//     .oWrFrmDone(wrFrm2FIFODone),
//     //How many bytes were written into FIFO.
//     .oWrFrmBytes(wrFrmBytes)
// );

///////////////////////////////////////////////////////
reg en_HRAM_i;
wire HRAM_UART_TxEn_i;
wire [7:0] HRAM_UART_TxData_i;
// wire UART_Upload_Done;
reg HRAM_UART_TxDone_i;
// wire HRAM_SelfCheckDone_i;
// ZHyperRAM myHyperRAM(
//     .iClk(clk_100MHz_i),
//     .iClkShift90(clk_100MHz_Shift90_i),
//     .iEn(en_HRAM_i),
//     .iRstN(rst_n_long),

//     //HyperRAM Interface.
//     .oRSTN(oH1_RSTN),
//     .oCSN(oH1_CSN),
//     .oCKP(oH1_CKP),
//     //output oCKN,
//     .ioRWDS0(ioH1_RWDS0),
//     .ioRWDS1(ioH1_RWDS1),
//     .ioDQ(ioH1_D),

//     //Debug UART.
//     .oTxEn(HRAM_UART_TxEn_i),
//     .oTxData(HRAM_UART_TxData_i),
//     .iTxDone(HRAM_UART_TxDone_i),
//     //UART Tx Done.
//     .oUART_Upload_Done(UART_Upload_Done),

//     //Self Check Done. Read data equals to written data.
//     .oSelfCheckDone(HRAM_SelfCheckDone_i),

//     //Dual-Port, Dual Clock, FIFO.
//     //Read data from FIFO and write into Hyper RAM.
//     .oRd_EnFIFO(rd_EnFIFO),
//     .iRd_DataFIFO(rd_DataFIFO),
//     .iEmpty_FIFO(empty_FIFO),

//     //OV5640_DVP Already write one frame into FIFO.
//     .iWrFrm2FIFODone(wrFrm2FIFODone),
//     //How many bytes OV5640_DVP wrote into FIFO.
//     .iWrFrmBytes(wrFrmBytes),
//     //Auxiliary Signals, routed to physical pins to measure how many clocks one block uses.
//     .oClkUsed(oClkUsed)
// );

/////////////////////////////////////////////////////////////////////////////////////////////////
//This UART is used to output debug information.
//It is shared by many modules, so a multiplexer is used here.
//It outputs data at UART_T_LD pin.
//TX_EN pin must be driven to HIGH.
assign oTX_EN=1;
//100MHz/1MHz=100.
//100MHz/100KHz=1000.
reg UART_Tx_En;
reg [7:0] UART_Tx_Data;
wire UART_Tx_Done;
//When using Laser diode, add a NOT gate here.
wire UART_TxD_Pin;
//assign oUV_UART_TX=~UART_TxD_Pin;
assign oUV_UART_TX=UART_TxD_Pin;
assign oDPU_TX=UART_TxD_Pin;
//assign oUART_T_LD=UART_TxD_Pin;
ZUART_Tx #(.Freq_divider(100)) myUART_Tx 
(
	.iClk(clk_100MHz_i),
	.iRst_N(rst_n_long),
	.iData(UART_Tx_Data),
	
	//pull down iEn to start transmition until pulse done oDone was issued.
	.iEn(UART_Tx_En),
	.oDone(UART_Tx_Done),
	.oTxD(UART_TxD_Pin)
);
/////////////////////////////////////////////////////////////////////////////////////////////////
//For Top Module Use.
reg Top_UART_TxEn=0;
reg [7:0] Top_UART_TxData;
reg Top_UART_TxDone;
//Multiplex for UART.
//0: Top Module.
//1: OV5640 SCCB Module.
//2: OV5640 DVP Module.
//3: Hyper RAM Module.
//4: SPI EEPROM Module.
reg [2:0] UART_MUX; //2^3=8.
always @(UART_MUX)
begin 
    case(UART_MUX)
    0: //Top Module.
        begin UART_Tx_En=Top_UART_TxEn; UART_Tx_Data=Top_UART_TxData; Top_UART_TxDone=UART_Tx_Done; end
    1: //OV5640 SCCB Configure.
        begin UART_Tx_En=Cfg_UART_TxEn_i; UART_Tx_Data=Cfg_UART_TxData_i; Cfg_UART_TxDone_i=UART_Tx_Done; end
    2: //Hyper RAM.
        begin UART_Tx_En=HRAM_UART_TxEn_i; UART_Tx_Data=HRAM_UART_TxData_i; HRAM_UART_TxDone_i=UART_Tx_Done; end
    3: //OV5640 DVP.
        begin UART_Tx_En=HRAM_UART_TxEn_i; UART_Tx_Data=HRAM_UART_TxData_i; HRAM_UART_TxDone_i=UART_Tx_Done; end
    default:
        begin UART_Tx_En=Top_UART_TxEn; UART_Tx_Data=Top_UART_TxData; Top_UART_TxDone=UART_Tx_Done; end
    endcase
end
/////////////////////////////////////////////////////////////////////////////////////////////////
reg en_CAT25512;
reg [1:0] OpReq_CAT25512;
reg [7:0] WrData_CAT25512;
reg [15:0] OpAddr_CAT25512;
wire [7:0] RdData_CAT25512;
wire OpDone_CAT25512;
ZCAT25512 myCAT25512(
	.iClk(clk_100MHz_i),
	.iRstN(rst_n_long),
    .iEn(en_CAT25512),

    //2'b00: Write Flag.
    //2'b01: Read Flag. 
    .iOpReq(OpReq_CAT25512),
    .iWrData(WrData_CAT25512),
    .iOpAddr(OpAddr_CAT25512),
    .oRdData(RdData_CAT25512),
    .oOpDone(OpDone_CAT25512),

    //EEPROM SPI Interface.
    .oSPI_CS(oSPI_CS),
    .oSPI_SCK(oSPI_SCK),
    .oSPI_SO(oSPI_SO),
    .iSPI_SI(iSPI_SI)
);
reg enUARTRx;
wire validRx;
wire [7:0] dataRx;
ZUART_Rx #(.Freq_divider(25)) myUARTRx
(
	.iClk(clk_100MHz_i),
	.iRst_N(rst_n_long),
	//pull down iEn to start transmition until pulse done oDone was issued.
	.iEn(enUARTRx),
	.iRxD(~iUV_UART_RX),

	.oDataValid(validRx),
	.oData(dataRx)
);


///////////////////////////////////////////////////////////////////////////////////////////////
//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt;
always @(posedge clk_100MHz_i or negedge rst_n_long)
if(!rst_n_long) begin step_i<=0; cnt<=0; end
else begin
    case(step_i)
        `STEP_00: 
            if(Top_UART_TxDone) begin Top_UART_TxEn<=0; step_i<=step_i+1; end
            else begin Top_UART_TxEn<=1; Top_UART_TxData<=8'h55; end
        `STEP_01:
            if(Top_UART_TxDone) begin Top_UART_TxEn<=0; step_i<=step_i+1;  end
            else begin Top_UART_TxEn<=1; Top_UART_TxData<=8'hAA; end
        `STEP_02:
            if(Top_UART_TxDone) begin Top_UART_TxEn<=0; step_i<=step_i+1;  end
            else begin Top_UART_TxEn<=1; Top_UART_TxData<=8'h19; end
        `STEP_03:
            if(Top_UART_TxDone) begin Top_UART_TxEn<=0; step_i<=step_i+1;  end
            else begin Top_UART_TxEn<=1; Top_UART_TxData<=8'h87; end 
        `STEP_04:
            if(cnt==16'hFF-1) begin cnt<=0; step_i<=0; end
            else begin cnt<=cnt+1; end
        default:
            begin step_i<=`STEP_00; end
    endcase
end

endmodule

//Pinout for Yantai InfiRay Lite640 Image Sensor.
//Lite640-C256
// iRxD //C256-RxD,T13
// oTxD //C256-TxD,T12
// P1V8_SHDN //C256-D0,R16
// HSYNC //C256-D1,M14
// PCLK //C256-D3,M15
// VSYNC //C256-D4,N16
// P3V3_SHDN //C256-D7,J12
// DV5 //C256-D8,H13
// DV0 //C256-D9,H14
// DV7 //C256-D10,G13
// DV2 //C256-D11,G14
// DV3 //C256-D12,F15
// DV6 //C256-D13,F10
// DV1 //C256-VSYNC,E13
// DV4 //C256-HSYNC,E15
*/