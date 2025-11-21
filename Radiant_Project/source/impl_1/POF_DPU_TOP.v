`include "ZPortableDefine.v"

//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module POF_DPU_TOP(
    input wire iClk_25MHz,

    //////////HyperRAM-1#.
    output wire oH1_RSTN,
    output wire oH1_CSN,
    output wire oH1_CKP,
    //output wire oH1_CKN,
    inout wire ioH1_RWDS0,
    inout wire ioH1_RWDS1,
    inout wire[15:0] ioH1_D,

    //////////HyperRAM-2#.
    output wire oH2_RSTN,
    output wire oH2_CSN,
    output wire oH2_CKP,
    //output wire oH2_CKN,
    inout wire ioH2_RWDS0,
    inout wire ioH2_RWDS1,
    inout wire [15:0] ioH2_D,

    //////////Yantai InfiRay Infrared Image Sensor.
    input iIR_PCLK,
    input iIR_VSYNC,
    input iIR_HSYNC,
    input [13:0] iIR_Data,
    output oIR_PWR_EN,
    input iIR_UART_RX,
    output oIR_UART_TX,

    //////////OV5640 Image Sensor.
    input wire iDVP_PCLK,
    input wire iDVP_HSYNC,
    input wire iDVP_VSYNC,
    input wire [7:0] iDVP_D,

    output wire oDVP_SCL,
    inout wire ioDVP_SDA,

    output wire oDVP_RST,
    output wire oDVP_PWDN,


    //////////CAT25512 EEPROM.
    output wire oSPI_CS,
    output wire oSPI_SCK,
    output wire oSPI_SO,
    input wire iSPI_SI,

    //////////Debug LED*3.
    output wire oLED1,
    output wire oLED2,
    output wire oLED3,

    //////////W5500 Physical Pins.
    output wire oW5500_CSN, //SPI_CS.
    output wire oW5500_SCLK, //SPI_SCLK.
    output wire oW5500_MOSI, //SPI_MISO.
    input wire iW5500_MISO, //SPI_MISO.
    output wire oW5500_RSTN, //Reset.
    input wire iW5500_INTN, //Interrupt Signal.

    //////////Ultrasonic Sensor AD7988-5.
    output wire oAD7988_CNV,
    output wire oAD7988_SCK,
    output wire iAD7988_SDO,
    input wire oAD7988_SDI,
    output wire oAD7988_LED,


    //////////Debug UART.
    input wire iDBG_UART_RX,
    output wire oDBG_UART_TX
);
///////////////////////////////////////////////////////////////////////////////////////////////////
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

reg [31:0] cnt_led;
reg clk_flag;
always @(posedge clk_100MHz_i or negedge rst_n_i)
if(!rst_n_i) begin cnt_led<=0; clk_flag<=0; end
else begin
    if(cnt_led==32'h2faf080) begin cnt_led<=0; clk_flag<=~clk_flag; end
    else begin cnt_led<=cnt_led+1; end
end
assign oLED1=clk_flag;
assign oAD7988_LED=clk_flag;
///////////////////////////////////////////////////////////////////////////////////////////////////
//This UART is used to output debug information.
//It is shared by many modules, so a multiplexer is used here.
//100MHz/1MHz=100.
//100MHz/100KHz=1000.
wire enUART;
wire [7:0] txDataUART;
wire doneUART;
ZUART_Tx #(.Freq_divider(100)) myUART_Tx 
(
	.iClk(clk_100MHz_i),
	.iRstN(rst_n_long),
    .iEn(enUART),
	
	.iData(txDataUART),
	.oDone(doneUART),
	.oTxD(oDBG_UART_TX)
);

///////////////////////////////////////////////////////////////////////////////////////////////////
//Instance for W5500 Module.
ZW5500_Module myW5500(
    .iClk(clk_100MHz_i),
    .iRstN(rst_n_long),
    .iEn(1'b1),

    .oLED(oLED2),

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


assign oIR_PWR_EN=1; 
endmodule

