`include "ZPortableDefine.v"
//Naming Rules:
//XXXX_i:  internal registers.
//iXXXXX:  external input signals.
//oXXXX:   output to external signals.
//ioXXX:   bi-directional signals.
module ZW958D6NBKX(
    input wire iClk,
    input wire iEn,
    input wire iRstN,

    //Operation Request.
    //[1:0]=2'b00, Hardware Reset.
    //[1:0]=2'b01, Read Registers.
    //[1:0]=2'b10, Write Memory.
    //[1:0]=2'b11, Read Memory.
    input [1:0] iOpReq,
    output reg oOpDone,

    //HyperRAM Interface.
    output reg oRSTN,
    output reg oCSN,
    output wire oCKP,
    //output wire oCKN,
    inout wire ioRWDS0,
    inout wire ioRWDS1,
    inout wire [15:0] ioDQ
);
/////////////////////////////////////////////////////////////////////////
//DDR Clock is same as System Clock.
//ODDRx1.Q() must be connected to top-level output port.
reg Clk_DDR_Rst_i;
ODDRX1
#(
.GSR ("ENABLED")
)CLK_DDR (
.D0   (1'b1),  // I
.D1   (1'b0),  // I
.SCLK (iClk),  // I
.RST  (Clk_DDR_Rst_i),  // I
.Q    (oCKP)   // O
);


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
assign DQ_In=ioDQ; //Input.
assign ioDQ=(output_En_DQ_i)?(DQ_Out):(16'bz); //Output.

//16-bits DDR IN.
wire [15:0] DQ_In_Rising;
wire [15:0] DQ_In_Falling;
//declare a temporary loop variable to be used during generation.
//won't be available during simulation.
genvar DQ_In_i;
generate //generate for loop to instantiate 16 times for DDR Input.
    for(DQ_In_i=0; DQ_In_i<16; DQ_In_i=DQ_In_i+1) begin
        IDDRX1
        #(
        .GSR ("ENABLED")
        )DQ_IN_DDR(
        .D    (DQ_In[DQ_In_i]),  // I
        .SCLK (iClk),  // I
        .RST  (~iRstN),  // I
        .Q0   (DQ_In_Rising[DQ_In_i]),  // O
        .Q1   (DQ_In_Falling[DQ_In_i])   // O
        );
    end 
endgenerate


//16-bits DDR OUT.
reg [15:0] DQ_Out_Rising;
reg [15:0] DQ_Out_Falling;
//declare a temporary loop variable to be used during generation.
//won't be available during simulation.
genvar DQ_Out_i;
generate //generate for loop to instantiate 16 times for DDR Output.
    for(DQ_Out_i=0; DQ_Out_i<16; DQ_Out_i=DQ_Out_i+1) begin
        ODDRX1
        #(
        .GSR ("ENABLED")
        )DQ_OUT_DDR (
        .D0   (DQ_Out_Rising[DQ_Out_i]),  // I
        .D1   (DQ_Out_Falling[DQ_Out_i]),  // I
        .SCLK (iClk),  // I
        .RST  (iRstN),  // I
        .Q    (DQ_Out[DQ_Out_i])   // O
        );
    end
endgenerate

/////////////////////////////////////////////////////////////////
//Tri-State of RWDS0.
reg output_En_RWDS0; //Tri-State Control.
wire iRWDS0; 
reg oRWDS0; 
assign iRWDS0=ioRWDS0;  //input.
assign ioRWDS0=(output_En_RWDS0==1)?(oRWDS0):(1'bz);  //output.

//Tri-State of RWDS1.
reg output_En_RWDS1; //Tri-State Control.
wire iRWDS1; 
reg oRWDS1; 
assign iRWDS1=ioRWDS1; //input.
assign ioRWDS1=(output_En_RWDS1==1)?(oRWDS1):(1'bz); //output.
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
//parameter CA_IDENTIFICATION_REG0=48'hC0_00_00_00_00_00; //(read-only)
parameter CA_IDENTIFICATION_REG0=48'h12_34_56_78_9A_BC; //(read-only)
//parameter CA_IDENTIFICATION_REG1=48'hC0_00_00_00_00_01; //(read-only)

parameter CA_CONFIG_REG0_READ=48'hC0_00_01_00_00_00; //(read)
parameter CA_CONFIG_REG0_WRITE=48'h60_00_01_00_00_00; //(write)

parameter CA_CONFIG_REG1_READ=48'hC0_00_01_00_00_01; //(read)
parameter CA_CONFIG_REG1_WRITE=48'h60_00_01_00_00_01; //(write)

////////////////////////////////////////////////////////////////////////
reg [31:0] DDR_In_Temp1;
reg [31:0] DDR_In_Temp2;
//driven by step_i.
reg [7:0] step_i;
reg [15:0] cnt1_i; 
always @(posedge iClk or negedge iRstN)
if(!iRstN) begin 
    step_i<=0; cnt1_i<=0;
    oOpDone<=0;
    oRSTN<=1; oCSN<=1; Clk_DDR_Rst_i<=1; 
end
else begin
    if(!iEn) begin
    end
    else begin
        case(iOpReq)
            2'b00: //2'b00, Hardware Reset.
                case(step_i)
                `STEP_00: //Hardware Reset.
                //tRP, RESET# Pulse Width > 200nS. 
                    if(cnt1_i==10-1) begin cnt1_i<=0; oRSTN<=1; step_i<=step_i+1; end
                    else begin oCSN<=1; oRSTN<=0; cnt1_i<=cnt1_i+1; end
                `STEP_01:
                //tRPH, RESET# Low to CS# Low > 400ns.
                    if(cnt1_i==10-1) begin cnt1_i<=0; oCSN<=0; step_i<=step_i+1;end
                    else begin cnt1_i<=cnt1_i+1; end
                `STEP_02:
                    begin oOpDone<=1; step_i<=step_i+1; end
                `STEP_03:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            2'b01: //2'b01, Read Registers.
                case(step_i)
                `STEP_00: //Read Identification Register 0, Pull CS# Low.
                    begin 
                        oCSN<=0; //Pull CS# Low.
                        Clk_DDR_Rst_i<=0;
                        //If RWDS is Low during the CA cycles, one latency count is inserted.
                        //If RWDS is High during the CA cycles, an additional latency count is inserted.
                        output_En_RWDS0<=1; oRWDS0<=0; output_En_RWDS1<=1; oRWDS1<=0;
                        output_En_DQ_i<=1; //Tri-State=Output.
                        CA_DR_i<=CA_IDENTIFICATION_REG0; //(read-only)
                        step_i<=step_i+1; 
                    end
                `STEP_01: //1st CA Data.
                    begin //Command-Address, Host drives DQ[7:0].
                        DQ_Out_Rising<={7'd0,CA_DR_i[47:40]}; DQ_Out_Falling={7'd0,CA_DR_i[39:32]};
                        step_i<=step_i+1;
                    end
                `STEP_02: //2nd CA Data.
                    begin //Command-Address, Host drives DQ[7:0].
                        DQ_Out_Rising<={7'd0,CA_DR_i[31:24]}; DQ_Out_Falling={7'd0,CA_DR_i[23:16]};
                        step_i<=step_i+1;
                    end
                `STEP_03: //3rd CA Data.
                    begin //Command-Address, Host drives DQ[7:0].  //Latency=1.
                        DQ_Out_Rising<={7'd0,CA_DR_i[15:8]}; DQ_Out_Falling={7'd0,CA_DR_i[7:0]};
                        step_i<=step_i+1;
                    end
                `STEP_04: //Latency=2.
                    begin 
                        output_En_RWDS0<=0; output_En_RWDS1<=0; //Tri-State=Input.
                        output_En_DQ_i<=0; //Tri-State=Input.
                        step_i<=step_i+1;
                    end
                `STEP_05: //Latency=3.
                    begin step_i<=step_i+1; end
                `STEP_06: //Latency=4.
                    begin step_i<=step_i+1; end
                `STEP_07: //1st RG Data.
                    begin 
                        DDR_In_Temp1<={DQ_In_Rising,DQ_In_Falling};
                        step_i<=step_i+1;
                    end
                `STEP_08: //Pull CS# Low.
                    begin 
                        DDR_In_Temp2<={DQ_In_Rising,DQ_In_Falling};
                        step_i<=step_i+1;
                    end
                `STEP_09:
                    begin  oCSN<=1; Clk_DDR_Rst_i<=1; oOpDone<=1; step_i<=step_i+1; end 
                `STEP_10:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            2'b10: //2'b10, Write Memory.
                begin end
            2'b11: //2'b11, Read Memory.
                begin end
            default: 
                begin end
        endcase

    end
end
endmodule