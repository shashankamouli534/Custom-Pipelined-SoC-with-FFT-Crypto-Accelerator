module alu(
    input [4:0] opcode,
    input [18:0] operand_a,
    input [18:0] operand_b,
    output reg [18:0] result,
    output reg zero_flag,
    output reg div_by_zero
);
    always @(*) begin
        result = 19'd0;
        div_by_zero = 1'b0;

        case(opcode)
            5'b00000: result = operand_a + operand_b;
            5'b00001: result = operand_a - operand_b;
            5'b00010: result = operand_a * operand_b;
            5'b00011: begin
                div_by_zero = (operand_b == 0);
                result = (operand_b == 0) ? 19'h7FFFF : operand_a / operand_b;
            end
            5'b00100: result = operand_a & operand_b;
            5'b00101: result = operand_a | operand_b;
            5'b00110: result = operand_a ^ operand_b;
            5'b00111: result = ~operand_a;
            5'b01000: result = operand_a + 1;
            5'b01001: result = operand_a - 1;
        endcase

        zero_flag = (result == 0);
    end
endmodule
