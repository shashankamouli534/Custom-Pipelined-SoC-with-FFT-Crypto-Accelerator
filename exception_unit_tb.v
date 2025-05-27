`timescale 1ns/1ps
module exception_unit_tb;
reg [4:0] opcode;
reg divided_by_0;
wire exception;
wire [18:0] handler_address;
exception_unit dut(.opcode(opcode),.divided_by_0(divided_by_0),.exception(exception),.handler_address(handler_address));
initial begin
opcode = 5'b00000;
divided_by_0 = 1;
#5;
opcode = 5'b00011;
#5;
divided_by_0 = 0;
#5;
$finish;
end
endmodule
