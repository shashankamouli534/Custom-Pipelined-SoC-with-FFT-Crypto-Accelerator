`timescale 1ns/1ps
module stack_tb;
reg clk = 0;
reg rst = 0;
reg call = 0;
reg ret = 0;
wire [7:0] sp;
wire [18:0] stack_data;
stack dut(.clk(clk),.rst(rst),.call(call),.ret(ret),.sp(sp),.stack_data(stack_data));
always #5 clk = ~clk;
initial begin
rst = 0;
#5;
rst = 1;
#10;
call = 1;
#10;
call = 0;
#10;
ret = 1;
#10;
ret = 0;
#10;
$finish;
end
endmodule
