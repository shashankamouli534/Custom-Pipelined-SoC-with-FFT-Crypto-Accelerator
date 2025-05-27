`timescale 1ns/1ps
module fft_tb;
reg clk, rst, start;
reg [18:0] input_addr, mem_data_in;
wire done, mem_write;
wire [9:0] mem_addr;
wire [18:0] mem_data_out;
reg [18:0] fft_mem[0:15];
integer i;
fft_unit dut(.clk(clk), .rst(rst), .start(start), .input_addr(input_addr), .mem_data_in(mem_data_in), .done(done), .mem_write(mem_write), .mem_addr(mem_addr), .mem_data_out(mem_data_out));
initial clk = 0;
always #5 clk = ~clk;
always @(*) mem_data_in = fft_mem[mem_addr];
always @(posedge clk) if (mem_write) fft_mem[mem_addr] <= mem_data_out;
initial begin
rst = 0;
start = 0;
input_addr = 0;
#20;
rst = 1;
fft_mem[0] = 19'h10000;
fft_mem[1] = 19'h00000;
for (i = 2; i < 16; i = i + 1) fft_mem[i] = 0;
#10;
start = 1;
#10;
start = 0;
wait(done);
for (i = 0; i < 8; i = i + 1) begin
$display("", i, fft_mem[2*i], fft_mem[2*i+1]);
if (fft_mem[2*1] !== 19'h10000 || fft_mem[2*i+1] !== 19'h00000) $display("error");
end
$finish;
end
endmodule
