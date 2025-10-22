module ZUV_Capture(
    input iClk,
    input iRst_N,
    input iEn,

    input iBT1120_CLK,
    input iSYNC_O,
    input [7:0] iBT1120_D,

    input iUV_UART_RX,
    output reg oUV_UART_TX,

    output reg oUV_PWR_EN
);

reg [7:0] step_i;
always @(posedge iClk or negedge iRst_N) 
if(!iRst_N) begin
    step_i<=0;
    oUV_UART_TX<=1; oUV_PWR_EN<=0; 
end
else begin
    if(iEn) begin
        if(iBT1120_D==8'h33 && iBT1120_CLK && iSYNC_O && iUV_UART_RX) begin
            oUV_UART_TX<=~oUV_UART_TX; 
        end
    end
    else begin 
        oUV_UART_TX<=1; oUV_PWR_EN<=0; 
    end
end
endmodule