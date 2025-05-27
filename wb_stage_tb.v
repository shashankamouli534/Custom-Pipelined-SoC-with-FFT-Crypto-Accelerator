`timescale 1ns/1ps
module wb_stage_tb;
reg [18:0] alu_result, mem_data;
reg [1:0] result_src;
wire [18:0] result;
wb_stage dut(.alu_result(alu_result), .mem_data(mem_data), .result_src(result_src), .result(result));
initial begin
alu_result = 19'd123;
mem_data = 19'd138;
result_src = 2'd0;
#5;
result_src = 2'b01;
#5;
result_src = 2'b10;
#5;
$finish;
end
endmodule
