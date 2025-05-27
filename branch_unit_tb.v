`timescale 1ns/1ps
module branch_unit_tb;
reg [4:0]opcode;
reg zero_flag,overflow_a,overflow_s;
reg [18:0]pc;reg [14:0]offset;
wire branch_taken;
wire [18:0]target_address;
branch_unit dut(.opcode(opcode),.zero_flag(zero_flag),.overflow_a(overflow_a),.overflow_s(overflow_s),.pc(pc),.offset(offset),.branch_taken(branch_taken),.target_address(target_address));
initial begin
opcode=5'b01010;zero_flag=0;overflow_a=0;overflow_s=0;pc=19'd138;offset=15'd5;
#5;
opcode=5'b01011;zero_flag=1;overflow_a=0;overflow_s=0;pc=19'd138;offset=15'd5;
#5;
opcode=5'b01100;zero_flag=0;overflow_a=0;overflow_s=1;pc=19'd138;offset=15'd5;
#5;
$finish;
end
endmodule
