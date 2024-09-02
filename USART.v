`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2023 10:12:16 AM
// Design Name: 
// Module Name: USART
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


module USART(
    input Reset, // reset toan bo setup ma cpu da dat cho usart
    input None, // None = 0, cpu ko co yeu cau gi voi usart     None = 1, tuy thuoc trang thai cua Rec va Trans
    input Rec,  // Rec = 1, Trans = 0 la cpu dang nhan data     Rec = 1, Trans = 1 la cpu dang setup lai cho usart
    input Trans,// Rec = 0, Trans = 1 la cpu dang truyen data   Rec = 0, Trans = 0 la ko lam gi
    input CPU_Clk, // Clk cua CPU voi usart, khong lien quan gi toi nhan/truyen giua usart nay voi usart khac
    input [6:0] Control,
    inout [7:0] CPU_Data,
    inout ExClk, // clk giua usart nay voi usart khac (dung trong dong bo)
    inout SLBit, // Bit duoc truyen tuan tu giua cac usart
    output [4:0] Status,
	 output INClk,
	 output [10:0] test
    );
    
    reg [6:0] Setup_next;
    reg [6:0] Setup; //Control
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
    
    reg WR;
    reg WR_next;
    wire WR_signal;
    reg RD;
    reg RD_next;
    wire RD_signal;
    wire InClk; // clk cho worker
	 
	 assign INClk = InClk;
    wire ExClk_GEN;
    wire ExClk_Wor;
    wire [13:0] UBRR;
    assign ExClk = (Setup[6])? 1'bz : ExClk_Wor; // Neu la nhan se nhan tin hieu ben ngoai, neu la truyen se nhan tin hieu tu ExClk_Wor
    assign ExClk_GEN = Setup[6]? ExClk : 1'b0;
    always @(*) begin
        if(None == 1'b1) begin
            case({Rec, Trans})
                2'b11: begin // cpu ko co yeu cau gi voi usart
                    WR_next = 1'b1; 
                    RD_next = 1'b1;
						  Setup_next = Setup;
                end
                2'b10: begin // cpu truyen data cho usart
                    WR_next = 1'b0;
                    RD_next = 1'b1;
						  Setup_next = Setup;
                end
                2'b01: begin // cpu nhan data tu usart
                    RD_next = 1'b0;
                    WR_next = 1'b1;
						  Setup_next = Setup;
                end
                2'b00: begin // cpu setup usart
                    WR_next = 1'b1;
                    RD_next = 1'b1;
                    Setup_next = Control; 
                end
            endcase
        end else begin
            WR_next = 1'b1;
            RD_next = 1'b1;
				Setup_next = Setup;
        end
    end
    always @(posedge CPU_Clk, posedge Reset) begin 
        if(Reset) begin
            WR <= 1'b1;
            RD <= 1'b1;
        end else begin
            WR <= WR_next;
            RD <= RD_next;
            Setup <= Setup_next;
        end 
    end
    negedge_detection wr(CPU_Clk, WR, WR_signal);
    negedge_detection rd(CPU_Clk, RD, RD_signal);
    USART_GENClock Generate_clk(Reset, Setup[6], Setup[5], Setup[4:1], CPU_Clk, ExClk_GEN, InClk);
    USART_Worker Worker(Reset, CPU_Clk, InClk, Setup[6], Setup[5], Setup[0], RD_signal, WR_signal, SLBit, CPU_Data, Status[4], Status[3], Status[2], Status[1], Status[0], ExClk_Wor, test);
endmodule
