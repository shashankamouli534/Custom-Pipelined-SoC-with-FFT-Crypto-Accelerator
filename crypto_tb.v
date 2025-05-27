`timescale 1ns/1ps
module crypto_tb;
reg clk,rst,start;
reg [18:0] input_addr,result_addr,mem_data_in;
wire done;
wire [9:0] mem_addr;
wire mem_write;
wire [18:0] mem_data_out;
reg [18:0] crypto_mem[0:15];

crypto_unit dut(.clk(clk),.rst(rst),.start(start),.input_addr(input_addr),.result_addr(result_addr),.mem_data_in(mem_data_in),.done(done),.mem_write(mem_write),.mem_addr(mem_addr),.mem_data_out(mem_data_out));

initial clk=0;always #5 clk=~clk;
always@(*)
mem_data_in=crypto_mem[mem_addr];
always@(posedge clk)
if(mem_write)crypto_mem[mem_addr]<=mem_data_out;

initial begin
rst=0;start=0;
input_addr=0;
result_addr=7;
#20;
rst=1;
crypto_mem[0]=19'h10000;
crypto_mem[1]=19'h00000;
crypto_mem[2]=19'h10001;
crypto_mem[3]=19'h00011;
crypto_mem[4]=19'h10111;
crypto_mem[5]=19'h01111;
crypto_mem[6]=19'h00000;
#10;
start=1;
#10;
start=0;
wait(done);
$finish;
end
endmodule
