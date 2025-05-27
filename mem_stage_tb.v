`timescale 1ns/1ps
module mem_stage_tb;
reg clk = 0;
reg [18:0] addr, write_data, rs1_data, rs2_data, rd_data;
reg fft_strt, crypto_en, mem_write, mem_read;
wire [18:0] read_data;
wire fft_key, crypto_key;
mem_stage dut(.clk(clk), .addr(addr), .write_data(write_data), .fft_strt(fft_strt), .crypto_en(crypto_en), .rs1_data(rs1_data), .rs2_data(rs2_data), .rd_data(rd_data), .mem_write(mem_write), .mem_read(mem_read), .read_data(read_data), .fft_key(fft_key), .crypto_key(crypto_key));
always #5 clk = ~clk;
initial begin
addr = 0;
write_data = 0;
rs1_data = 0;
rs2_data = 0;
rd_data = 0;
fft_strt = 0;
crypto_en = 0;
mem_write = 0;
mem_read = 0;
#10;
mem_write = 1;
addr = 19'h100;
write_data = 19'd123;
#10;
mem_write = 0;
mem_read = 1;
#10;
fft_strt = 1;
addr = 19'h7F000;
write_data = 19'd138;
#10;
fft_strt = 0;
mem_read = 1;
#10;
crypto_en = 1;
addr = 19'h6000;
write_data = 19'd255;
#10;
crypto_en = 0;
mem_read = 1;
#10;
$finish;
end
endmodule
