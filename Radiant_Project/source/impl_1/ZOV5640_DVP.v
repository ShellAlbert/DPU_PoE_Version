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


    //FIFO, Write Port.
    input wire iFull_FIFO,
    output reg oWrEn_FIFO,
    output reg [15:0] oWrData_FIFO,

    //Already write one frame into FIFO.
    output reg oWrFrmDone,
    //How many bytes were written into FIFO.
    output reg [31:0] oWrFrmBytes /*synthesis syn_preserve=1*/
);


//delay 2 clocks to sync to main clock.
reg [1:0] PCLK_Delay;
reg [1:0] HSYNC_Delay, VSYNC_Delay;
reg [1:0] D_Delay0,D_Delay1,D_Delay2,D_Delay3,D_Delay4,D_Delay5,D_Delay6,D_Delay7;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin
    PCLK_Delay<=2'b00; 
    HSYNC_Delay<=2'b00; VSYNC_Delay<=2'b00;
    D_Delay0<=2'b00; D_Delay1<=2'b00; D_Delay2<=2'b00; D_Delay3<=2'b00; D_Delay4<=2'b00; D_Delay5<=2'b00; D_Delay6<=2'b00; D_Delay7<=2'b00;
end
else begin 
    PCLK_Delay<={PCLK_Delay[0],iDVP_PCLK};
    HSYNC_Delay<={HSYNC_Delay[0],iDVP_HSYNC};
    VSYNC_Delay<={VSYNC_Delay[0],iDVP_VSYNC};
    D_Delay0<={D_Delay0[0],iDVP_D[0]}; 
    D_Delay1<={D_Delay1[0],iDVP_D[1]}; 
    D_Delay2<={D_Delay2[0],iDVP_D[2]};
    D_Delay3<={D_Delay3[0],iDVP_D[3]}; 
    D_Delay4<={D_Delay4[0],iDVP_D[4]}; 
    D_Delay5<={D_Delay5[0],iDVP_D[5]};
    D_Delay6<={D_Delay6[0],iDVP_D[6]}; 
    D_Delay7<={D_Delay7[0],iDVP_D[7]};
end
//////////////////////////////////////////////////////////////////////
wire PCLK_Rising_Edge;
wire PCLK_Falling_Edge;
assign PCLK_Rising_Edge=(!PCLK_Delay[1] & PCLK_Delay[0]);
assign PCLK_Falling_Edge=(PCLK_Delay[1] & !PCLK_Delay[0]);
//////////////////////////////////////////////////////////////////////
wire HSYNC_Rising_Edge;
wire HSYNC_Falling_Edge;
assign HSYNC_Rising_Edge=(!HSYNC_Delay[1] & HSYNC_Delay[0]);
assign HSYNC_Falling_Edge=(HSYNC_Delay[1] & !HSYNC_Delay[0]);
////////////////////////////////////////////////////////////////////
wire [7:0] Data_Bus;
assign Data_Bus={D_Delay7[1],D_Delay6[1],D_Delay5[1],D_Delay4[1],D_Delay3[1],D_Delay2[1],D_Delay1[1],D_Delay0[1]};
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//driven by step_i.
reg [7:0] step_i;
reg [7:0] cnt_latch;
reg [15:0] data_integrity;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; oWrEn_FIFO<=0; oWrData_FIFO<=0; oWrFrmBytes<=0; cnt_latch<=0; data_integrity<=0; 
end
else begin
    if(iEn) begin
        case(step_i)
        `STEP_00: //Bypass 100 frames.
            if(cnt_latch==100-1) begin cnt_latch<=0; step_i<=step_i+1; end
            else begin 
                if(HSYNC_Falling_Edge) begin cnt_latch<=cnt_latch+1; end
            end
        `STEP_01: //Waiting for A New Frame Starts.
            if(HSYNC_Rising_Edge) begin oWrFrmBytes<=0; step_i<=step_i+1; end
        `STEP_02: //Sample 1st 8-bits Data & Write Into FIFO.
            begin
                if(HSYNC_Falling_Edge) begin oWrEn_FIFO<=0; step_i<=step_i+1; end
                else begin
                        if(cnt_latch==2) begin 
                            cnt_latch<=0; oWrEn_FIFO<=1/*(!iFull_FIFO)?(1):(0)*/; oWrFrmBytes<=oWrFrmBytes+2; 
                            data_integrity<=data_integrity+1;
                        end
                        else begin
                            oWrEn_FIFO<=0;
                            /////////////////////////////////////////////////////////////////////////////////////////////////////
                            if(PCLK_Rising_Edge) begin 
                                oWrData_FIFO<={oWrData_FIFO[7:0],Data_Bus}; 
                                //oWrData_FIFO<=data_integrity; 
                                cnt_latch<=cnt_latch+1; 
                            end
                        end
                end
            end
        `STEP_03:
            begin oWrEn_FIFO<=(!iFull_FIFO)?(1):(0); oWrData_FIFO<=16'h861014; oWrFrmBytes<=oWrFrmBytes+2; step_i<=step_i+1; end
        `STEP_04:
            begin oWrFrmDone<=1; step_i<=step_i+1; end
        `STEP_05:
            begin oWrFrmDone<=0; step_i<=`STEP_00; end
        default: begin step_i<=`STEP_00; end
        endcase
    end
    else begin
        step_i<=0; oWrEn_FIFO<=0; oWrData_FIFO<=0; oWrFrmBytes<=0; cnt_latch<=0;
    end
end


// ///////////////////////////////////////////////////////
// //Since iDVP_PCLK is not assigned to a clock pin in schematic. 
// //So here I try to replicate a new clock equals to iDVP_PCLK.
// reg [1:0] DVP_PCLK_Delay;
// always @(posedge iClk or negedge iRstN)
// if(!iRstN) begin
//     DVP_PCLK_Delay<=2'b00;
// end
// else begin
//     if(iEn) begin 
//         DVP_PCLK_Delay[0]<=iDVP_PCLK;
//         DVP_PCLK_Delay[1]<=DVP_PCLK_Delay[0];
//     end
//     else begin 
//         DVP_PCLK_Delay<=2'b00;
//     end
// end
// wire DVP_PCLK_Falling;
// assign DVP_PCLK_Falling=(DVP_PCLK_Delay[1] && !DVP_PCLK_Delay[0]);
// wire DVP_PCLK_Rising;
// assign DVP_PCLK_Rising=(!DVP_PCLK_Delay[1] && DVP_PCLK_Delay[0]);
// ///////////////////////////////////////////////////////////////////////////////////////
// reg PCLK_i;
// always @(posedge iClk or negedge iRstN)
// if(!iRstN) begin
//     PCLK_i<=0;
// end
// else begin
//     if(iEn) begin
//         if(DVP_PCLK_Rising) begin PCLK_i<=1; end
//         else if(DVP_PCLK_Falling) begin PCLK_i<=0; end
//         else begin PCLK_i<=PCLK_i; end
//     end
//     else begin 
//         PCLK_i<=0;
//     end
// end

// ///////////////////////////////////////////////////////
// //Rising and Falling Edge Detection. 
// //Edge Synced to System Clock.
// reg [1:0] DVP_VSYNC_Delay;
// always @(posedge iClk or negedge iRstN)
// if(!iRstN) begin
//     DVP_VSYNC_Delay<=2'b00;
// end
// else begin
//     if(iEn) begin 
//         DVP_VSYNC_Delay[0]<=iDVP_VSYNC;
//         DVP_VSYNC_Delay[1]<=DVP_VSYNC_Delay[0];
//     end
//     else begin 
//         DVP_VSYNC_Delay<=2'b00;
//     end
// end
// wire DVP_VSYNC_Falling;
// assign DVP_VSYNC_Falling=(DVP_VSYNC_Delay[1] && !DVP_VSYNC_Delay[0]);
// wire DVP_VSYNC_Rising;
// assign DVP_VSYNC_Rising=(!DVP_VSYNC_Delay[1] && DVP_VSYNC_Delay[0]);

// reg VSYNC_i;
// always @(posedge iClk or negedge iRstN)
// if(!iRstN) begin
//     VSYNC_i<=0;
// end
// else begin
//     if(iEn) begin
//         if(DVP_VSYNC_Rising) begin VSYNC_i<=1; end
//         else if(DVP_VSYNC_Falling) begin VSYNC_i<=0; end
//         else begin VSYNC_i<=VSYNC_i; end
//     end
//     else begin 
//         VSYNC_i<=0;
//     end
// end

// ///////////////////////////////////////////////////////
// //Rising and Falling Edge Detection. 
// //Edge Synced to System Clock.
// reg [1:0] DVP_HSYNC_Delay;
// always @(posedge iClk or negedge iRstN)
// if(!iRstN) begin
//     DVP_HSYNC_Delay<=2'b00;
// end
// else begin
//     if(iEn) begin 
//         DVP_HSYNC_Delay[0]<=iDVP_HSYNC;
//         DVP_HSYNC_Delay[1]<=DVP_HSYNC_Delay[0];
//     end
//     else begin
//         DVP_HSYNC_Delay<=2'b00;
//     end
// end
// wire DVP_HSYNC_Falling;
// assign DVP_HSYNC_Falling=(DVP_HSYNC_Delay[1] && !DVP_HSYNC_Delay[0]);
// wire DVP_HSYNC_Rising;
// assign DVP_HSYNC_Rising=(!DVP_HSYNC_Delay[1] && DVP_HSYNC_Delay[0]);

// reg HSYNC_i;
// always @(posedge iClk or negedge iRstN)
// if(!iRstN) begin
//     HSYNC_i<=0;
// end
// else begin
//     if(iEn) begin
//         if(DVP_HSYNC_Rising) begin HSYNC_i<=1; end
//         else if(DVP_HSYNC_Falling) begin HSYNC_i<=0; end
//         else begin HSYNC_i<=HSYNC_i; end
//     end
//     else begin 
//         HSYNC_i<=0;
//     end
// end

// //////////////////////////////////////////////////////////////////////////
// //Used to capture FF D9(head), FF D8(tail) in Reveal.
// reg [7:0] DVP_D_Delay;
// always @(posedge PCLK_i or negedge iRstN)
// if(!iRstN) begin
//     DVP_D_Delay<=0; //oWrData<=0;
// end
// else begin
//     DVP_D_Delay<=(iEn)?(iDVP_D):(0);
//     //oWrData<=(iEn)?(DVP_D_Delay):(0);
// end
////////////////////////////////////////////////////
// reg [1:0] full_FIFO_Delay;
// always @(posedge PCLK_i or negedge iRstN)
// if(!iRstN) begin
//     full_FIFO_Delay<=2'b00;
// end
// else begin
//     full_FIFO_Delay[0]<=iFull_FIFO;
//     full_FIFO_Delay[1]<=full_FIFO_Delay[0];
// end


// // wire WrClkNoFullCheck /*synthesis syn_preserve=1*/;
// // assign WrClkNoFullCheck=(iEn & HSYNC_i | enPadding)?(PCLK_i):(0);

// //Once HSYNC is valid and FIFO is not full, write continuously.
// //We don't care about bytes-aligned issue.
// reg enPadding;
// //assign oWrEn=(iEn & HSYNC_i & ((!iFull_FIFO)|enPadding))?(1):(0);
// //sync WrEn to clock.
// always @(posedge PCLK_i or negedge iRstN) 
// if(!iRstN) begin oWrEn<=0; end
// else begin
//     oWrEn<=((iEn & HSYNC_i & (!iFull_FIFO))|enPadding)?(1):(0);
// end
// // wire WrEnNoFullCheck /*synthesis syn_preserve=1*/;
// // assign WrEnNoFullCheck=((iEn & HSYNC_i)|enPadding)?(1):(0);


// //WrClk of FIFO.
// assign oWrClk=(oWrEn)?(PCLK_i):(0);

// // assign oWrData=iDVP_D;
// //assign oWrData=8'h11;
// assign oWrData=oWrFrmBytes;

// //driven by step_i.
// reg [7:0] step_i;
// reg [7:0] cnt_padding;
// always @(posedge PCLK_i or negedge iRstN)
// if(!iRstN) begin
//     step_i<=0; oWrFrmDone<=0; oWrFrmBytes<=0; cnt_padding<=0; enPadding<=0; 
// end
// else begin
//     if(iEn) begin 
//         case(step_i)
//         `STEP_00: //HSYNC Pull up to start transfer.
//             if(HSYNC_i) begin oWrFrmBytes<=0; step_i<=step_i+1; end
//         `STEP_01: //HSYNC Pull down to end transfer.
//             if(!HSYNC_i) begin step_i<=step_i+1; end
//             else begin oWrFrmBytes<=(oWrEn)?(oWrFrmBytes+1):(oWrFrmBytes); end
//         `STEP_02: //Padding with Zero.
//             if(cnt_padding==16-1) begin cnt_padding<=0; enPadding<=0; step_i<=step_i+1; end
//             else begin enPadding<=1; cnt_padding<=cnt_padding+1; end
//         `STEP_03: //One Single Pulse Done Signal.
//             begin oWrFrmDone<=1; step_i<=step_i+1; end
//         `STEP_04: //One Single Pulse Done Signal.
//             begin oWrFrmDone<=0; step_i<=`STEP_00; end
//         default:
//             begin oWrFrmDone<=0; step_i<=`STEP_00; end
//         endcase
//     end
//     else begin
//         step_i<=0; oWrFrmDone<=0; 
//     end
// end

endmodule
