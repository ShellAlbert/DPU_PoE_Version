`include "ZPortableDefine.v"

//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZCAT25512(
    input wire iClk,
    input wire iClk90,
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
    output wire oSPI_SCK,
    output reg oSPI_SO,
    input wire iSPI_SI
);


//The maximum frequency of SPI clock is 5MHz.
//100MHz/5Mhz=20.
//100MHz/500KHz=200.
reg [7:0] cnt_tick;
reg clkSPI;
reg enClkSPI;
always @(negedge iClk or negedge iRstN)
if(!iRstN) begin cnt_tick<=0; clkSPI<=0; end
else begin
        if(iEn) begin 
                cnt_tick<=(cnt_tick==200-1)?(0):(cnt_tick+1);
                clkSPI<=(enClkSPI)?((cnt_tick==200-1)?(~clkSPI):(clkSPI)):(0);
        end
        else begin
                cnt_tick<=0; clkSPI<=0; 
        end
end
wire tickClk;
assign tickClk=(iEn && (cnt_tick==200-1))?(1):(0);
assign oSPI_SCK=clkSPI;

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
reg [7:0] Rx_DR;
always @(negedge iClk or negedge iRstN)
if(!iRstN) begin 
        step_i<=0; bit_shift<=0; Tx_DR<=0; 
        oSPI_CS<=1; oSPI_SO<=0; 
        oOpDone<=0;
end
else begin 
        if(iEn) begin
                case(iOpReq)
                2'b00: //2'b00: Write Flag.
                        case(step_i)
                        `STEP_00: //Enable ClkSPI for a while.
                                case({tickClk,bit_shift})
                                {1,8'hFF-1}: begin bit_shift<=0; enClkSPI<=0; step_i<=step_i+1; end
                                {1,8'hxx}: begin bit_shift<=bit_shift+1; enClkSPI<=1; end
                                endcase
                        `STEP_01: //Enable Write Operations.
                                if(tickClk) begin oSPI_CS<=0; Tx_DR<={8'd0,CMD_WREN}; step_i<=step_i+1; end
                        `STEP_02: //Prepare data.
                                if(tickClk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_02: //Device latches data in at rising edge.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_03: //Shift 8-bits OPCODE out.
                                if(tickClk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(iOpAddr):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_04: //End. 
                                if(tickClk) begin oSPI_CS<=1; oSPI_SO<=0; step_i<=step_i+1; end
                        `STEP_05: //Give more clocks to Device to finish internal operation.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_06:
                                if(tickClk) begin oSPI_SCK<=0; step_i<=step_i+1; end
                        `STEP_07: //CSN high time>=80ns.
                                if(tickClk) begin
                                        if(bit_shift==16-1) begin bit_shift<=0; step_i<=step_i+1; end
                                        else begin bit_shift<=bit_shift+1; step_i<=step_i-2; end
                                end
                        /////////////////////////////////////////////////////////////////////////////////////////
                        `STEP_08: //Write Data to Memory.
                                if(tickClk) begin oSPI_CS<=0; Tx_DR<={8'd0,CMD_WRITE}; step_i<=step_i+1; end
                        `STEP_09: //Prepare data.
                                if(tickClk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_10: //Device latches data in at rising edge.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_11: //Shift 8-bits OPCODE out.
                                if(tickClk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(iOpAddr):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end 
                        `STEP_12: //Prepare data.
                                if(tickClk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end
                        `STEP_13: //Device latches data in at rising edge.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_14: //Shift 16-bits ADDRESS out.
                                if(tickClk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==16-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==16-1)?({8'd0,iWrData}):(Tx_DR<<1);
                                        step_i<=(bit_shift==16-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_15: //Prepare data.
                                if(tickClk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_16: //Device latches data in at rising edge.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_17: //Shift 8-bits DATA out.
                                if(tickClk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end 
                        `STEP_18: //End.
                                if(tickClk) begin oSPI_CS<=1; step_i<=step_i+1; end
                        //CAUTION HERE!!!!
                        //After a successful byte/page write or status register write, the device goes into a write disable mode.
                        //The CS input must be set high after the proper number of clock cycles to start the internal write cycle.
                        //////////////////////////////////////////////////////////////////////////////////
                        `STEP_19: //Give more clocks to Device to finish internal operation then pull up CS to end.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_20:
                                if(tickClk) begin oSPI_SCK<=0; step_i<=step_i+1; end
                        `STEP_21: //CSN high time>=80ns.
                                if(tickClk) begin
                                        if(bit_shift==8'h1F-1) begin bit_shift<=0; step_i<=step_i+1; end
                                        else begin bit_shift<=bit_shift+1; step_i<=step_i-2; end
                                end
                        `STEP_22:
                                begin oOpDone<=1; step_i<=step_i+1; end
                        `STEP_23:
                                begin oOpDone<=0; step_i<=`STEP_00; end
                        endcase
                2'b01: //2'b01: Read Flag. 
                        case(step_i)
                        `STEP_00: //Read Data from Memory. 
                                if(tickClk) begin oSPI_CS<=0; Tx_DR<={8'd0,CMD_READ}; step_i<=step_i+1; end
                        `STEP_01: //Prepare data.
                                if(tickClk) begin oSPI_SO<=Tx_DR[7]; step_i<=step_i+1; end
                        `STEP_02: //Device latches data in at rising edge.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_03: //Shift 8-bits OPCODE out.
                                if(tickClk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==8-1)?(iOpAddr):(Tx_DR<<1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_04: //Prepare data.
                                if(tickClk) begin oSPI_SO<=Tx_DR[15]; step_i<=step_i+1; end
                        `STEP_05: //Device latches data in at rising edge.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_06: //Shift 16-bits ADDRESS out.
                                if(tickClk) begin 
                                        oSPI_SCK<=0; 
                                        bit_shift<=(bit_shift==16-1)?(0):(bit_shift+1);
                                        Tx_DR<=(bit_shift==16-1)?(0):(Tx_DR<<1);
                                        step_i<=(bit_shift==16-1)?(step_i+1):(step_i-2);
                                end
                        `STEP_07: //generate 8-clocks to latch data in.
                                if(tickClk) begin oSPI_SCK<=1; step_i<=step_i+1; end
                        `STEP_08:
                                if(tickClk) begin oSPI_SCK<=0; step_i<=step_i+1; end
                        `STEP_09: 
                                if(tickClk) begin 
                                        Rx_DR<={Rx_DR[6:0],iSPI_SI};
                                        bit_shift<=(bit_shift==8-1)?(0):(bit_shift+1);
                                        step_i<=(bit_shift==8-1)?(step_i+1):(step_i-2);
                                end 
                        `STEP_10://End.
                                if(tickClk) begin oSPI_CS<=1; step_i<=step_i+1; end
                        `STEP_11: //CSN high time>=80ns.
                                if(tickClk) begin
                                        if(bit_shift==8'h0F-1) begin bit_shift<=0; step_i<=step_i+1; end
                                        else begin bit_shift<=bit_shift+1; end
                                end
                        `STEP_12:
                                begin oOpDone<=1; step_i<=step_i+1; end
                        `STEP_13:
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
