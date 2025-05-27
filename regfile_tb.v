`timescale 1ns/1ps
module regfile_tb;
reg clk = 0;
reg reg_write;
reg [2:0] rd_addr, rs1_addr, rs2_addr;
reg [18:0] wb_data;
wire [18:0] rs1_data, rs2_data;
regfile dut(.clk(clk), .rd_addr(rd_addr), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .wb_data(wb_data), .reg_write(reg_write), .rs1_data(rs1_data), .rs2_data(rs2_data));
always #5 clk = ~clk;
initial begin
reg_write = 1;
rd_addr = 3'd1;
wb_data = 19'd123;
#10;
reg_write = 0;
rs1_addr = 3'd1;
#10;
$finish;
end
endmodule
