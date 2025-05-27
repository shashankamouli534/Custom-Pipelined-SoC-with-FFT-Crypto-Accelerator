`timescale 1ns/1ps
module hazard_unit_tb;
reg [2:0] rs1, rs2, ex_rd, mem_rd;
reg ex_reg_write, mem_reg_write, ex_mem_read;
wire stall;
wire [1:0] forward_a, forward_b;
hazard_unit dut(.rs1(rs1),.rs2(rs2),.ex_rd(ex_rd),.mem_rd(mem_rd),.ex_reg_write(ex_reg_write),.mem_reg_write(mem_reg_write),.stall(stall),.forward_a(forward_a),.forward_b(forward_b),.ex_mem_read(ex_mem_read));
initial begin
rs1 = 3'd1;
rs2 = 3'd2;
ex_rd = 3'd3;
ex_reg_write = 0;
mem_rd = 3'd4;
mem_reg_write = 0;
ex_mem_read = 0;
#5;
rs1 = 3'd1;
rs2 = 3'd2;
ex_rd = 3'd1;
ex_reg_write = 1;
mem_rd = 3'd4;
mem_reg_write = 0;
ex_mem_read = 1;
#5;
rs1 = 3'd1;
rs2 = 3'd2;
ex_rd = 3'd3;
ex_reg_write = 0;
mem_rd = 3'd1;
mem_reg_write = 1;
#5;
$finish;
end
endmodule
