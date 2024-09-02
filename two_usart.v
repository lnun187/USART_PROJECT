`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2024 10:27:24 PM
// Design Name: 
// Module Name: two_usart
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


module two_usart(
    input Reset,
    input None, // None = 0, cpu ko co yeu cau gi voi usart     None = 1, tuy thuoc trang thai cua Rec va Trans
    input Rec,  // Rec = 1, Trans = 0 la cpu dang nhan data     Rec = 1, Trans = 1 la cpu dang setup lai cho usart
    input Trans,// Rec = 0, Trans = 1 la cpu dang truyen data   Rec = 0, Trans = 0 la ko lam gi
    input CPU_Clk, // Clk cua CPU voi usart, khong lien quan gi toi nhan/truyen giua usart nay voi usart khac
    input [5:0] Control,
    input [7:0] CPU_Data_in,
    output INClk,
    output ExClk,
    output SLBit,
    output [7:0] CPU_Data_out
    );
    
    wire ExClk_internal;
    wire SLBit_internal;
    wire [4:0] Status_trans;
    wire [4:0] Status_rec;

    wire INClk_trans;
    wire INClk_rec;
    wire [10:0] test_trans;
    wire [10:0] test_rec;
    
    assign INClk = INClk_trans;
    assign ExClk = ExClk_internal;
    assign SLBit = SLBit_internal;
    USART transmitter(Reset, None, Rec, Trans, CPU_Clk, {1'b0, Control}, CPU_Data_in, ExClk_internal, SLBit_internal, Status_trans, INClk_trans, test_trans);
    USART receiver(Reset, None, Rec, Trans, CPU_Clk, {1'b1, Control}, CPU_Data_out, ExClk_internal, SLBit_internal, Status_rec, INClk_rec, test_rec);

endmodule
