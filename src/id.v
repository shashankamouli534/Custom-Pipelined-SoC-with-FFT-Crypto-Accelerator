module id_stage(
    input [18:0] instruction,
    output [4:0] opcode,
    output [2:0] rd,
    output [2:0] rs1,
    output [2:0] rs2,
    output [14:0] immediate,
    output reg [1:0] prediction
);
    assign opcode = instruction[18:14];
    assign rd = instruction[13:11];
    assign rs1 = instruction[10:8];
    assign rs2 = instruction[7:5];
    assign immediate = instruction[14:0];
    
    // Simple branch prediction
    always @(*) begin
        case(opcode)
            5'b01010, 5'b01011, 5'b01100: prediction = 2'b10; // Strongly taken
            default: prediction = 2'b00; // Not branch
        endcase
    end
endmodule