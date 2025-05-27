`timescale 1ns/1ps
module alu_tb;
reg [4:0]opcode;
reg [18:0]operand_a,operand_b;
wire [18:0]result;
wire zero_flag,divided_by_0,fft_strt,crypto_en,overflow_a,overflow_s;
alu dut(.opcode(opcode),.operand_a(operand_a),.operand_b(operand_b),.result(result),.zero_flag(zero_flag),.divided_by_0(divided_by_0),.fft_strt(fft_strt),.crypto_en(crypto_en),.overflow_a(overflow_a),.overflow_s(overflow_s));
initial begin

opcode=5'b00000;operand_a=19'h7FFFF;operand_b=19'h1;#10;
opcode=5'b00001;operand_a=19'h0;operand_b=19'h1;#10;
opcode=5'b00011;operand_a=19'h7FFFF;operand_b=19'h0;#10;
opcode=5'b11000;#10;
opcode=5'b11001;#10;
opcode=5'b11010;#10;

$finish;
end
endmodule
