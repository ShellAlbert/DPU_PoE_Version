`include "ZPortableDefine.v"
//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZHyperRAM(
    input iClk,
    input iClkShift90,
    input iEn,
    input iRstN,

    //HyperRAM Interface.
    output oRSTN,
    output oCSN,
    output oCKP,
    //output oCKN,
    inout ioRWDS0,
    inout ioRWDS1,
    inout [15:0] ioDQ,

    //Debug UART.
    output reg oTxEn,
    output reg [7:0] oTxData,
    input wire iTxDone,
    //UART Tx Done.
    output reg oUART_Upload_Done,

    //Self Check Done. Read data equals to written data.
    output reg oSelfCheckDone,

    //Dual-Port, Dual Clock, FIFO.
    //Read data from FIFO and write into Hyper RAM.
    output wire oClk_RdFIFO,
    output reg oRd_EnFIFO,
    input wire [127:0] iRd_DataFIFO,
    input wire iEmpty_FIFO,
    
    //OV5640_DVP Already write one frame into FIFO.
    input wire iWrFrm2FIFODone,
    //How many bytes OV5640_DVP wrote into FIFO.
    input wire [31:0] iWrFrmBytes,

    //Auxiliary Signals, routed to physical pins to measure how many clocks one block uses.
    output wire oClkUsed
);

assign oClk_RdFIFO=iClk;
// assign oRd_EnFIFO=(iEn && (!iEmpty_FIFO))?(1):(0);
///////////////////////////
reg En_i;
reg [2:0] OpReq_i;
reg [22:0] OpMemAddr_i;
reg [127:0] OpMemData_i;
wire [127:0] OpRdData_i;
wire OpDone_i;
ZW958D6NBKX hyperRAM_W958D6NBKX(
    .iClk(iClk),
    .iClkShift90(iClkShift90),
    .iEn(En_i),
    .iRstN(iRstN),

    //Operation Request.
    //[2:0]=3'b000, Hardware Reset.
    //[2:0]=3'b001, Read Registers.
    //[2:0]=3'b010, Write Registers.
    //[2:0]=3'b011, Read Memory.
    //[2:0]=3'b100, Write Memory.
    .iOpReq(OpReq_i),
    .iOpMemAddr(OpMemAddr_i), //Memory Space Address. 
    .iOpMemData(OpMemData_i), //Memory Write Data.(16-bits Rising Edge + 16-bits Falling Edge).
    .oRdData(OpRdData_i),
    .oOpDone(OpDone_i),

    //HyperRAM Interface.
    .oRSTN(oRSTN),
    .oCSN(oCSN),
    .oCKP(oCKP),
    //output oCKN,
    .ioRWDS0(ioRWDS0),
    .ioRWDS1(ioRWDS1),
    .ioDQ(ioDQ),

    .oClkUsed(oClkUsed)
);


//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt_1; 
reg [31:0] rd_bytes;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt_1<=0; oSelfCheckDone<=0; oRd_EnFIFO<=0;
end
else begin
    if(iEn) begin
        case(step_i)
        `STEP_00: //100uS after POR.
                if(cnt_1==32768-1) begin cnt_1<=0; step_i<=step_i+1; end
                else begin cnt_1<=cnt_1+1; end
        `STEP_01: //[2:0]=3'b000, Hardware Reset.
                if(OpDone_i) begin En_i<=0; step_i<=step_i+1; end
                else begin OpReq_i<=3'b000; En_i<=1; end
        `STEP_02: //[2:0]=3'b010, Write Registers.
                if(OpDone_i) begin En_i<=0; step_i<=step_i+1; end
                else begin OpReq_i<=3'b010; En_i<=1; end
        `STEP_03: //[2:0]=3'b001, Read Registers.
                if(OpDone_i) begin En_i<=0; OpMemData_i<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b001; En_i<=1; end
        `STEP_04: //UART Tx for Debug, Default Value=0x0E76            
                if(cnt_1==2) begin cnt_1<=0; step_i<=step_i+1; end
                else begin
                    if(iTxDone) begin oTxEn<=0; OpMemData_i<=OpMemData_i<<8; cnt_1<=cnt_1+1; end
                    else begin oTxEn<=1; oTxData<=OpMemData_i[15:8]; end
                end
        `STEP_05: //[2:0]=3'b100, Write Memory.
                if(OpDone_i) begin En_i<=0; step_i<=step_i+1; end
                else begin OpReq_i<=3'b100; En_i<=1; OpMemAddr_i<=0; OpMemData_i<={32'h19870901,32'h19861014,32'h20160323,32'h19571112}; end
        `STEP_06: //[2:0]=3'b011, Read Memory.
                if(OpDone_i) begin En_i<=0; OpMemData_i<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b011; En_i<=1; OpMemAddr_i<=0; end
        `STEP_07: //UART Tx for Debug.
                if(cnt_1==16) begin cnt_1<=0; step_i<=step_i+1; end
                else begin
                    if(iTxDone) begin oTxEn<=0; OpMemData_i<=OpMemData_i<<8; cnt_1<=cnt_1+1; end
                    else begin oTxEn<=1; oTxData<=OpMemData_i[127:120]; end
                end 
                //debug, read memory continuously.
                //begin step_i<=step_i-2; end
        `STEP_08:
                begin oSelfCheckDone<=1; step_i<=step_i+1; end
        `STEP_09: //Write from Address-0x0.
                begin oSelfCheckDone<=0; OpMemAddr_i<=0; step_i<=step_i+1; end
/////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_10: //Fetch 16*8-bits data from FIFO write to Hyper RAM.
                if(!iEmpty_FIFO) begin oRd_EnFIFO<=1; OpMemData_i<=iRd_DataFIFO; step_i<=step_i+1; end
                else begin 
                        if(iWrFrm2FIFODone) begin step_i<=step_i+2; end
                        else begin oRd_EnFIFO<=0; end
                end
        `STEP_11: //[2:0]=3'b100, Write Memory.
                begin //128-bits/16-bits=8.
                        oRd_EnFIFO<=0; 
                        if(OpDone_i) begin En_i<=0; OpMemAddr_i<=OpMemAddr_i+8; step_i<=step_i-1; end
                        else begin OpReq_i<=3'b100; En_i<=1;  end
                end
        `STEP_12: //Read from HyperRAM and Tx out at a low speed(1Mbps).
                //[2:0]=3'b011, Read Memory.
                if(OpDone_i) begin En_i<=0; OpMemData_i<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b011; En_i<=1; OpMemAddr_i<=0; end
        `STEP_13:
                begin 
                    if(cnt_1==16) begin cnt_1<=0; step_i<=step_i+1; end
                    else begin
                        if(iTxDone) begin oTxEn<=0; OpMemData_i<=OpMemData_i<<8; cnt_1<=cnt_1+1; end
                        else begin oTxEn<=1; oTxData<=OpMemData_i[127:120]; end
                    end 
                end
        `STEP_14: //Repeat or Exit.
                if(rd_bytes==iWrFrmBytes) begin rd_bytes<=0; step_i<=step_i+1; end
                else begin rd_bytes<=rd_bytes+16; step_i<=step_i-2; end     
        `STEP_15: //UART_Upload_Done keeps HIGH always. Stop Here.
                begin oUART_Upload_Done<=1; step_i<=step_i; end
        default:
                begin step_i<=`STEP_00; end
        endcase
    end
end

endmodule