

//Control-Phase.
//Block Select Bits [4:0].
parameter BSB40_COMMON_REG  = 5'b00000;
parameter BSB40_SOCKET0_REG = 5'b00001;
parameter BSB40_SOCKET0_TX  = 5'b00010;
parameter BSB40_SOCKET0_RX  = 5'b00011;

//Control-Phase Read/Write Bit.[2]
parameter CP_RWB_RD = 1'b0; //Read.
parameter CP_RWB_WR = 1'b1; //Write.

//Control-Phase SPI Operation Mode Bits. [1:0]
parameter CP_OM_VDM = 2'b00; //Variable Length Data Mode,controlled by SCSn.
parameter CP_OM_1 = 2'b01; //Fixed Data Length Mode, 1 byte data length.
parameter CP_OM_2 = 2'b10; //Fixed Data Length Mode, 2 byte data length.
parameter CP_OM_4 = 2'b11; //Fixed Data Length Mode, 4 byte data length.

//Address Offset Definition for W5500

//VERSIONR, Chip Version Register.
//VERSIONR always indicates the W5500 version as 0x04.
parameter ADDR_VERR = 16'h0039;
parameter VERSION_W5500 = 8'h04;

//PHYCFGR, PHY Configuration Register.
parameter ADDR_PHYCFGR = 16'h002E;

//Gateway Address. (GAR)
parameter ADDR_GAR0 = 16'h0001;
parameter ADDR_GAR1 = 16'h0002;
parameter ADDR_GAR2 = 16'h0003;
parameter ADDR_GAR3 = 16'h0004;

//Subnet Mask Address. (SUBR)
parameter ADDR_SUBR0 = 16'h0005;
parameter ADDR_SUBR1 = 16'h0006;
parameter ADDR_SUBR2 = 16'h0007;
parameter ADDR_SUBR3 = 16'h0008;

//Source Hardware Address. (MAC)
parameter ADDR_SHA0 = 16'h0009;
parameter ADDR_SHA1 = 16'h000A;
parameter ADDR_SHA2 = 16'h000B;
parameter ADDR_SHA3 = 16'h000C;
parameter ADDR_SHA4 = 16'h000D;
parameter ADDR_SHA5 = 16'h000E;

//Source IP Address. (SIPR)
parameter ADDR_SIPR0 = 16'h000F;
parameter ADDR_SIPR1 = 16'h0010;
parameter ADDR_SIPR2 = 16'h0011;
parameter ADDR_SIPR3 = 16'h0012;


//Socket Register Block.

//Socket n Mode. (Sn_MR)
parameter ADDR_Sn_MR = 16'h0000;
parameter PRO_MODE_CLOSED = 4'hb0000;
parameter PRO_MODE_TCP = 4'b0001; 
parameter PRO_MODE_UDP = 4'b0010;
parameter PRO_MODE_MACRAW = 4'b0100;
///////////////////////////////////////////////////////////////////
//Socket n Command Register. (Sn_CR)
parameter ADDR_Sn_CR = 16'h0001;
//Command List.
parameter CMD_OPEN      = 8'h01;
parameter CMD_LISTEN    = 8'h02;
parameter CMD_CONNECT   = 8'h04;
parameter CMD_DISCON    = 8'h08;
parameter CMD_CLOSE     = 8'h10;
parameter CMD_SEND      = 8'h20;
parameter CMD_SEND_MAC  = 8'h21;
parameter CMD_SEND_KEEP = 8'h22;
parameter CMD_RECV      = 8'h40;
///////////////////////////////////////////////////////////////////
//Socket n Interrupt Register. (Sn_IR)
parameter ADDR_Sn_IR = 16'h0002;
parameter IR_SEND_OK = 8'h10; //[4]=1.
parameter IR_TIMEOUT = 8'h08; //[3]=1.
parameter IR_RECV = 8'h04; //[2]=1.
parameter IR_DISCON = 8'h02; //[1]=1.
parameter IR_CON = 8'h01; //[0]=1.

///////////////////////////////////////////////////////////////////
//Socket n Status.(Sn_SR)
parameter ADDR_Sn_SR = 16'h0003;
//Socket Status Definition.
parameter SOCK_CLOSED       = 8'h00;
parameter SOCK_INIT         = 8'h13;
parameter SOCK_LISTEN       = 8'h14;
parameter SOCK_ESTABLISHED  = 8'h17;
parameter SOCK_CLOSE_WAIT   = 8'h1C;
parameter SOCK_UDP          = 8'h22;
parameter SOCK_MACRAW       = 8'h42;
///////////////////////////////////////////////////////////////////
//Socket n Source Port. (Sn_PORT0, Sn_PORT1)
parameter ADDR_Sn_PORT0 = 16'h0004;
parameter ADDR_Sn_PORT1 = 16'h0005;
///////////////////////////////////////////////////////////////////
//Socket n Destination IP Address. (Sn_DIPR0,Sn_DIPR1,Sn_DIPR2,Sn_DIPR3)
parameter ADDR_Sn_DIPR0 = 16'h000C;
parameter ADDR_Sn_DIPR1 = 16'h000D;
parameter ADDR_Sn_DIPR2 = 16'h000E;
parameter ADDR_Sn_DIPR3 = 16'h000F;
/////////////////////////////////////////////////////////////////////
//Socket n Destination Port. (Sn_DPORT0, Sn_DPORT1)
parameter ADDR_Sn_DPORT0 = 16'h0010;
parameter ADDR_Sn_DPORT1 = 16'h0011;
////////////////////////////////////////////////////////////////////////
//Socket n TX Free Size. (Sn_TX_FSR0, Sn_TX_FSR1)
parameter ADDR_Sn_TX_FSR0 = 16'h0020;
parameter ADDR_Sn_TX_FSR1 = 16'h0021;
/////////////////////////////////////////////////////////////////////////
//Socket n TX Read Pointer. (Sn_TX_RD0, Sn_TX_RD1)
parameter ADDR_Sn_TX_RD0 = 16'h0022;
parameter ADDR_Sn_TX_RD1 = 16'h0023;
/////////////////////////////////////////////////////////////////////////
//Socket n Tx Write Pointer. (Sn_TX_WR0, Sn_TX_WR1)
parameter ADDR_Sn_TX_WR0 = 16'h0024;
parameter ADDR_Sn_TX_WR1 = 16'h0025;
/////////////////////////////////////////////////////////////////////
//Socket n Rx Received Size. (Sn_RX_RSR0, Sn_RX_RSR1)
parameter ADDR_Sn_RX_RSR0 = 16'h0026;
parameter ADDR_Sn_RX_RSR1 = 16'h0027;
//Socket n Rx Read Pointer. (Sn_RX_RD0, Sn_RX_RD1)
parameter ADDR_Sn_RX_RD0 = 16'h0028;
parameter ADDR_Sn_RX_RD1 = 16'h0029;
///////////////////////////////////////////////////////////////////////
//KeepAliveTimer. (Sn_KPALVTR)
parameter ADDR_Sn_KPALVTR = 16'h002F;

