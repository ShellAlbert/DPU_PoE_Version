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
    //[2:0]=3'b000, Hardware Reset.
    //[2:0]=3'b001, Read Registers.
    //[2:0]=3'b010, Write Registers.
    //[2:0]=3'b011, Read Memory.
    //[2:0]=3'b100, Write Memory.
    input [2:0] iOpReq,
    output reg oOpDone,

    //HyperRAM Interface.
    output reg oRSTN,
    output reg oCSN,
    output reg oCKP,
    //output wire oCKN,
    inout wire ioRWDS0,
    inout wire ioRWDS1,
    inout wire [15:0] ioDQ,

    output reg oTP10
);

///////////////////////////////////////////////////////////////////////////
reg output_En_DQ_i; //tristate control.
wire [15:0] DQ_In;
reg [15:0] DQ_Out;
assign DQ_In=ioDQ; //Input.  //16'bzzzzzzzzzzzzzzzz
assign ioDQ=(output_En_DQ_i)?(DQ_Out):({16{1'bz}}); //Output.


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
parameter CA_IDENTIFICATION_REG0=48'hC0_00_00_00_00_00; //(read-only)
//parameter CA_IDENTIFICATION_REG0=48'h12_34_56_78_9A_BC; //(read-only)
parameter CA_IDENTIFICATION_REG1=48'hC0_00_00_00_00_01; //(read-only)

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
    oRSTN<=1; oCSN<=1; oCKP<=0; oTP10<=0;
end
else begin
    if(iEn) begin
        case(iOpReq)
            3'b000: //[2:0]=3'b000, Hardware Reset.
                case(step_i)
                `STEP_00: //Hardware Reset.
                //tRP, RESET# Pulse Width > 200nS. 
                    if(cnt1_i==1000-1) begin cnt1_i<=0; oRSTN<=1; step_i<=step_i+1; end
                    else begin oRSTN<=0; cnt1_i<=cnt1_i+1; end
                `STEP_01:
                //tRPH, RESET# Low to CS# Low > 400ns.
                    if(cnt1_i==1000-1) begin cnt1_i<=0; step_i<=step_i+1;end
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
                    if(cnt1_i==10) begin cnt1_i<=0; step_i<=step_i+1;  oTP10<=1; end
                    else begin 
                        oCSN<=0; //Pull CS# Low.
                        oCKP<=0; 
                        //During the CA transfer portion of a read or write transaction,
                        //RWDS[1:0] acts as an output from a HyperRAM to indicate whether additional initial access latency is needed.
                        //If RWDS is Low during the CA cycles, one latency count is inserted.
                        //If RWDS is High during the CA cycles, an additional latency count is inserted.
                        output_En_RWDS0<=0; output_En_RWDS1<=0;
                        //Data bus Tri-State=Output.
                        CA_DR_i<=CA_IDENTIFICATION_REG0; output_En_DQ_i<=1; DQ_Out<=0;
                        cnt1_i<=cnt1_i+1;
                    end
                `STEP_01:
                    begin DQ_Out<={8'd0,CA_DR_i[47:40]}; step_i<=step_i+1; end
                `STEP_02: 
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_03:
                    begin DQ_Out<={8'd0,CA_DR_i[39:32]}; step_i<=step_i+1; end
                `STEP_04:
                    begin oCKP<=0; step_i<=step_i+1; end
                /////////////////////////////////////////////////////////////////////
                `STEP_05: 
                    begin DQ_Out<={8'd0,CA_DR_i[31:24]}; step_i<=step_i+1; end
                `STEP_06:
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_07:
                    begin DQ_Out<={8'd0,CA_DR_i[23:16]}; step_i<=step_i+1; end
                `STEP_08:
                    begin oCKP<=0; step_i<=step_i+1; end
                //////////////////////////////////////////////////////////////////////
                `STEP_09: //Latency=1.
                    begin DQ_Out<={8'd0,CA_DR_i[15:8]}; step_i<=step_i+1; end
                `STEP_10:
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_11:
                    begin DQ_Out<={8'd0,CA_DR_i[7:0]}; step_i<=step_i+1; end
                `STEP_12:
                    begin oCKP<=0; step_i<=step_i+1; output_En_DQ_i<=0;  end
                //////////////////////////////////////////////////////////////////////
                `STEP_13: //Initial Latency-7 Clock Latency for clock rate<=200MHz(default)
                    //Fixed Latency Enable-Fixed 2 times Initial Latency (default)
                    begin 
                        oCKP<=1; step_i<=step_i+1; //Tri-State=Input.
                    end
                `STEP_14: 
                    begin oCKP<=0; step_i<=step_i+1; end
                `STEP_15: 
                    if(cnt1_i==28-1) begin cnt1_i<=0; step_i<=step_i+1; end
                    else begin cnt1_i<=cnt1_i+1; step_i<=step_i-2; end
                `STEP_16:
                    begin  oCSN<=1; oOpDone<=1; oTP10<=0; step_i<=step_i+1; end 
                `STEP_17:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b010: //[2:0]=3'b010, Write Registers.
            case(step_i)
                `STEP_00: //Read Identification Register 0, Pull CS# Low.
                    begin 
                        oCSN<=0; //Pull CS# Low.
                        oCKP<=0; 
                        //Memory drives RWDS[1:0].
                        output_En_RWDS0<=0; output_En_RWDS1<=0;
                        //Data bus Tri-State=Output.
                        CA_DR_i<=CA_CONFIG_REG0_WRITE; output_En_DQ_i<=1; DQ_Out<=0;
                        step_i<=step_i+1;  oTP10<=1;
                    end
                `STEP_01:
                    begin DQ_Out<={8'd0,CA_DR_i[47:40]}; step_i<=step_i+1; end
                `STEP_02: 
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_03:
                    begin DQ_Out<={8'd0,CA_DR_i[39:32]}; step_i<=step_i+1; end
                `STEP_04:
                    begin oCKP<=0; step_i<=step_i+1; end
                /////////////////////////////////////////////////////////////////////
                `STEP_05: 
                    begin DQ_Out<={8'd0,CA_DR_i[31:24]}; step_i<=step_i+1; end
                `STEP_06:
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_07:
                    begin DQ_Out<={8'd0,CA_DR_i[23:16]}; step_i<=step_i+1; end
                `STEP_08:
                    begin oCKP<=0; step_i<=step_i+1; end
                //////////////////////////////////////////////////////////////////////
                `STEP_09: 
                    begin DQ_Out<={8'd0,CA_DR_i[15:8]}; step_i<=step_i+1; end
                `STEP_10:
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_11:
                    begin DQ_Out<={8'd0,CA_DR_i[7:0]}; step_i<=step_i+1; end
                `STEP_12:
                    begin oCKP<=0; step_i<=step_i+1; end
                //////////////////////////////////////////////////////////////////////
                `STEP_13: //RG[15:8],1_000_1111_1110_1_1_11=0x8FEF
                    begin DQ_Out<={8'd0,8'h8F}; step_i<=step_i+1; end
                `STEP_14:
                    begin oCKP<=1; step_i<=step_i+1; end
                `STEP_15: //RG[7:0]
                    begin DQ_Out<={8'd0,8'hEF}; step_i<=step_i+1; end
                `STEP_16:
                    begin oCKP<=0; step_i<=step_i+1; end
                `STEP_17: //Pull up CSN to end.
                    begin  oCSN<=1; oOpDone<=1; oTP10<=0; step_i<=step_i+1; end 
                `STEP_18:
                    begin oOpDone<=0; step_i<=`STEP_00; end
                default:
                    begin step_i<=`STEP_00; end
                endcase
            3'b011: //[2:0]=3'b011, Read Memory.
                begin step_i<=`STEP_00; end
            3'b100: //[2:0]=3'b100, Write Memory.
                begin step_i<=`STEP_00; end
            default: 
                begin step_i<=`STEP_00; end
        endcase
    end
end
endmodule