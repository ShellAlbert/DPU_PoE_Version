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

    //VersionID*2.
    input [1:0] iVersion_ID,
    //Debug LED*3.
    output reg oLED1,
    output reg oLED2,
    output reg oLED3,

    //UART UPLOAD IF.
    input iDPU_RX,
    output reg oDPU_TX,

    output reg oLD_PWR_EN,
    output reg oIAM_ALIVE,
    output reg oIO_P5V0_SHDN,

    //Laser Diode.
    output oTX_EN,
    output oUART_T_LD,
    output oUART_T,

    //Aux.
    output reg [7:0] oIO,

    output oClkUsed
);



//On-board Oscillator 25.0MHz -> PLL -> 100.0MHz (Phase Shift Degree 0)
//                                   -> 100.0MHz (Phase Shift Degree 90)
wire clk_100MHz_i;
wire clk_100MHz_Shift90_i;
wire rst_n_i;
ZPLL myPLL(
    .clki_i(iClk_25MHz),
    .clkop_o(clk_100MHz_i),
    .clkos_o(clk_100MHz_Shift90_i),
    .lock_o(rst_n_i));

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
//Dual Port (Dual Clock) FIFO connects ZOV5640_DVP and ZHyperRAM.
//65536-depth*8-bits.
//Write Port.
wire clk_WrFIFO;
wire wr_EnFIFO;
wire [7:0] wr_DataFIFO;
wire full_FIFO;
//Read Port.
wire clk_RdFIFO;
wire rd_EnFIFO;
wire [127:0] rd_DataFIFO;
wire empty_FIFO;
reg rstFIFO;
ZFIFO_DC myFIFO_DC(
        .wr_clk_i(clk_WrFIFO),
        .rd_clk_i(clk_RdFIFO),
        .rst_i(rstFIFO),
        .rp_rst_i(rstFIFO),
        .wr_en_i(wr_EnFIFO),
        .rd_en_i(rd_EnFIFO),
        .wr_data_i(wr_DataFIFO),
        .full_o(full_FIFO),
        .empty_o(empty_FIFO),
        .rd_data_o(rd_DataFIFO));


////////////////////////////////////////////////////////
//Configure OV5640 to JPEG mode.
reg enOV5640Cfg_i;
wire OV5640CfgDone_i;
wire Cfg_UART_TxEn_i;
wire [7:0] Cfg_UART_TxData_i;
reg Cfg_UART_TxDone_i;
ZOV5640_Cfg myOV5640_Cfg(
    .iClk(clk_100MHz_i),
    .iRstN(rst_n_i),
    .iEn(enOV5640Cfg_i),
    .oCfgDone(OV5640CfgDone_i),

    //DVP SCCB Interface.
    .oDVP_SCL(oDVP_SCL),
    .ioDVP_SDA(ioDVP_SDA),

    .oDVP_RST(oDVP_RST),
    .oDVP_PWDN(oDVP_PWDN),

    //Debug UART.
    .oTxEn(Cfg_UART_TxEn_i),
    .oTxData(Cfg_UART_TxData_i),
    .iTxDone(Cfg_UART_TxDone_i)
);
////////////////////////////////////////////////////////////////////////////
reg enDVP_i;
wire wrFrm2FIFODone;
wire [31:0] wrFrmBytes;
ZOV5640_DVP myOV5640_DVP(
    .iClk(clk_100MHz_i), //100MHz.
    .iRstN(rst_n_i),
    .iEn(enDVP_i),

    //OV5640 Image Sensor.
    .iDVP_PCLK(iDVP_PCLK), //24MHz,12MHz.
    .iDVP_HSYNC(iDVP_HSYNC),
    .iDVP_VSYNC(iDVP_VSYNC),
    .iDVP_D(iDVP_D),


    //Dual-Port FIFO, Write Port.
    .iFull_FIFO(full_FIFO),
    .oWrClk(clk_WrFIFO),
    .oWrEn(wr_EnFIFO),
    .oWrData(wr_DataFIFO),

    //Already write one frame into FIFO.
    .oWrFrmDone(wrFrm2FIFODone),
    //How many bytes were written into FIFO.
    .oWrFrmBytes(wrFrmBytes)
);

///////////////////////////////////////////////////////
reg en_HRAM_i;
wire HRAM_UART_TxEn_i;
wire [7:0] HRAM_UART_TxData_i;
wire UART_Upload_Done;
reg HRAM_UART_TxDone_i;
wire HRAM_SelfCheckDone_i;
ZHyperRAM myHyperRAM(
    .iClk(clk_100MHz_i),
    .iClkShift90(clk_100MHz_Shift90_i),
    .iEn(en_HRAM_i),
    .iRstN(rst_n_i),

    //HyperRAM Interface.
    .oRSTN(oH1_RSTN),
    .oCSN(oH1_CSN),
    .oCKP(oH1_CKP),
    //output oCKN,
    .ioRWDS0(ioH1_RWDS0),
    .ioRWDS1(ioH1_RWDS1),
    .ioDQ(ioH1_D),

    //Debug UART.
    .oTxEn(HRAM_UART_TxEn_i),
    .oTxData(HRAM_UART_TxData_i),
    .iTxDone(HRAM_UART_TxDone_i),
    //UART Tx Done.
    .oUART_Upload_Done(UART_Upload_Done),

    //Self Check Done. Read data equals to written data.
    .oSelfCheckDone(HRAM_SelfCheckDone_i),

    //Dual-Port, Dual Clock, FIFO.
    //Read data from FIFO and write into Hyper RAM.
    .oClk_RdFIFO(clk_RdFIFO),
    .oRd_EnFIFO(rd_EnFIFO),
    .iRd_DataFIFO(rd_DataFIFO),
    .iEmpty_FIFO(empty_FIFO),

    //OV5640_DVP Already write one frame into FIFO.
    .iWrFrm2FIFODone(wrFrm2FIFODone),
    //How many bytes OV5640_DVP wrote into FIFO.
    .iWrFrmBytes(wrFrmBytes),
    //Auxiliary Signals, routed to physical pins to measure how many clocks one block uses.
    .oClkUsed(oClkUsed)
);

/////////////////////////////////////////////////////////////////////////////////////////////////
//This UART is used to output debug information.
//It is shared by many modules, so a multiplexer is used here.
//It outputs data at UART_T_LD pin.
//TX_EN pin must be driven to HIGH.
assign oTX_EN=1;
//100MHz/1MHz=100.
reg tx_en_i;
reg [7:0] tx_data_i;
wire tx_done_i;
ZUART_Tx #(.Freq_divider(100)) myUART_Tx 
(
	.iClk(clk_100MHz_i),
	.iRst_N(rst_n_i),
	.iData(tx_data_i),
	
	//pull down iEn to start transmition until pulse done oDone was issued.
	.iEn(tx_en_i),
	.oDone(tx_done_i),
	.oTxD(oUART_T_LD)
);
/////////////////////////////////////////////////////////////////////////////////////////////////
//Multiplex for UART.
reg [7:0] UART_MUX;
always @(UART_MUX)
begin 
    case(UART_MUX)
    0: //OV5640 SCCB Configure.
        begin tx_en_i=Cfg_UART_TxEn_i; tx_data_i=Cfg_UART_TxData_i; Cfg_UART_TxDone_i=tx_done_i; end
    1: //Hyper RAM.
        begin tx_en_i=HRAM_UART_TxEn_i; tx_data_i=HRAM_UART_TxData_i; HRAM_UART_TxDone_i=tx_done_i; end
    2: //OV5640 DVP.
        begin tx_en_i=HRAM_UART_TxEn_i; tx_data_i=HRAM_UART_TxData_i; HRAM_UART_TxDone_i=tx_done_i; end
    default:
        begin tx_en_i=HRAM_UART_TxEn_i; tx_data_i=HRAM_UART_TxData_i; HRAM_UART_TxDone_i=tx_done_i; end
    endcase
end
/////////////////////////////////////////////////////////////////////////////////////////////////
//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt_i; 
always @(posedge clk_100MHz_i or negedge rst_n_i)
if(!rst_n_i) begin
    step_i<=0; cnt_i<=0; oLED1<=0; oLED2<=0; oLED3<=0; UART_MUX<=0; rstFIFO<=0; 
end
else begin
    case(step_i)
        `STEP_00: //Waiting for hardware stability.
            if(cnt_i==32768-1) begin cnt_i<=0; rstFIFO<=0; step_i<=step_i+1; end
            else begin rstFIFO<=1; cnt_i<=cnt_i+1; end
        `STEP_01: //Configure OV5640 First.
            if(OV5640CfgDone_i) begin enOV5640Cfg_i<=0; step_i<=step_i+1; end
            else begin enOV5640Cfg_i<=1; UART_MUX<=0; end
        `STEP_02: //Start Hyper-RAM.
            //HyperRAM compares written data and read back data to finish self-checking.
            if(HRAM_SelfCheckDone_i) begin oLED1<=1; step_i<=step_i+1; end
            else begin en_HRAM_i<=1; UART_MUX<=1; end
        `STEP_03: //Launch Once DVP Capture.
            if(wrFrm2FIFODone) begin /*enDVP_i<=0;*/ oLED2<=1; step_i<=step_i+1; end
            else begin enDVP_i<=1; end
        `STEP_04: //UART_Upload_Done means One Frame Transmit Finished.
            if(UART_Upload_Done) begin en_HRAM_i<=0; enDVP_i<=0; step_i<=step_i+1; end
        `STEP_05: //Stop Here.
            begin oLED3<=1; step_i<=step_i; end
        default:
            begin step_i<=`STEP_00; end
    endcase
end

endmodule