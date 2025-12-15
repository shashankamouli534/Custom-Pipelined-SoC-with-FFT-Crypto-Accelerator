module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        branch_taken,
    input  wire [18:0] branch_target,

    // Instruction bus interface
    output reg         ibus_valid,
    output reg  [18:0] ibus_addr,
    input  wire [18:0] ibus_rdata,

    output reg  [18:0] pc,
    output reg  [18:0] instruction
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc          <= 19'd0;
            ibus_valid  <= 1'b0;
        end
        else if (!stall) begin
            pc <= branch_taken ? branch_target : pc + 19'd1;
            ibus_valid <= 1'b1;
            ibus_addr  <= pc;
        end
    end

    // Latch fetched instruction
    always @(posedge clk) begin
        if (ibus_valid)
            instruction <= ibus_rdata;
    end

endmodule
