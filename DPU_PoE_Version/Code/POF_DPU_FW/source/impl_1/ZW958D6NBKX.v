`include "ZPortableDefine.v"
//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZW958D6NBKX(
    input wire iClk,
    input wire iClkShift90,
    input wire iEn,
    input wire iRstN,

    //Operation Request.
    //[2:0]=3'b000, Hardware Reset.
    //[2:0]=3'b001, Read Registers.
    //[2:0]=3'b010, Write Registers.
    //[2:0]=3'b011, Read Memory.
    //[2:0]=3'b100, Write Memory.
    input [2:0] iOpReq,
    //Memory Address. [22:8]: Row Address, [7:0], Column Address.
    input [22:0] iOpMemAddr, //Memory Space Address. 
    input [127:0] iOpMemData, //Memory Write Data.(16-bits Rising Edge + 16-bits Falling Edge). 32*4 CLKS=128.
    output reg [127:0] oRdData,
    output reg oOpDone,

    //HyperRAM Interface.
    output reg oRSTN,
    output reg oCSN,
    output wire oCKP,
    //output wire oCKN,
    inout wire ioRWDS0,
    inout wire ioRWDS1,
    inout wire [15:0] ioDQ,

    output reg oClkUsed
);


// ODDRX1 #(.GSR ("ENABLED")) CKP_OUT_DDR 
// (
// .D0   (1'b1),  // I
// .D1   (1'b0),  // I
// .SCLK (iClkShift),  // I
// .RST  (~iRstN),  // I
// .Q    (oCKP)   // O
// );
assign oCKP=iClkShift90;

//////////////////////////////////////////////////////////////////////
// Input DDR <---    |
//  (DQ_In_Rising)   |
//  (DQ_In_Falling)  |
//                   DQ_In <---  ioDQ
//   Output DDR ---> DQ_Out ---> ioDQ
//   (DQ_Out_Rising)  ^
//   (DQ_Out_Falling) ^
//                    |
//               output_En_DQ_i
///////////////////////////////////////////////////////////////////////////
reg output_En_DQ_i; //tristate control.
wire [15:0] DQ_In;
wire [15:0] DQ_Out;
assign DQ_In=ioDQ; //Input.  //16'bzzzzzzzzzzzzzzzz
assign ioDQ=(output_En_DQ_i)?(DQ_Out):({16{1'bz}}); //Output.

// wire [15:0] DQ_In_DelayB;
// genvar cnt_i1;
// generate 
// for(cnt_i1=0; cnt_i1<16; cnt_i1=cnt_i1+1) begin
// DELAYB
// #(
//   .DEL_VALUE    ("100"), //100*12.5ps
//   .COARSE_DELAY ("0NS"),
//   .DEL_MODE     ("SCLK_ALIGNED")
// ) myDQ_IN_DelayB(
//   .A (DQ_In[cnt_i1]),  // I
//   .Z (DQ_In_DelayB[cnt_i1])   // O
// );
// end
// endgenerate

//16-bits DDR IN.
wire [15:0] DQ_In_Rising;
wire [15:0] DQ_In_Falling;
wire [15:0] DQ_In_DelayB/*synthesis syn_keep=1*/; 
//declare a temporary loop variable to be used during generation.
//won't be available during simulation.
genvar i;
generate //generate for loop to instantiate 16 times for DDR Input.
    for(i=0; i<16; i=i+1) begin : ddr_dq_in
//Once we use DELAYB before IDDRx1, 
//we can't probe this signal in Reveal, otherwise following error occurs.
//Error	52281040	Map	ERROR <52281040> - Delay 'myHyperRAM.hyperRAM_W958D6NBKX.ddr_dq_in[15].myDQ_IN_DelayB' input signal 'DQ_In_DelayB_15__N_1001' cannot drive both delay component and other logic due to device architecture limitation..	
//Error	52281048	Map	ERROR <52281048> - Cannot pack DELAY component 'myHyperRAM.hyperRAM_W958D6NBKX.ddr_dq_in[1].myDQ_IN_DelayB' into any IOLOGIC, please check its usage. E.g. It must be associated with an IO - It delays an input or output, it cannot delay any logic within FPGA core.	
        DELAYB #(
        .DEL_VALUE("127"), //127*12.5ps=1.58nS
        .DEL_MODE("USER_DEFINED")
        ) myDQ_IN_DelayB(
        .A (DQ_In[i]),  // I
        .Z (DQ_In_DelayB[i])   // O
        );

        IDDRX1 #(.GSR("ENABLED"))DQ_IN_DDR(
        .D (DQ_In_DelayB[i]),  // I
        .SCLK (iClk),  // I
        .RST  (~iRstN),  // I
        .Q0   (DQ_In_Rising[i]),  // O
        .Q1   (DQ_In_Falling[i])   // O
        );
    end 
endgenerate


//16-bits DDR OUT.
reg [15:0] DQ_Out_Rising;
reg [15:0] DQ_Out_Falling;
//declare a temporary loop variable to be used during generation.
//won't be available during simulation.
generate //generate for loop to instantiate 16 times for DDR Output.
    for(i=0; i<16; i=i+1) begin : ddr_dq_out
        ODDRX1 #(.GSR ("ENABLED"))DQ_OUT_DDR(
        .D0   (DQ_Out_Rising[i]),  // I
        .D1   (DQ_Out_Falling[i]),  // I
        .SCLK (iClk),  // I
        .RST  (~iRstN),  // I
        .Q    (DQ_Out[i])   // O
        );
    end
endgenerate
////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////
//Tri-State of RWDS0.
reg output_En_RWDS0; //Tri-State Control.
wire iRWDS0; 
wire oRWDS0; 
assign iRWDS0=ioRWDS0;  //input.
assign ioRWDS0=(output_En_RWDS0==1)?(oRWDS0):(1'bz);  //output.
wire RWDS0_In_Rising;
wire RWDS0_In_Falling;
IDDRX1 #(.GSR ("ENABLED")) RWDS0_IN_DDR
(
.D    (iRWDS0),  // I
.SCLK (iClk),  // I
.RST  (~iRstN),  // I
.Q0   (RWDS0_In_Rising),  // O
.Q1   (RWDS0_In_Falling)   // O
);
reg RWDS0_Out_Rising;
reg RWDS0_Out_Falling;
ODDRX1 #(.GSR ("ENABLED")) RWDS0_OUT_DDR 
(
.D0   (RWDS0_Out_Rising),  // I
.D1   (RWDS0_Out_Falling),  // I
.SCLK (iClk),  // I
.RST  (~iRstN),  // I
.Q    (oRWDS0)   // O
);

//Tri-State of RWDS1.
reg output_En_RWDS1; //Tri-State Control.
wire iRWDS1; 
wire oRWDS1; 
assign iRWDS1=ioRWDS1; //input.
assign ioRWDS1=(output_En_RWDS1==1)?(oRWDS1):(1'bz); //output.
wire RWDS1_In_Rising;
wire RWDS1_In_Falling;
IDDRX1 #(.GSR ("ENABLED")) RWDS1_IN_DDR
(
.D    (iRWDS1),  // I
.SCLK (iClk),  // I
.RST  (~iRstN),  // I
.Q0   (RWDS1_In_Rising),  // O
.Q1   (RWDS1_In_Rising)   // O
);
reg RWDS1_Out_Rising;
reg RWDS1_Out_Falling;
ODDRX1 #(.GSR ("ENABLED")) RWDS1_OUT_DDR 
(
.D0   (RWDS1_Out_Rising),  // I
.D1   (RWDS1_Out_Falling),  // I
.SCLK (iClk),  // I
.RST  (~iRstN),  // I
.Q    (oRWDS1)   // O
);

//////////////////////////////////////////////////////////////////////////

//Data Register for Column Address.
reg [47:0] CA_DR_i;
//Configure Registers.
//CA[47:40]=011X_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX_0000_0000_0000_0XXX
//[47], R/W#, 1:indicates a Read transaction. 0:indicates a Write transaction.
//[46], Address Space, 0:indicates memory space, 1:indicates register space.
//[45], Burst Type, 0:indicates wrapped burst, 1:indicates linear burst.
//[44-16]: Row & Upper Column Address, A31-A3.
//[15-3]: Reserved, should be set to 0.
//[2-0]: Low Column Address, A2-A0.
//Identification Register 0 (Read only).
//Refer to <9.1 HyperRAM Register Addressing> in official datasheet.
parameter CA_IDENTIFICATION_REG0=48'hC0_00_00_00_00_00; //(read-only)
//parameter CA_IDENTIFICATION_REG0=48'h12_34_56_78_9A_BC; //(read-only)
parameter CA_IDENTIFICATION_REG1=48'hC0_00_00_00_00_01; //(read-only)

parameter CA_CONFIG_REG0_READ=48'hC0_00_01_00_00_00; //(read)
parameter CA_CONFIG_REG0_WRITE=48'h60_00_01_00_00_00; //(write)

parameter CA_CONFIG_REG1_READ=48'hC0_00_01_00_00_01; //(read)
parameter CA_CONFIG_REG1_WRITE=48'h60_00_01_00_00_01; //(write)

//Configuration Register 0.
//[15]=1b, Normal Operation.
//[14:12]=000b, 34-ohms.
//[11:8]=1111, Reserved for future use.
//[7:4]=1111b, 4 Clock Latency for clock rate <=104MHz.
//[3]=1b, Fixed 2 times Initial Latency.
//[2]=1b, Wrapped burst sequences in legacy wrapped burst manner.
//[1:0]=11b, Burst Length 32.
//1_000_1111_1111_1_1_11=0x8FFF
localparam CONFIG_REG0_WR_VALUE=16'h8FFF;

////////////////////////////////////////////////
//Clock-Domain-Crossing
//Falling Edge Capture.
reg [15:0] DQ_In_Rising_D1;
reg [15:0] DQ_In_Falling_D1;
always @(negedge iClk or negedge iRstN)
if(!iRstN) begin DQ_In_Rising_D1<=0; DQ_In_Falling_D1<=0; end
else begin DQ_In_Rising_D1<=DQ_In_Rising; DQ_In_Falling_D1<=DQ_In_Falling; end
//Two-stage synchronizer reduces the chance of metastability.
reg [15:0] DQ_In_Rising_D2;
reg [15:0] DQ_In_Falling_D2;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin DQ_In_Rising_D2<=0; DQ_In_Falling_D2<=0; end
else begin DQ_In_Rising_D2<=DQ_In_Rising_D1; DQ_In_Falling_D2<=DQ_In_Falling_D1; end
//Output synchronized data.
reg [15:0] DQ_In_Rising_Sync;
reg [15:0] DQ_In_Falling_Sync;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin DQ_In_Rising_Sync<=0; DQ_In_Falling_Sync<=0; end
else begin DQ_In_Rising_Sync<=DQ_In_Rising_D2; DQ_In_Falling_Sync<=DQ_In_Falling_D2; end

////////////////////////////////////////////////////////////////////////
reg [31:0] DDR_Data_Temp;
//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt1_i; 
reg additional_latency_i;
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt1_i<=0; oClkUsed<=0; oRdData<=0; oOpDone<=0;
    oRSTN<=1; oCSN<=1; output_En_RWDS0<=0; output_En_RWDS1<=0;
    output_En_DQ_i<=1; DQ_Out_Rising<=0; DQ_Out_Falling<=0; 
end
else begin
    if(iEn) begin
        case(iOpReq)
            3'b000: //[2:0]=3'b000, Hardware Reset.
                case(step_i)
                `STEP_00: //Hardware Reset.
                //tRP, RESET# Pulse Width > 200nS. 
                    if(cnt1_i==500-1) begin cnt1_i<=0; oRSTN<=1; step_i<=step_i+1; end
                    else begin oRSTN<=0; cnt1_i<=cnt1_i+1; end
                `STEP_01:
                //tRPH, RESET# Low to CS# Low > 400ns.
                    if(cnt1_i==500-1) begin cnt1_i<=0; step_i<=step_i+1;end
                    else begin cnt1_i<=cnt1_i+1; end
                `STEP_02:
                    begin oOpDone<=1; step_i<=step_i+1; end
                `STEP_03:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b001: //[2:0]=3'b001, Read Registers.
                case(step_i)
                `STEP_00: //Read Identification Register 0, Pull CS# Low.
                    begin 
                        //During the CA transfer portion of a read or write transaction,
                        //RWDS[1:0] acts as an output from a HyperRAM to indicate whether additional initial access latency is needed.
                        //If RWDS is Low during the CA cycles, one latency count is inserted.
                        //If RWDS is High during the CA cycles, an additional latency count is inserted.
                        output_En_RWDS0<=0; output_En_RWDS1<=0;  
                        //Data bus Tri-State=Output.
                        CA_DR_i<=CA_IDENTIFICATION_REG0; output_En_DQ_i<=0; DQ_Out_Rising<=0; DQ_Out_Falling<=0; 
                        DDR_Data_Temp<=0;
                        step_i<=step_i+1; 
                    end
                `STEP_01:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[47:40]}; DQ_Out_Falling<={8'd0,CA_DR_i[39:32]}; step_i<=step_i+1; end
                `STEP_02:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[31:24]}; DQ_Out_Falling<={8'd0,CA_DR_i[23:16]}; step_i<=step_i+1; end
                `STEP_03:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[15:8]}; DQ_Out_Falling<={8'd0,CA_DR_i[7:0]}; step_i<=step_i+1; end
                `STEP_04: //Pull CS# Low.
                    begin oCSN<=0; output_En_DQ_i<=1; step_i<=step_i+1; end
                `STEP_05: //The First-Three Clocks to send Command-Address.
                    if(cnt1_i==3-1) begin cnt1_i<=0; output_En_DQ_i<=0; additional_latency_i<=(iRWDS0)?1:0; step_i<=step_i+1; end
                    else begin cnt1_i<=cnt1_i+1; end
                `STEP_06: //Set Latency=4, fixed 2 Times.
                    if(additional_latency_i) begin //with additional latency, latency count=2.
                        if(cnt1_i==8-1) begin cnt1_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1;end
                    end
                    else begin //without additional latency, latency count=1.
                        if(cnt1_i==4-1) begin cnt1_i<=0; step_i<=step_i+1; end
                        else begin cnt1_i<=cnt1_i+1;end
                    end
                `STEP_07:
                    //RWDS0/RWDS1 is used for variable latency mode.
                    //We use fixed latency mode, so here ignore RWDS0/RWDS1.
                    begin step_i<=step_i+1; end
                `STEP_08:
                    begin oCSN<=1; oOpDone<=1; oRdData<={112'd0,DQ_In_Rising_D1[7:0],DQ_In_Falling_D1[7:0]}; step_i<=step_i+1; end
                `STEP_09:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b010: //[2:0]=3'b010, Write Registers.
                case(step_i)
                `STEP_00: //Read Identification Register 0, Pull CS# Low.
                    begin 
                        //During the CA transfer portion of a read or write transaction,
                        //RWDS[1:0] acts as an output from a HyperRAM to indicate whether additional initial access latency is needed.
                        //If RWDS is Low during the CA cycles, one latency count is inserted.
                        //If RWDS is High during the CA cycles, an additional latency count is inserted.
                        output_En_RWDS0<=0; output_En_RWDS1<=0;  
                        //Data bus Tri-State=Output.
                        CA_DR_i<=CA_CONFIG_REG0_WRITE; output_En_DQ_i<=1; DQ_Out_Rising<=0; DQ_Out_Falling<=0; 
                        step_i<=step_i+1;
                    end
                `STEP_01:
                    begin DQ_Out_Rising<=CA_DR_i[47:40]; DQ_Out_Falling<=CA_DR_i[39:32]; step_i<=step_i+1; end
                `STEP_02: 
                    begin DQ_Out_Rising<=CA_DR_i[31:24]; DQ_Out_Falling<=CA_DR_i[23:16]; step_i<=step_i+1; end
                `STEP_03: 
                    begin DQ_Out_Rising<=CA_DR_i[15:8]; DQ_Out_Falling<=CA_DR_i[7:0]; step_i<=step_i+1; end
                `STEP_04:  //Pull CS# Low. //RG[15:8],1_000_1111_1111_1_1_11=0x8FFF
                    begin 
                        oCSN<=0;   
                        output_En_DQ_i<=1; DQ_Out_Rising<={8'd0,CONFIG_REG0_WR_VALUE}; DQ_Out_Falling<={8'd0,CONFIG_REG0_WR_VALUE}; 
                        step_i<=step_i+1; 
                    end
                `STEP_05:
                    begin DQ_Out_Rising<=0; DQ_Out_Falling<=0; step_i<=step_i+1; end 
                `STEP_06:
                    begin step_i<=step_i+1; end 
                `STEP_07:
                    begin step_i<=step_i+1; end 
                `STEP_08: //Pull up CSN to end.
                    begin  oCSN<=1; oOpDone<=1; step_i<=step_i+1; end 
                `STEP_09:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b011: //[2:0]=3'b011, Read Memory.
                case(step_i)
                `STEP_00: 
                    begin 
                        //During the CA transfer portion of a read or write transaction,
                        //RWDS[1:0] acts as an output from a HyperRAM to indicate whether additional initial access latency is needed.
                        //If RWDS is Low during the CA cycles, one latency count is inserted.
                        //If RWDS is High during the CA cycles, an additional latency count is inserted.
                        output_En_RWDS0<=0; output_En_RWDS1<=0;  
                        //Data bus Tri-State=Output.
                        output_En_DQ_i<=0; DQ_Out_Rising<=0; DQ_Out_Falling<=0; 
                        //prepare address.
                        //CA[47]=1, Read Transaction. CA[46]=0, Memory Space. CA[45]=1, Linear Burst. //3'b001
                        //[44-16]: Row & Upper column address.29'dx
                        //[15-3]: Reserved. Shoule be set to 0. //13'd0
                        //[2:0]: Lower Column Address. //3'dx.
                        //[44:36]: Unused. 9'd0.
                        //[35-21]: Row Address.
                        //[20:16]: Column Address.
                        //[15:3]: Reserved.13'd.
                        //[2:0]: Column Adress.
                        //3-bits+9-bits+15-bits+5-bits+13-bits+3-bits=48-bits.
                        CA_DR_i<={3'b101,9'd0,iOpMemAddr[22:8],iOpMemAddr[7:3],13'd0,iOpMemAddr[2:0]};
                        step_i<=step_i+1; 
                    end
                `STEP_01:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[47:40]}; DQ_Out_Falling<={8'd0,CA_DR_i[39:32]}; step_i<=step_i+1; end
                `STEP_02:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[31:24]}; DQ_Out_Falling<={8'd0,CA_DR_i[23:16]}; step_i<=step_i+1; end
                `STEP_03:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[15:8]}; DQ_Out_Falling<={8'd0,CA_DR_i[7:0]}; step_i<=step_i+1; end
                `STEP_04: //Pull CS# Low.
                    begin oCSN<=0; output_En_DQ_i<=1; step_i<=step_i+1; end
                `STEP_05: //The First-Three Clocks to send Command-Address.
                    if(cnt1_i==3-1) begin cnt1_i<=0; output_En_DQ_i<=0; step_i<=step_i+1; end
                    else begin additional_latency_i<=(iRWDS0)?1:0; cnt1_i<=cnt1_i+1; end
                `STEP_06: //Set Latency=4, Fixed 2 times.
                    begin
                        if(additional_latency_i) begin //with additional latency, latency count=2.
                            if(cnt1_i==8-1) begin cnt1_i<=0; step_i<=step_i+1; end
                            else begin cnt1_i<=cnt1_i+1; end
                        end
                        else begin //without additional latency, latency count=1.
                            if(cnt1_i==4-1) begin cnt1_i<=0; step_i<=step_i+1; end
                            else begin cnt1_i<=cnt1_i+1; end
                        end
                    end
                `STEP_07: 
                    //RWDS0/RWDS1 is used for variable latency mode.
                    //We use fixed latency mode, so here ignore RWDS0/RWDS1.
                    //if({RWDS0_In_Rising,RWDS0_In_Falling}==2'b01) begin step_i<=step_i+1; end
                    begin step_i<=step_i+1; end
                `STEP_08: //IDDRx1 needs 4 clocks to output data.
                    if(cnt1_i==4) begin cnt1_i<=0; step_i<=step_i+1; end
                    else begin oRdData<={oRdData[95:0],DQ_In_Rising_D1,DQ_In_Falling_D1}; cnt1_i<=cnt1_i+1; end
                `STEP_09: //Pull up CSN to end.
                    begin oCSN<=1; oOpDone<=1; step_i<=step_i+1; end 
                `STEP_10:
                    begin oOpDone<=0; step_i<=`STEP_00; end 
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b100: //[2:0]=3'b100, Write Memory.
                case(step_i)
                `STEP_00: 
                    begin 
                        //During the CA transfer portion of a read or write transaction,
                        //RWDS[1:0] acts as an output from a HyperRAM to indicate whether additional initial access latency is needed.
                        //If RWDS is Low during the CA cycles, one latency count is inserted.
                        //If RWDS is High during the CA cycles, an additional latency count is inserted.
                        output_En_RWDS0<=0; output_En_RWDS1<=0;  
                        //Data bus Tri-State=Output.
                        output_En_DQ_i<=0; {DQ_Out_Rising,DQ_Out_Falling}<=0; 
                        //prepare address.
                        //CA[47]=0, Write Transaction. CA[46]=0, Memory Space. CA[45]=1, Linear Burst. //3'b001
                        //[44-16]: Row & Upper column address.29'dx
                        //[15-3]: Reserved. Shoule be set to 0. //13'd0
                        //[2:0]: Lower Column Address. //3'dx.
                        //[44:36]: Unused. 9'd0.
                        //[35-21]: Row Address.
                        //[20:16]: Column Address.
                        //[15:3]: Reserved.13'd.
                        //[2:0]: Column Adress.
                        //3-bits+9-bits+15-bits+5-bits+13-bits+3-bits=48-bits.
                        CA_DR_i<={3'b001,9'd0,iOpMemAddr[22:8],iOpMemAddr[7:3],13'd0,iOpMemAddr[2:0]};
                        step_i<=step_i+1; 
                    end
                `STEP_01:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[47:40]}; DQ_Out_Falling<={8'd0,CA_DR_i[39:32]}; step_i<=step_i+1; end
                `STEP_02:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[31:24]}; DQ_Out_Falling<={8'd0,CA_DR_i[23:16]}; step_i<=step_i+1; end
                `STEP_03:
                    begin DQ_Out_Rising<={8'd0,CA_DR_i[15:8]}; DQ_Out_Falling<={8'd0,CA_DR_i[7:0]}; step_i<=step_i+1; end
                `STEP_04: //Pull CS# Low.
                    begin oCSN<=0; output_En_DQ_i<=1; oClkUsed<=1; step_i<=step_i+1; end
                `STEP_05: //The First-Three Clocks to send Command-Address.
                    if(cnt1_i==3-1-1) begin //-1 means include the clock of Pulling down CSN.
                        cnt1_i<=0; 
                        output_En_RWDS0<=1; RWDS0_Out_Rising<=0; RWDS0_Out_Falling<=0; //Do not mask data.
                        output_En_RWDS1<=1; RWDS0_Out_Rising<=0; RWDS0_Out_Falling<=0; 
                        {DQ_Out_Rising,DQ_Out_Falling}<={16'd0,16'd0};
                        step_i<=step_i+1; 
                    end
                    else begin additional_latency_i<=(iRWDS0)?1:0; cnt1_i<=cnt1_i+1; end
                `STEP_06: //Set Latency=4, Fixed 2 times.
                    begin
                        if(additional_latency_i) begin //with additional latency, latency count=2.
                            if(cnt1_i==8-1) begin cnt1_i<=0; step_i<=step_i+1; end
                            else begin cnt1_i<=cnt1_i+1; end
                            //prepare DDR data before 4 clocks.                            
                            case(cnt1_i) //[127:112],[111,96],[95:80],[79:64],[63:48],[47:32],[31:16],[15:0]
                                /*(8-1-0)*/7: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[31:0]; end
                                /*(8-1-1)*/6: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[63:32]; end
                                /*(8-1-2)*/5: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[95:64]; end
                                /*(8-1-3)*/4: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[127:96]; end
                                default: begin {DQ_Out_Rising,DQ_Out_Falling}<=0; end
                            endcase
                        end
                        else begin //without additional latency, latency count=1.
                            if(cnt1_i==4-1) begin cnt1_i<=0; step_i<=step_i+1; end
                            else begin cnt1_i<=cnt1_i+1; end
                            //prepare DDR data before 4 clocks.                            
                            case(cnt1_i) //[127:112],[111,96],[95:80],[79:64],[63:48],[47:32],[31:16],[15:0]
                                /*(7-1-0)*/6: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[31:0]; end
                                /*(7-1-1)*/5: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[63:32]; end
                                /*(7-1-2)*/4: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[95:64]; end
                                /*(7-1-3)*/3: begin {DQ_Out_Rising,DQ_Out_Falling}<=iOpMemData[127:96]; end
                                default: begin {DQ_Out_Rising,DQ_Out_Falling}<=0; end
                            endcase 
                        end
                    end
                `STEP_07: 
                    begin {DQ_Out_Rising,DQ_Out_Falling}<=0; step_i<=step_i+1; end
                `STEP_08:
                    begin step_i<=step_i+1; end
                `STEP_09:
                    begin step_i<=step_i+1; end
                `STEP_10: //Pull up CSN to end.
                    begin oCSN<=1; oOpDone<=1;step_i<=step_i+1; end 
                `STEP_11:
                    begin oOpDone<=0; oClkUsed<=0; step_i<=`STEP_00; end 
                default:
                    begin step_i<=`STEP_00; end
                endcase
            default:
                begin oOpDone<=0; oClkUsed<=0; step_i<=`STEP_00; end
            endcase
    end //if(iEn) begin
    else begin 
        oOpDone<=0; oClkUsed<=0; step_i<=`STEP_00; 
    end
end

// reg [1:0] RWDS0_Sync;
// always @(negedge iClk or negedge iRstN)
// if(!iRstN) begin
//     RWDS0_Sync<=2'b00;
// end
// else begin
//         if (!output_En_RWDS0 & !output_En_RWDS1 & iRWDS0 & iRWDS1) begin 
//             RWDS0_Sync[0]<=iRWDS0;
//             RWDS0_Sync[1]<=RWDS0_Sync[0];
//         end
// end



//use falling edge of iClk to capture RWDS and Data.
// reg [31:0] DDR_Data_In;
// reg [7:0] step_i_rwds;
// always @(negedge iClk or negedge iRstN)
// if(!iRstN) begin 
//     step_i_rwds<=0;
// end
// else begin
//     if(iEn) begin 
//         case(step_i_rwds)
//             `STEP_00:
//                 if (output_En_RWDS0 & output_En_RWDS1 & iRWDS0 & iRWDS1) begin 
//                     step_i_rwds<=step_i_rwds+1;
//                 end
//             `STEP_01:
//                 begin DDR_Data_In<={DQ_In_Falling, DQ_In_Rising}; end
//         endcase
        
            
//         end
//     end
// end
endmodule
