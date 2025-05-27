module id_stage(
inout clk,rst,
input [18:0] instruction,
input [18:0] wb_data,
input reg_write,
output [18:0] rs1_data,
output [18:0] rs2_data,
output [4:0] opcode,
output [2:0] rd,rs1,rs2,
output [18:0] immediate,
output reg [1:0] prediction,
output fft, crypto
    );
    
    
    
    regfile rf(.clk(clk),.rd_addr(rd),.rs1_addr(rs1),.rs2_addr(rs2),.wb_data(wb_data),.reg_write(reg_write),.rs1_data(rs1_data),.rs2_data(rs2_data));

assign opcode = instruction[18:14];
assign rd= instruction [13:11];
assign rs1= instruction [10:8];
assign rs2= instruction [7:5];
wire [14:0] tmp = instruction[14:0];
assign immediate = {{4{tmp[14]}}, tmp};

assign fft = (opcode == 5'b11000);
assign crypto = (opcode == 5'b11001 || opcode == 5'b11010);

assign mem_read = (opcode == 5'b01101); 
assign mem_write = (opcode == 5'b01110);

always@(*)begin
case(opcode)
5'b01010,5'b01011,5'b01100:
prediction=2'b10;
default:prediction=2'b00;
endcase
end
endmodule

