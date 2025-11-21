`include "ZPortableDefine.v"

module ZW5500_SPI(
    input wire iClk,
    input wire iRstN,
    input wire iEn,

    //[1:0]=2'b00, Read/Write Register.
    //[1:0]=2'b01, Variable Length Read/Write.
    input wire [1:0] iOpReq,
    input wire [15:0] iAddrPhase,
    input wire [7:0] iCtrlPhase,
    input wire [7:0] iDataPhase,
    output reg [7:0] oDataPhase,
    output reg oOpDone,

    //In Variable Length Data Mode.
    //iVDMByte[7:0] indicates how many bytes could be written. 
    //update iDataPhase[7:0] once oVDMDone is valid.
    input wire [7:0] iVDMByte,
    output reg oVDMDone,
    
    //W5500 Physical Pins.
    output reg oW5500_CSN,
    output reg oW5500_SCLK,
    output reg oW5500_MOSI,
    input wire iW5500_MISO
);


//combine one complete SPI frame.
wire [31:0] SPIFrame_Tx;
assign SPIFrame_Tx={iAddrPhase,iCtrlPhase,iDataPhase};
reg [31:0] SPIFrame_Rx;

//driven by step_i.
reg [7:0] step_i;
reg [4:0] bit_shift; //2^5=32.
reg [7:0] cnt_1;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; bit_shift<=0; cnt_1<=0; oVDMDone<=0; oDataPhase<=0; oOpDone<=0; 
    oW5500_CSN<=1; oW5500_SCLK<=0; oW5500_MOSI<=0; 
end
else begin 
        if(iEn) begin
            case(iOpReq)
            2'b00: //[1:0]=2'b00, Read/Write Register.
                case(step_i)
                `STEP_00: //pull down CSN to start.
                    begin oW5500_CSN<=0; oW5500_SCLK<=0; bit_shift<=(32-1); SPIFrame_Rx<=0; step_i<=step_i+1; end
                `STEP_01: //W5500 latches data on the rising edge.
                    begin oW5500_MOSI<=SPIFrame_Tx[bit_shift]; step_i<=step_i+1; end
                `STEP_02: //Rising Edge.
                    begin oW5500_SCLK<=1; step_i<=step_i+1; end
                `STEP_03: //50% duty cycle.
                    begin step_i<=step_i+1; end
                `STEP_04: //Falling Edge.
                    begin oW5500_SCLK<=0; step_i<=step_i+1; end
                `STEP_05: //W5500 outputs data on the falling edge.
                    begin SPIFrame_Rx[bit_shift]<=iW5500_MISO; step_i<=step_i+1; end
                `STEP_06:
                    if(bit_shift==0) begin bit_shift<=0; step_i<=step_i+1; end
                    else begin bit_shift<=bit_shift-1; step_i<=step_i-5; end
                `STEP_07: //pull up CSN to end.
                    begin oW5500_CSN<=1; step_i<=step_i+1; end
                `STEP_08:
                    begin oOpDone<=1; oDataPhase<=SPIFrame_Rx[7:0]; step_i<=step_i+1; end
                `STEP_09:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                endcase
            2'b01: //[1:0]=2'b01, Variable Length Read/Write.
                case(step_i)
                `STEP_00: //pull down CSN to start. //Address-Phase+Control-Phase=16bits+8bits=24bits.
                    begin oW5500_CSN<=0; oW5500_SCLK<=0; bit_shift<=(32-1); SPIFrame_Rx<=0; step_i<=step_i+1; end
                `STEP_01: //W5500 latches data on the rising edge.
                    begin oW5500_MOSI<=SPIFrame_Tx[bit_shift]; step_i<=step_i+1; end
                `STEP_02: //Rising Edge.
                    begin oW5500_SCLK<=1; step_i<=step_i+1; end
                `STEP_03: //50% duty cycle.
                    begin step_i<=step_i+1; end
                `STEP_04: //Falling Edge.
                    begin oW5500_SCLK<=0; step_i<=step_i+1; end
                `STEP_05: //W5500 outputs data on the falling edge.
                    begin SPIFrame_Rx[bit_shift]<=iW5500_MISO; step_i<=step_i+1; end
                `STEP_06:
                    if(bit_shift==8) begin bit_shift<=(8-1); step_i<=step_i+1; end
                    else begin bit_shift<=bit_shift-1; step_i<=step_i-5; end
                ////////////////////////////////////////////////////////////////////////////////////////////////////////
                ////////// Data-Phase.
                `STEP_07: //W5500 latches data on the rising edge.
                    begin oW5500_MOSI<=iDataPhase[bit_shift]; step_i<=step_i+1; end
                `STEP_08: //Rising Edge.
                    begin oW5500_SCLK<=1; step_i<=step_i+1; end
                `STEP_09: //50% duty cycle.
                    begin step_i<=step_i+1; end
                `STEP_10: //Falling Edge.
                    begin oW5500_SCLK<=0; step_i<=step_i+1; end
                `STEP_11: //W5500 outputs data on the falling edge.
                    begin
                        oDataPhase[bit_shift]<=iW5500_MISO;
                        //////////////////////////////////////////////////////////////////////////////
                        if(bit_shift==0) begin bit_shift<=(8-1); oVDMDone<=1; step_i<=step_i+1; end
                        else begin bit_shift<=bit_shift-1; step_i<=step_i-4; end
                    end
                `STEP_12: //Additional one clock for caller to update iDataPhase.
                    begin oVDMDone<=0; step_i<=step_i+1; end
                `STEP_13:
                    if(cnt_1==(iVDMByte-1)) begin cnt_1<=0; step_i<=step_i+1; end
                    else begin cnt_1<=cnt_1+1; step_i<=step_i-6; end
                `STEP_14: //pull up CSN to end.
                    begin oW5500_CSN<=1; step_i<=step_i+1; end
                `STEP_15:
                    begin oOpDone<=1; step_i<=step_i+1; end
                `STEP_16:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                endcase
            default:
                begin oOpDone<=0; step_i<=`STEP_00; end
            endcase
        end
        else begin //if(iEn)
            step_i<=0; cnt_1<=0; oOpDone<=0; step_i<=`STEP_00; 
        end
end
endmodule