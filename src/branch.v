module branch_unit(
    input [4:0] opcode,
    input zero_flag,
    input [18:0] pc,
    input [14:0] offset,
    output reg branch_taken,
    output [18:0] target_address
);
    wire signed [18:0] sign_extended = {{4{offset[14]}}, offset};
    
    always @(*) begin
        case(opcode)
            5'b01010: branch_taken = 1'b1;       // JMP
            5'b01011: branch_taken = zero_flag;  // BEQ
            5'b01100: branch_taken = ~zero_flag; // BNE
            default: branch_taken = 1'b0;
        endcase
    end
    
    assign target_address = pc + (sign_extended << 1);
endmodule