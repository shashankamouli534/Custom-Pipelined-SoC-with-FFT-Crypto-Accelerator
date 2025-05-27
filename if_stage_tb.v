`timescale 1ns/1ps
module if_stage_tb;
reg clk, rst, branch_taken, stall;
reg [18:0] branch_target;
wire [18:0] pc, instruction;
if_stage dut(.clk(clk), .rst(rst), .branch_taken(branch_taken), .stall(stall), .branch_target(branch_target), .pc(pc), .instruction(instruction));
initial clk = 0;
always #5 clk = ~clk;
initial begin
rst = 1;
branch_taken = 0;
stall = 0;
branch_target = 0;
#10;
rst = 0;
#10;
branch_taken = 1;
branch_target = 19'd138;
#10;
branch_taken = 0;
#10;
stall = 1;
#10;
$finish;
end
endmodule
