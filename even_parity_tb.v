`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2024 05:12:40 PM
// Design Name: 
// Module Name: even_parity_tb
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


module even_parity_tb;
    reg [7:0] data_in;
    wire parity_bit;
    even_parity_gen par(data_in, parity_bit);
    initial begin
        data_in = 8'b0000_1001;
        #5 data_in = 8'b0001_1001;
        #5 data_in = 8'b0110_1001;
    end
endmodule
