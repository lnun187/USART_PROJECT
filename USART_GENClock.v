`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2023 10:12:16 AM
// Design Name: 
// Module Name: USART_GENClock
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


module USART_GENClock(
    input Reset,
    input Mode,
    input Sync,
    input [3:0] Baudrate,
    input CPUClk,
    input ExClk,
    output INClk
    );
    integer UBRR ;
    reg InClk;
    reg InClk_next;
    reg [13:0] count;
    reg [13:0] count_next;
    assign INClk = (Mode && Sync) ? ExClk : InClk; // chi khi usart o che do nhan dong bo thi worker moi xai ExClk
    always @(*) begin // tao UBRR lan lap
        case(Baudrate)
				4'd0: UBRR = 10415; // 2400
				4'd1: UBRR = 5207; //4800
				4'd2: UBRR = 2603; //9600
				4'd3: UBRR = 1_735; //14_400
				4'd4: UBRR = 1_301; //19_200
				4'd5: UBRR = 867; //28_800
				4'd6: UBRR = 650; //38_400
				4'd7: UBRR = 433; //57_600
				4'd8: UBRR = 324; //76_800
				4'd9: UBRR = 216; //115_200
				4'd10:UBRR = 107; //230_400
				4'd11:UBRR = 99; //250_000
				4'd12:UBRR = 49; //500_000
				4'd13:UBRR = 24; //1_000_000
				default: UBRR = 0;
        endcase
    end
    always @(*) begin
        if(count >= UBRR) begin
            InClk_next = ~InClk;
            count_next = 14'd1;
        end
        else begin
            count_next = count + 1'b1;
            InClk_next = InClk;
        end
    end
    always @(posedge CPUClk, posedge Reset) begin // tao InClk cho worker
        if(Reset) begin
            InClk <= 1'b0;
            count <= 14'd0;
        end else begin
            InClk <= InClk_next;
            count <= count_next;
        end
    end
endmodule
