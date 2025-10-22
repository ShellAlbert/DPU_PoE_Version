`timescale 1ps/1ps
`include "ZPortableDefine.v"
module ZOV5640_DVP(
    input iClk, //100MHz.
    input iRstN,
    input iEn,

    //OV5640 Image Sensor.
    input wire iDVP_PCLK, //24MHz.
    input wire iDVP_HSYNC,
    input wire iDVP_VSYNC,
    input wire [7:0] iDVP_D,


    //Dual-Port FIFO, Write Port.
    input wire iFull_FIFO,
    output wire oWrClk,
    output wire oWrEn,
    output wire [7:0] oWrData,

    //Already write one frame into FIFO.
    output reg oWrFrmDone,
    //How many bytes were written into FIFO.
    output reg [31:0] oWrFrmBytes /*synthesis syn_preserve=1*/
);

// wire clk_selected;
// wire clk_buffered;
// PLLREFCS myPLLREFCS(
//   .CLK0     (iDVP_PCLK),  // I
//   .CLK1     (1'b0),  // I
//   .SEL      (1'b1),  // I
//   .PLLCSOUT (clk_selected)   // O
// );
// EHXPLLL myEHXPLLL
// (
// 	.CLKI(clk_selected),
// 	.CLKOP(clk_buffered),
// 	.ENCLKOP(1'b1),
// 	.RST(1'b0),
// 	.CLKFB(1'b0),
// 	.PHASESEL0(2'b00),
// 	.PHASEDIR(1'b0),
// 	.PHASESTEP(1'b0),
// 	.STDBY(1'b0)
// );
// defparam myEHXPLLL.CLKI_DIV=1;
// defparam myEHXPLLL.CLKOP_DIV=1;
// defparam myEHXPLLL.CLKFB_DIV=1;
// defparam myEHXPLLL.CLKOP_CPHASE=0;
// defparam myEHXPLLL.FEEDBK_PATH="INTERNAL";

///////////////////////////////////////////////////////
//Since iDVP_PCLK is not assigned to a clock pin in schematic. 
//So here I try to replicate a new clock equals to iDVP_PCLK.
reg [1:0] DVP_PCLK_Delay;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    DVP_PCLK_Delay<=2'b00;
end
else begin
    if(1/*iEn*/) begin 
        DVP_PCLK_Delay[0]<=iDVP_PCLK;
        DVP_PCLK_Delay[1]<=DVP_PCLK_Delay[0];
    end
    else begin 
        DVP_PCLK_Delay<=2'b00;
    end
end
wire DVP_PCLK_Falling;
assign DVP_PCLK_Falling=(DVP_PCLK_Delay[1] && !DVP_PCLK_Delay[0]);
wire DVP_PCLK_Rising;
assign DVP_PCLK_Rising=(!DVP_PCLK_Delay[1] && DVP_PCLK_Delay[0]);

reg PCLK_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    PCLK_i<=0;
end
else begin
    if(1/*iEn*/) begin
        if(DVP_PCLK_Rising) begin PCLK_i<=1; end
        else if(DVP_PCLK_Falling) begin PCLK_i<=0; end
        else begin PCLK_i<=PCLK_i; end
    end
    else begin 
        PCLK_i<=0;
    end
end

///////////////////////////////////////////////////////
//Rising and Falling Edge Detection. 
//Edge Synced to System Clock.
reg [1:0] DVP_VSYNC_Delay;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    DVP_VSYNC_Delay<=2'b00;
end
else begin
    if(iEn) begin 
        DVP_VSYNC_Delay[0]<=iDVP_VSYNC;
        DVP_VSYNC_Delay[1]<=DVP_VSYNC_Delay[0];
    end
    else begin 
        DVP_VSYNC_Delay<=2'b00;
    end
end
wire DVP_VSYNC_Falling;
assign DVP_VSYNC_Falling=(DVP_VSYNC_Delay[1] && !DVP_VSYNC_Delay[0]);
wire DVP_VSYNC_Rising;
assign DVP_VSYNC_Rising=(!DVP_VSYNC_Delay[1] && DVP_VSYNC_Delay[0]);

reg VSYNC_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    VSYNC_i<=0;
end
else begin
    if(iEn) begin
        if(DVP_VSYNC_Rising) begin VSYNC_i<=1; end
        else if(DVP_VSYNC_Falling) begin VSYNC_i<=0; end
        else begin VSYNC_i<=VSYNC_i; end
    end
    else begin 
        VSYNC_i<=0;
    end
end

///////////////////////////////////////////////////////
//Rising and Falling Edge Detection. 
//Edge Synced to System Clock.
reg [1:0] DVP_HSYNC_Delay;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    DVP_HSYNC_Delay<=2'b00;
end
else begin
    if(1/*iEn*/) begin 
        DVP_HSYNC_Delay[0]<=iDVP_HSYNC;
        DVP_HSYNC_Delay[1]<=DVP_HSYNC_Delay[0];
    end
    else begin
        DVP_HSYNC_Delay<=2'b00;
    end
end
wire DVP_HSYNC_Falling;
assign DVP_HSYNC_Falling=(DVP_HSYNC_Delay[1] && !DVP_HSYNC_Delay[0]);
wire DVP_HSYNC_Rising;
assign DVP_HSYNC_Rising=(!DVP_HSYNC_Delay[1] && DVP_HSYNC_Delay[0]);

reg HSYNC_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    HSYNC_i<=0;
end
else begin
    if(1/*iEn*/) begin
        if(DVP_HSYNC_Rising) begin HSYNC_i<=1; end
        else if(DVP_HSYNC_Falling) begin HSYNC_i<=0; end
        else begin HSYNC_i<=HSYNC_i; end
    end
    else begin 
        HSYNC_i<=0;
    end
end

//////////////////////////////////////////////////////////////////////////
//Used to capture FF D9(head), FF D8(tail) in Reveal.
reg [7:0] DVP_D_Delay;
always @(posedge PCLK_i or negedge iRstN)
if(!iRstN) begin
    DVP_D_Delay<=0; //oWrData<=0;
end
else begin
    DVP_D_Delay<=(iEn)?(iDVP_D):(0);
    //oWrData<=(iEn)?(DVP_D_Delay):(0);
end

//WrClk of FIFO.
assign oWrClk=PCLK_i;
//Once HSYNC is valid and FIFO is not full, write continuously.
//We don't care about bytes-aligned issue.
reg enPadding;
assign oWrEn=((iEn & HSYNC_i & (!iFull_FIFO))|enPadding)?(1):(0);
// assign oWrData=iDVP_D;
//assign oWrData=8'h11;
assign oWrData=oWrFrmBytes;

//driven by step_i.
reg [7:0] step_i;
reg [7:0] cnt_padding;
always @(posedge PCLK_i or negedge iRstN)
if(!iRstN) begin
    step_i<=0; oWrFrmDone<=0; oWrFrmBytes<=0; cnt_padding<=0; enPadding<=0; 
end
else begin
    if(iEn) begin 
        case(step_i)
        `STEP_00: //HSYNC Pull up to start transfer.
            if(HSYNC_i) begin oWrFrmBytes<=0; step_i<=step_i+1; end
        `STEP_01: //HSYNC Pull down to end transfer.
            if(!HSYNC_i) begin step_i<=step_i+1; end
            else begin oWrFrmBytes<=(oWrEn)?(oWrFrmBytes+1):(oWrFrmBytes); end
        `STEP_02: //Padding with Zero.
            if(cnt_padding==16-1) begin cnt_padding<=0; enPadding<=0; step_i<=step_i+1; end
            else begin enPadding<=1; cnt_padding<=cnt_padding+1; end
        `STEP_03: //One Single Pulse Done Signal.
            begin oWrFrmDone<=1; step_i<=step_i+1; end
        `STEP_04: //One Single Pulse Done Signal.
            begin oWrFrmDone<=0; step_i<=`STEP_00; end
        default:
            begin oWrFrmDone<=0; step_i<=`STEP_00; end
        endcase
    end
    else begin
        step_i<=0; oWrFrmDone<=0; 
    end
end

endmodule
