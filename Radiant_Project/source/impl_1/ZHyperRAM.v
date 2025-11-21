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

    //Read data from FIFO and write into Hyper RAM.
    output reg oRd_EnFIFO,
    input wire [15:0] iRd_DataFIFO,
    input wire iEmpty_FIFO,
    
    //OV5640_DVP Already write one frame into FIFO.
    input wire iWrFrm2FIFODone,
    //How many bytes OV5640_DVP wrote into FIFO.
    input wire [31:0] iWrFrmBytes,

    //Auxiliary Signals, routed to physical pins to measure how many clocks one block uses.
    output wire oClkUsed
);


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


reg wr_frame_done;
reg [31:0] WrFrmBytes;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin wr_frame_done<=0; end
else begin 
        if(iEn) begin 
                if(iWrFrm2FIFODone) begin wr_frame_done<=1; WrFrmBytes<=iWrFrmBytes; end
        end
        else begin wr_frame_done<=0; WrFrmBytes<=0; end
end

//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt_1; 
reg [31:0] rd_bytes;

always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt_1<=0; oSelfCheckDone<=0; oRd_EnFIFO<=0; oUART_Upload_Done<=0;
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
        `STEP_05: //[2:0]=3'b100, Write Memory, Address:0,1,2,3.
                if(OpDone_i) begin En_i<=0; step_i<=step_i+1; end
                else begin OpReq_i<=3'b100; En_i<=1; OpMemAddr_i<=0; OpMemData_i<={32'h19870901,32'h19861014,32'h20160323,32'h19571112}; end
        `STEP_06: //[2:0]=3'b100, Write Memory,Address:4,5,6,7.
                if(OpDone_i) begin En_i<=0; step_i<=step_i+1; end
                 else begin OpReq_i<=3'b100; En_i<=1; OpMemAddr_i<=4; OpMemData_i<={32'h20250901,32'h20251014,32'h20250323,32'h20251112}; end
        `STEP_07: //[2:0]=3'b011, Read Memory, Address:0,1,2,3.
                if(OpDone_i) begin En_i<=0; OpMemData_i<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b011; En_i<=1; OpMemAddr_i<=0; end
        `STEP_08: //UART Tx for Debug.
                if(cnt_1==16) begin cnt_1<=0; step_i<=step_i+1; end
                else begin
                    if(iTxDone) begin oTxEn<=0; OpMemData_i<=OpMemData_i<<8; cnt_1<=cnt_1+1; end
                    else begin oTxEn<=1; oTxData<=OpMemData_i[127:120]; end
                end 
        `STEP_09: //[2:0]=3'b011, Read Memory, Address:4,5,6,7.
                if(OpDone_i) begin En_i<=0; OpMemData_i<=OpRdData_i; step_i<=step_i+1; end
                else begin OpReq_i<=3'b011; En_i<=1; OpMemAddr_i<=4; end
        `STEP_10: //UART Tx for Debug.
                if(cnt_1==16) begin cnt_1<=0; step_i<=step_i+1; end
                else begin
                    if(iTxDone) begin oTxEn<=0; OpMemData_i<=OpMemData_i<<8; cnt_1<=cnt_1+1; end
                    else begin oTxEn<=1; oTxData<=OpMemData_i[127:120]; end
                end 
        `STEP_11:
                begin oSelfCheckDone<=1; step_i<=step_i+1; end
        `STEP_12: //Write from Address-0x0.
                begin oSelfCheckDone<=0; OpMemAddr_i<=0; rd_bytes<=0; step_i<=step_i+1; end
/////////////////////////////////////////////////////////////////////////////////////////////////////
        `STEP_13: //Fetch 128-bits/16-bits=8 data from FIFO write to Hyper RAM.
                if(!iEmpty_FIFO) begin oRd_EnFIFO<=1; step_i<=step_i+1; end
                else begin //exit flag detection.
                        if(wr_frame_done) begin step_i<=step_i+3; end
                end
        `STEP_14: //delay one clock to get data from FIFO.
                begin 
                        oRd_EnFIFO<=0; step_i<=step_i+1; 
                        case(rd_bytes)
                        0: begin OpMemData_i[127:112]<=iRd_DataFIFO; end
                        1: begin OpMemData_i[111:96]<=iRd_DataFIFO; end
                        2: begin OpMemData_i[95:80]<=iRd_DataFIFO; end
                        3: begin OpMemData_i[79:64]<=iRd_DataFIFO; end
                        4: begin OpMemData_i[63:48]<=iRd_DataFIFO; end
                        5:begin OpMemData_i[47:32]<=iRd_DataFIFO; end
                        6:begin OpMemData_i[31:16]<=iRd_DataFIFO; end
                        7:begin OpMemData_i[15:0]<=iRd_DataFIFO; end
                        endcase
                end
        `STEP_15: //Write info Memory.
                if(rd_bytes==8-1) begin 
                        //[2:0]=3'b100, Write Memory.
                        if(OpDone_i) begin 
                                En_i<=0; OpMemAddr_i<=OpMemAddr_i+4; rd_bytes<=0; 
                                //exit or continue?
                                step_i<=(wr_frame_done)?(step_i+1):(step_i-2);
                        end //128-bits/32-bits=4.
                        else begin OpReq_i<=3'b100; En_i<=1;  end
                end 
                else begin rd_bytes<=rd_bytes+1; step_i<=step_i-2; end //continue to fetch from FIFO.
        `STEP_16: 
                begin OpMemAddr_i<=0; rd_bytes<=0; step_i<=step_i+1; end            
        `STEP_17: //Read from HyperRAM and Tx out at a low speed(1Mbps).
                //[2:0]=3'b011, Read Memory.
                if(OpDone_i) begin En_i<=0; OpMemData_i<=OpRdData_i; OpMemAddr_i<=OpMemAddr_i+4; step_i<=step_i+1; end
                else begin OpReq_i<=3'b011; En_i<=1; end
        `STEP_18: //Tx Out. //128-bits/8-bits=16.
                begin 
                    if(cnt_1==16) begin cnt_1<=0; step_i<=step_i+1; end
                    else begin
                        if(iTxDone) begin oTxEn<=0; /*OpMemData_i<=OpMemData_i<<8;*/ cnt_1<=cnt_1+1; end
                        else begin 
                                oTxEn<=1; 
                                //oTxData<=OpMemData_i[127:120]; //Bugs Here!!!!!!!
                                case(cnt_1)
                                0: begin oTxData<=OpMemData_i[127:120]; end
                                1: begin oTxData<=OpMemData_i[119:112]; end
                                2: begin oTxData<=OpMemData_i[111:104]; end
                                3: begin oTxData<=OpMemData_i[103:96]; end
                                4: begin oTxData<=OpMemData_i[95:88]; end
                                5: begin oTxData<=OpMemData_i[87:80]; end
                                6: begin oTxData<=OpMemData_i[79:72]; end
                                7: begin oTxData<=OpMemData_i[71:64]; end
                                8: begin oTxData<=OpMemData_i[63:56]; end
                                9: begin oTxData<=OpMemData_i[55:48]; end
                                10:begin oTxData<=OpMemData_i[47:40]; end
                                11:begin oTxData<=OpMemData_i[39:32]; end
                                12:begin oTxData<=OpMemData_i[31:24]; end
                                13:begin oTxData<=OpMemData_i[23:16]; end
                                14:begin oTxData<=OpMemData_i[15:8]; end
                                15:begin oTxData<=OpMemData_i[7:0]; end
                                endcase
                        end
                    end 
                end
                // begin step_i<=step_i+1; end
        `STEP_19: //Repeat or Exit.
                if(rd_bytes>=WrFrmBytes) begin rd_bytes<=0; step_i<=step_i+1; end
                else begin rd_bytes<=rd_bytes+16; step_i<=step_i-2; end
        `STEP_20:
                begin oUART_Upload_Done<=1; step_i<=step_i+1; end
        `STEP_21:
                begin oUART_Upload_Done<=0; step_i<=`STEP_00; end
        default:
                begin step_i<=`STEP_00; end
        endcase
    end
end

endmodule