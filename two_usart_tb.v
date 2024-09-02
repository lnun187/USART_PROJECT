`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2024 03:22:48 PM
// Design Name: 
// Module Name: two_usart_tb
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


module two_usart_tb;
    reg Reset;
    reg None; // None = 0, cpu ko co yeu cau gi voi usart     None = 1, tuy thuoc trang thai cua Rec va Trans
    reg Rec;  // Rec = 1, Trans = 0 la cpu dang nhan data     Rec = 1, Trans = 1 la cpu dang setup lai cho usart
    reg Trans;// Rec = 0, Trans = 1 la cpu dang truyen data   Rec = 0, Trans = 0 la ko lam gi
    reg CPU_Clk; // Clk cua CPU voi usart, khong lien quan gi toi nhan/truyen giua usart nay voi usart khac
    reg [5:0] Control;
    reg [7:0] CPU_Data_in;
    wire InClk;
    wire ExClk;
    wire SLBit;
    wire [7:0] CPU_Data_out;
    two_usart test(Reset, None, Rec, Trans, CPU_Clk, Control, CPU_Data_in, InClk, ExClk, SLBit, CPU_Data_out);
    initial begin
        CPU_Clk = 1'b0;
        forever #2 CPU_Clk = ~CPU_Clk;
    end
    initial begin
        Reset = 1'b0;
        None = 1'b0;
        Rec = 1'b1;
        Trans = 1'b1;
        Control = 6'b011001;
        #5 Reset = 1'b1;        
        #5 Reset = 1'b0;
        None = 1'b1;
        #200000 $finish;
    end
    initial begin
            Trans = 1'b0;
        forever begin
            #20 Trans = 1'b1;
            #2000 Trans = 1'b0;
        end
    end
    initial begin
             Rec = 1'b0;
            #1980
        forever begin
            #10 Rec = 1'b1;
            #20000 Rec = 1'b0;
        end
    end
    initial begin
        forever #198 CPU_Data_in = {$random} % 256;
    end
endmodule
