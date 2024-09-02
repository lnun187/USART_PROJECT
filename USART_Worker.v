`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2023 10:12:16 AM
// Design Name: 
// Module Name: USART_Worker
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


module USART_Worker(
	input Reset, 				// Reset
	input CPU_Clk,				// Clk cua fpga
	input InClk, 				// Clk dung cho truyen va nhan bat dong bo
	input Mode, 				// Mode = 1 : che do nhan							Mode = 0 : Che do truyen
	input Sync, 				// Sync = 1 : dong bo								Sync = 0 : bat dong bo
	input Par,					// Par = 1 : co su dung parity bit				Par = 0 : ko su dung parity bit
	input RD,					// RD = 1 khi CPU yeu cau doc du lieu trong che do nhan
	input WR,					// WR = 1 khi CPU yeu cau viet trong che do truyen
	inout SLBit,				// Inout truyen nhan tuan tu tung bit trong data frame
	inout [7:0] CPU_Data,	// Noi CPU se truyen/nhan data ma USART truyen/nhan duoc
	output CP,					// CP = 1 khi bo nho trong va khong dang truyen/nhan du lieu nao
	output OV,					// OV = 1 khi bo nho day
	output AV,					// AV = 1 khi du lieu trong
	output FE,			// FE = 1 khi data frame co loi ve stopbit
	output reg PE,			// PE = 1 khi data frame co loi ve parity bit
	output reg ExClk,			// Clk su dung o che do truyen dong bo dung de truyen tin hieu dong bo cho thiet bi khac
	output [10:0] test
	);
    //*****************************************************************************************************
    //                                                 KHAI BAO
	//*****************************************************************************************************
    reg ExClk_next;
    reg [10:0] out_reg;
    reg [10:0] out_reg_next;
	reg tmp_out; 				// Bien tam gan cho SLBit
	reg tmp_out_next;
	reg [10:0] buf_reg;		// Bo nho dem
	reg [10:0] buf_reg_next;		// Bo nho dem
	reg RC; 					// out_reg su dung, khi da gui xong (truyen) hoac nhan xong (nhan) thi RC = 1
	reg RC_next;
	reg CC;
    reg CC_next;
    reg PE_next;
    reg MC;						// buf_reg su dung, khi da check hoan tat (truyen) va ko loi (nhan) thi CC = 1
	reg [3:0] Nbits;			// Bien luu tru so luong bit trong data frame (tinh ca start, stop bit)
	integer i; 				// dem so bit da nhan (out_reg)
	integer i_next;        // gia tri tiep theo cua i
	reg [3:0] lp; 			//loop
	integer dem; 				// dung khi o che do 4 bit	##Dang khong dung toi
	wire par_gen;
	wire par_check;
	wire pos_InClk;
	wire neg_InClk;
	wire [7:0] data_out;
	//*****************************************************************************************************
	//                                                 ASSIGN
	//*****************************************************************************************************
	assign test = data_out;
	assign SLBit = Mode ? 1'bz : tmp_out; // khi che do nhan SLBit la inpput, khi che do truyen, SLBit thay doi dong thoi voi
														// out_reg[0] (SLBit la output)
	assign CP = (AV && buf_reg == 11'b111_1111_1111 && out_reg == 11'b111_1111_1111) 
							 ? 1'b1 : 1'b0; 				// neu bo nho trong va outreg la IDLE la xong
	assign CPU_Data = Mode ? data_out : 8'bz; 		// Neu la nhan thi la output, neu la truyen se la input
	assign FE = (Sync || out_reg[Nbits]) ? 1'b0 : 1'b1;
	even_parity_gen gen(data_out, par_gen);
	even_parity_checker check(Sync ? out_reg[8:0] : out_reg[9:1], par_check);
	posedge_detection pos(CPU_Clk, InClk, pos_InClk);
	negedge_detection neg(CPU_Clk, InClk, neg_InClk);
	
	//*****************************************************************************************************
    //                                                 DAT SO LUONG BIT TRONG DATA
    //*****************************************************************************************************
    //Set  so luong bit trong data, dung cho ca truyen va nhan
	always @(*) begin // so luong bit co trong mot frame
		case({Sync, Par})
			2'b00: Nbits = 4'd9;
			2'b01: Nbits = 4'd10;
			2'b10: Nbits = 4'd7;
			2'b11: Nbits = 4'd8;
			default: Nbits = 4'd0;
		endcase
	end
	//*****************************************************************************************************
    //                                                 OUT_REG
	//*****************************************************************************************************
    //                                                          combinational logic of out_reg
    always @(*) begin
        i_next = i; // default value
        if(pos_InClk && ~Mode || neg_InClk && Mode) begin
            if(i == 0 && (SLBit == 1'b0 || Sync || ~Mode)) i_next = 1;
            else if(i != 0 && i != Nbits) i_next = i + 1;
            else i_next = 0;
        end
        out_reg_next = out_reg; // default value
        if(pos_InClk && ~Mode && i == Nbits) out_reg_next <= buf_reg;
        else if(neg_InClk && Mode) begin
            out_reg_next[i] = SLBit;
        end
        RC_next = 1'b0;// default value
        if(i == Nbits && (pos_InClk && ~Mode || neg_InClk && Mode)) RC_next = 1'b1;
        tmp_out_next = tmp_out;// default value
        if(pos_InClk && ~Mode) tmp_out_next = out_reg[i];
        ExClk_next = ExClk;// default value
        if(pos_InClk && ~Mode) ExClk_next = (out_reg != 11'b111_1111_1111 && ~Mode && Sync)? InClk : 1'b0;
    end
    //                                                          out_reg che do truyen + nhan
    always @(posedge CPU_Clk, posedge Reset ) begin
		if(Reset) begin
			i <= 0;
			tmp_out <= 1'b1;
			out_reg <= 11'b1111_1111_111;
			RC <= 1'b0;
			ExClk <= 1'b0;
		end else begin
            RC <= RC_next;  
            tmp_out <= tmp_out_next;
            ExClk <= ExClk_next;            
            i <= i_next;
            out_reg <= out_reg_next;
		end
	end
	//*****************************************************************************************************
	//                                                 BUF_REG
	//*****************************************************************************************************
    //                                                 combinational logic of buf_reg
	always @(*) begin
        buf_reg_next = 11'b111_1111_1111;
		if(~Mode) begin // che do truuyen
			if(!AV)
                case(Nbits) // dang chua co truong hop xai parity bit
                     4'd7: buf_reg_next = {3'b000, data_out};
                     4'd8: buf_reg_next = {2'b00, par_gen, data_out};
                     4'd9: buf_reg_next = {2'b11, data_out, 1'b0};
                     4'd10:buf_reg_next = {1'b1, par_gen, data_out, 1'b0};
                     default: begin
                          buf_reg_next = 11'b111_1111_1111; 
                     end
                endcase
		end else begin // che do nhan
			if((out_reg[Nbits] == 1'b1 || Sync) && (~Par || Par&&~par_check))
				buf_reg_next = {3'b000, (Sync ? out_reg[7:0] : out_reg[8:1])};
        end
        if(RC && par_check && Mode && Par) PE_next = 1'b1;
        else PE_next = 1'b0;
        if(RC && buf_reg_next != 11'b111_1111_1111) CC_next = 1'b1;
        else CC_next = 1'b0;
	end
    //                                                  buf_reg che do truyen + nhan
    always @(posedge Reset, posedge CPU_Clk) begin // vi che do truyen nen chi su dung 8 bit dau cua buf_reg hay buf_reg[7:0]
		if(Reset) begin
			buf_reg <= 11'b111_1111_1111;
		end
		else if(RC) begin
			buf_reg <= buf_reg_next;
		end 		
	end
	always @(posedge Reset, posedge CPU_Clk) begin // vi che do truyen nen chi su dung 8 bit dau cua buf_reg hay buf_reg[7:0]
        if(Reset) begin
            CC <= 1'b0;
            PE <= 1'b0;
        end
        else begin
            PE <= PE_next;
            CC <= CC_next;
        end         
    end
	//*****************************************************************************************************
	//                                                 MEMORY
	//*****************************************************************************************************
    fifo mem(CPU_Clk, Reset, ~Mode ? CPU_Data : buf_reg[7:0], (WR && ~Mode) || (CC && Mode), (RD && Mode) ||  (CC && ~Mode), data_out, OV, AV);
endmodule
