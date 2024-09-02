`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2023 10:10:36 PM
// Design Name: 
// Module Name: GEN_Clk_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module GEN_Clk_tb;
    reg Reset;
    reg Mode;
    reg Sync;
    reg [3:0] Baudrate;
    reg CPUClk;
    reg ExClk;
    wire InClk;
    integer i;
    USART_GENClock Clock(Reset, Mode, Sync, Baudrate, CPUClk, ExClk, InClk);
    initial begin // tao CPUClk
        CPUClk = 1'b0;
        forever #0.1 CPUClk = ~CPUClk;
    end
    initial begin // tao CPUClk
            ExClk = 1'b0;
            forever #10 ExClk = ~ExClk;
        end
    initial begin
        Mode = 1'b0;
        Sync = 1'b0;
        Reset = 1'b1;
        #5 Reset = 1'b0;
//        ExClk = 1'b0;
        Baudrate = 4'd0;
        for(i = 1; i < 14; i = i + 1) begin
            #100 Baudrate = i;
        end
        #2000 $finish;
    end
endmodule
