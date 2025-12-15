module exception_unit (
    input  wire [4:0] opcode,
    input  wire        div_by_zero,

    output reg         exception,
    output reg  [3:0]  exception_code
);

    always @(*) begin
        exception      = 1'b0;
        exception_code = 4'd0;

        // Divide-by-zero exception
        if (opcode == 5'b00011 && div_by_zero) begin
            exception      = 1'b1;
            exception_code = 4'd1;
        end
    end

endmodule
