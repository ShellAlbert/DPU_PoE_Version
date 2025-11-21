`timescale 1ns/1ps

module ZUART_Rx
#(parameter Freq_divider=25)
(
	input wire iClk,
	input wire iRst_N,

	//pull down iEn to start transmition until pulse done oDone was issued.
	input wire iEn,
	input wire iRxD,

	output reg oDataValid,
	output reg [7:0] oData
);

//100MHz/4MHz=25.
reg [7:0] cntBPS;
always @(posedge iClk or negedge iRst_N)
if(!iRst_N) begin cntBPS<=0; end
else begin cntBPS<=(iEn)?((cntBPS==Freq_divider-1)?(0):(cntBPS+1)):(0); end
//We sample data at middle position. 25/2=12.
wire rxPulse;
assign rxPulse=(cntBPS==12-1)?(1):(0);

//falling edge of RxD.
reg [1:0] RxD_Delay;
always @(posedge iClk or negedge iRst_N)
if(!iRst_N) begin RxD_Delay<=2'b00; end
else begin RxD_Delay[1]<=(iEn)?(RxD_Delay[0]):(0); RxD_Delay[0]<=(iEn)?(iRxD):(0); end

wire FallEdge_RxD;
assign FallEdge_RxD=(RxD_Delay[1] & !RxD_Delay[0]);

//Rx: start bit(1)+data bits(8)+stop bit(1)
reg [7:0] step_i;
reg [3:0] cnt_bits;
always @(posedge iClk or negedge iRst_N)
if(!iRst_N) begin step_i<=0; oData<=0; oDataValid<=0; cnt_bits<=0; end
else if(iEn) begin
				case(step_i)
					0: //start bit(1).
						if(FallEdge_RxD) begin step_i<=step_i+1; end
					1: //data bits(8). //LSB First.
						if(rxPulse) begin oData<={iRxD,oData[7:1]}; step_i<=step_i+1; end
					2: 
						if(cnt_bits==8) begin cnt_bits<=0; step_i<=step_i+1; end
						else begin cnt_bits<=cnt_bits+1; step_i<=step_i-1; end
					3: //stop bit(1).
						if(rxPulse) begin step_i<=step_i+1; end
					4:	//gap between two transfer.
						if(rxPulse) begin step_i<=step_i+1; end
					5: //done signal.
						begin oDataValid<=1; step_i<=step_i+1; end
					6: //done signal.
						begin oDataValid<=0; oData<=0; step_i<=0; end
					default:
						begin oDataValid<=0; step_i<=0; end
				endcase
			end
	else begin
			step_i<=0; oData<=0; oDataValid<=0; cnt_bits<=0; 
		end
endmodule