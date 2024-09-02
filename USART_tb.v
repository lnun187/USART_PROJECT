`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2023 09:33:45 PM
// Design Name: 
// Module Name: USART_tb
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


module USART_tb;
    reg Reset; // reset toan bo setup ma cpu da dat cho usart
    reg None; // None = 0; cpu ko co yeu cau gi voi usart     None = 1; tuy thuoc trang thai cua Rec va Trans
    reg Rec;  // Rec = 1; Trans = 0 la cpu dang nhan data     Rec = 1; Trans = 1 la cpu dang setup lai cho usart
    reg Trans;// Rec = 0; Trans = 1 la cpu dang truyen data   Rec = 0; Trans = 0 la ko lam gi
    reg CPUClk; // Clk cua CPU voi usart; khong lien quan gi toi nhan/truyen giua usart nay voi usart khac
    reg[6:0] Control;
    wire [7:0] CPU_Data;
    wire ExClk; // clk giua usart nay voi usart khac (dung trong dong bo)
    wire SLBit; // Bit duoc truyen tuan tu giua cac usart
    wire [4:0] Status;
    wire Clk;
     wire [10:0] test;
    USART trans(Reset, None, Rec, Trans, CPUClk, Control, CPU_Data, ExClk, SLBit, Status, Clk, test);
    reg [7:0] Data;
   reg ex;
//   assign ExClk = ex;
    assign SLBit = Data;
//    assign CPU_Data = Data;


// Mode Sync Baudrate Par
//   x   x     xxxx    x
//   6   5     4321    0
// Mode = 0, usart o che do truyen, Mode = 1, usart o che do nhan
// Sync = 0, usart bat dong bo, Sync = 1, usart dong bo
// toc do truyen do cpu cai trong che do truyen, toc do nhan do cpu cai trong che do nhan bat dong bo
         
         
//    reg [4:0] Status;
// CP OV AV FE PE
// x  x  x  x  x 
// 4  3  2  1  0 
// CP = 1, da hoan tat viec truyen/nhan
// OV = 1, bo nho usart dang day
// AV = 1, bo nho usart dang trong
// FE = 1, nhan goi du lieu sai, khong co stopbit
// PE = 1, nhan goi du lieu sai khong dung parity bit
        
        
    initial begin // tao CPUClk
        CPUClk = 1'b0;
        forever #2 CPUClk = ~CPUClk;
    end
    initial begin // tao CPUClk
        ex = 1'b0;
        forever #200 ex = ~ex;
    end
        initial begin // khoi tao cho transmit
                None = 1'b0;
                Rec = 1'b0;
                Trans = 1'b0;
                Reset = 1'b0;
            #5  Reset = 1'b1;
            #5  Reset = 1'b0;
            #5  Control = 7'b1011001; //Mode = 0, Sync = 0, Baudrate = 1_000_000, Par = 0
            #5  None = 1'b1;
            #5  None = 1'b0;
                Rec = 1'b0;
                Trans = 1'b1;
        end
        
        
        initial begin // tao CPUClk
                forever  begin
                    #198 Data = {$random} % 2;
                end
            end
        initial begin // tao CPUClk
            forever  begin
                #1000 None = ~None;
            end
        end
        
        
        initial begin
            #200000 $finish;
        end
endmodule
