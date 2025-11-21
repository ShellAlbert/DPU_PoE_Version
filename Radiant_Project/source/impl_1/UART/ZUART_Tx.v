`timescale 1ns/1ps
`include "ZPortableDefine.v"

module ZUART_Tx #(parameter Freq_divider=50)
(
	input wire iClk,
	input wire iRstN,
	input wire iEn,

	input wire [7:0] iData,
	output reg oDone,
	output reg oTxD
);

//generate 1MHz Clock. //48MHz/1MHz=48.
//generate 2MHz Clock. //48MHz/2M=24.
//generate 4MHz Clock, //48MHz/4MHz=12.
//generate 115200bps, 48MHz/115200bps=416.7

//We expect a 100MHz PLL output, but the report gives out the maximum frequency is 51MHz.
//Single Clock Domain
//-------------------------------------------------------------------------------------------------------
//	Clock clk_100MHz            |                    |       Period       |     Frequency      
//-------------------------------------------------------------------------------------------------------
//	 From clk_100MHz                        |             Target |          10.000 ns |        100.002 MHz 
//											| Actual (all paths) |          19.442 ns |         51.435 MHz 
//100MHz/2MHz=5.
//51.435MHz/2MHz=25.7175
reg [15:0] cnt_bps;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin cnt_bps<=0; end
else if(iEn) begin 
				if(cnt_bps==Freq_divider-1) begin cnt_bps<=0; end
				else begin cnt_bps<=cnt_bps+1; end
			end
	else begin //if(iEn)
		cnt_bps<=0;
	end

wire tick_pulse;
assign tick_pulse=(cnt_bps==Freq_divider-1)?(1):(0);

//Tx: start bit(1)+data bits(8)+stop bit(1)
//Tx Idle is High.
//Pull Low to start transfer, start bit is Low.
//8 bits data. (Bit0~Bit7, LSB First.)
//1 Stop bit is High.
reg [7:0] step_i;
reg [8:0] bit_shift;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
	oTxD<=1; //Idle is High.
	oDone<=0; step_i<=0; bit_shift<=0;
end
else if(iEn) begin
				case(step_i)
				`STEP_00: //start bit(1).
					if(tick_pulse) begin oTxD<=0; step_i<=step_i+1; end
				`STEP_01: //data bits(8). //LSB First.
					if(tick_pulse) begin oTxD<=iData[bit_shift]; step_i<=step_i+1; end
				`STEP_02: 
					if(bit_shift==7) begin bit_shift<=0; step_i<=step_i+1; end
					else begin bit_shift<=bit_shift+1; step_i<=step_i-1; end
				`STEP_03: //stop bit(1).
					if(tick_pulse) begin oTxD<=1; step_i<=step_i+1; end
				`STEP_04:	//gap between two transfer.
					if(tick_pulse) begin step_i<=step_i+1; end
				`STEP_05: //done signal.
					begin oDone<=1; step_i<=step_i+1; end
				`STEP_06: //done signal.
					begin oDone<=0; step_i<=0; end
				default:
						begin oTxD<=1; oDone<=0; step_i<=0; end
				endcase
			end
	else begin
			oTxD<=1; oDone<=0; step_i<=0;
		end
endmodule