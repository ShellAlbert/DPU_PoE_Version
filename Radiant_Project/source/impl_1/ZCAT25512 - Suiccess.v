`include "ZPortableDefine.v"

//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZCAT25512(
    input wire iClk,
    input wire iRstN,
    input wire iEn,

    //2'b00: Write Flag.
    //2'b01: Read Flag. 
    input wire[1:0] iOpReq,
    input wire [7:0] iWrData,
    input wire [15:0] iOpAddr,
    output reg [7:0] oRdData,
    output reg oOpDone,

    //EEPROM SPI Interface.
    output reg oSPI_CS,
    output reg oSPI_SCK,
    output reg oSPI_SO,
    input wire iSPI_SI
);


//The maximum frequency of SPI clock is 5MHz.
//100MHz/5Mhz=20.
//100MHz/4MHz=25.
//100MHz/500KHz=200.
reg [7:0] cnt_tick;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin cnt_tick<=0; end
else begin
        if(iEn) begin 
                cnt_tick<=(cnt_tick==50-1)?(0):(cnt_tick+1);
        end
        else begin
                cnt_tick<=0; 
        end
end
wire tick_Clk;
assign tick_Clk=(iEn && (cnt_tick==50-1))?(1):(0);

//Instruction Set.
localparam CMD_WREN=8'b0000_0110; //Enable Write Operations.
localparam CMD_WRDI=8'b0000_0100; //Disable Write Operations.
localparam CMD_RDSR=8'b0000_0101; //Read Status Register.
localparam CMD_WRSR=8'b0000_0001; //Write Status Register.
localparam CMD_READ=8'b0000_0011; //Read Data from Memory.
localparam CMD_WRITE=8'b0000_0010; //Write Data to Memory.

//driven by step_i.
reg [7:0] step_i;
reg [7:0] bit_shift;
reg [15:0] Tx_DR;
reg [15:0] Rx_DR;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
        step_i<=0; bit_shift<=0; Tx_DR<=0; 
        oSPI_CS<=1; oSPI_SO<=0; oSPI_SCK<=0; 
        oOpDone<=0; 
end
else begin 
        if(iEn) begin
                case(iOpReq)
                2'b00: //2'b00: Write Flag.
                        case(step_i)
                        `STEP_00: //Read Status Register to check RDY bit.
                                if(tick_Clk) begin oSPI_CS<=0; Tx_DR<={CMD_RDSR,8'd0}; Rx_DR<=0; step_i<=step_i+1; end
                        `STEP_01: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end    
                        `STEP_02:
                                if(tick_Clk) begin oSPI_SCK<=1; Rx_DR<={Rx_DR[14:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_03:
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==15-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==15-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==15-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_04:
                                if(tick_Clk) begin Rx_DR<={Rx_DR[14:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_05: //End.  //If RDY is 1 (internal writing is still ongoing), continue to polling.
                                if(tick_Clk) begin oSPI_CS<=1; step_i<=(!Rx_DR[0])?(step_i+1):(step_i-5); end
                        /////////////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_06: //Enable Write Operations.
                                if(tick_Clk) begin oSPI_CS<=0; Tx_DR<={8'd0,CMD_WREN}; step_i<=step_i+1; end
                        `STEP_07: //Prepare data.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_08: //Device latches data in at rising edge.
                                if(tick_Clk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_09: //Shift 8-bits OPCODE out.
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_10: //End. 
                                if(tick_Clk) begin oSPI_CS<=1; oSPI_SO<=0; Tx_DR<=0; step_i<=step_i+1; end
                        /////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_11: //Write Data to Memory.
                                if(tick_Clk) begin oSPI_CS<=0; Tx_DR<={8'd0,CMD_WRITE}; step_i<=step_i+1; end
                        `STEP_12: //Prepare data.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_13: //Device latches data in at rising edge.
                                if(tick_Clk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_14: //Shift 8-bits OPCODE out.
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(iOpAddr):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end 
                        `STEP_15: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end
                        `STEP_16: //Device latches data in at rising edge.
                                if(tick_Clk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_17: //Shift 16-bits ADDRESS out.
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==16-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==16-1)?({8'd0,iWrData}):(Tx_DR<<1);
                                        step_i<=(bit_shift==16-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_18: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_19: //Device latches data in at rising edge.
                                if(tick_Clk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_20: //Shift 8-bits DATA out.
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end 
                        `STEP_21: //End. //CSN high time>=80ns.
                                if(tick_Clk) begin oSPI_CS<=1; step_i<=step_i+1; end
                        ////////////////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_22: //Read Status Register to check RDY bit.
                                if(tick_Clk) begin oSPI_CS<=0; Tx_DR<={CMD_RDSR,8'd0}; Rx_DR<=0; step_i<=step_i+1; end
                        `STEP_23: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end    
                        `STEP_24:
                                if(tick_Clk) begin oSPI_SCK<=1; Rx_DR<={Rx_DR[14:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_25:
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0;  
                                        bit_shift<=(bit_shift==15-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==15-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==15-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_26:
                                if(tick_Clk) begin Rx_DR<={Rx_DR[14:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_27: //End.  //If RDY is 1 (internal writing is still ongoing), continue to polling.
                                if(tick_Clk) begin oSPI_CS<=1; step_i<=(!Rx_DR[0])?(step_i+1):(step_i-5); end
                        ////////////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_28:
                                begin oOpDone<=1; oLED<=0; step_i<=step_i+1; end
                        `STEP_29:
                                begin oOpDone<=0; step_i<=`STEP_00; end
                        endcase
                2'b01: //2'b01: Read Flag. 
                        case(step_i)
                        `STEP_00: //Read Status Register to check RDY bit.
                                if(tick_Clk) begin oSPI_CS<=0; Tx_DR<={CMD_RDSR,8'd0}; Rx_DR<=0; step_i<=step_i+1; end
                        `STEP_01: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end    
                        `STEP_02:
                                if(tick_Clk) begin oSPI_SCK<=1; Rx_DR<={Rx_DR[14:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_03:
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==15-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==15-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==15-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_04:
                                if(tick_Clk) begin Rx_DR<={Rx_DR[14:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_05: //End.  //If RDY is 1 (internal writing is still ongoing), continue to polling.
                                if(tick_Clk) begin oSPI_CS<=1; step_i<=(!Rx_DR[0])?(step_i+1):(step_i-4); end
                        ///////////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_06: //Read Data from Memory. 
                                if(tick_Clk) begin oSPI_CS<=0; Tx_DR<={8'd0,CMD_READ}; step_i<=step_i+1; end
                        `STEP_07: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_08: //Device latches data in at rising edge.
                                if(tick_Clk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_09: //Shift 8-bits OPCODE out.
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(iOpAddr):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_10: //MSB First.
                                if(tick_Clk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end
                        `STEP_11: //Device latches data in at rising edge.
                                if(tick_Clk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_12: //Shift 16-bits ADDRESS out.
                                if(tick_Clk) begin
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==16-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==16-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==16-1)?(step_i+1):(step_i-2);
                                        oRdData<=0;
                                end
                        `STEP_13: //generate 8-clocks to latch data in.
                                if(tick_Clk) begin oSPI_SCK<=1; oRdData<={oRdData[6:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_14: //Latch data in.
                                if(tick_Clk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==7-1)?(0):(bit_shift+1);
                                        step_i<=(bit_shift==7-1)?(step_i+1):(step_i-1);
                                end
                        `STEP_15:
                                if(tick_Clk) begin oRdData<={oRdData[6:0],iSPI_SI}; step_i<=step_i+1; end
                        `STEP_16://End.
                                if(tick_Clk) begin oSPI_CS<=1; step_i<=step_i+1; end
                        /////////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_17:
                                begin oOpDone<=1; step_i<=step_i+1; end
                        `STEP_18:
                                begin oOpDone<=0; step_i<=`STEP_00; end
                        endcase
                default:
                        begin step_i<=`STEP_00; end
                endcase
        end
        else begin 
                step_i<=0; oSPI_CS<=1; oSPI_SO<=0; oOpDone<=0; 
        end
end

endmodule
