`timescale 1ns / 1ps
module id_stage_tb;
reg [18:0] instruction;
wire [4:0] opcode;
wire [2:0] rd,rs1,rs2;
wire [14:0] immediate;
wire [1:0] prediction;
id_stage dut(.instruction(instruction),.opcode(opcode),.rd(rd),.rs1(rs1),.rs2(rs2),.immediate(immediate),.prediction(prediction));
initial begin
instruction = {5'b00010,3'b001,3'b010,3'b011,6'b000000,3'b000};//R-test
#5;
if(opcode!==5'd2||rd!==3'd1||rs1!==3'd2||rs2!==3'd3)
$error("R failed");
instruction=19'b00011100101110101010101010101;
#5;
if(immediate!==15'b101010101010101)
$error ("immediate fail");
$finish;
end
endmodule