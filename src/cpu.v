module cpu_core (
    input  wire        clk,
    input  wire        rst_n,

    // SoC bus
    output reg         bus_valid,
    output reg         bus_write,
    output reg  [18:0] bus_addr,
    output reg  [18:0] bus_wdata,
    input  wire [18:0] bus_rdata
);

    // ---------------- IF ----------------
    wire [18:0] if_pc;
    wire [18:0] if_instr;

    // ---------------- ID ----------------
    wire [4:0]  opcode;
    wire [2:0]  rd, rs1, rs2;
    wire [14:0] imm;

    // ---------------- EX ----------------
    wire [18:0] rs1_data, rs2_data;
    wire [18:0] alu_result;
    wire        zero_flag;
    wire        div_by_zero;

    // ---------------- WB ----------------
    wire [18:0] wb_data;
    wire        reg_write;

    // ---------------- Control ----------------
    wire is_load  = (opcode == 5'b01000);
    wire is_store = (opcode == 5'b01001);
    wire mem_access = is_load | is_store;

    // ---------------- IF stage ----------------
    if_stage ifs (
        .clk(clk),
        .rst_n(rst_n),
        .stall(mem_access),          // ⭐ stall IF during MEM access
        .branch_taken(1'b0),
        .branch_target(19'd0),
        .ibus_valid(),               // unused explicit signal
        .ibus_addr(),                // unused explicit signal
        .ibus_rdata(bus_rdata),
        .pc(if_pc),
        .instruction(if_instr)
    );

    // ---------------- ID stage ----------------
    id_stage id (
        .instruction(if_instr),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(imm),
        .prediction()
    );

    // ---------------- Register File ----------------
    regfile rf (
        .clk(clk),
        .rd_addr(rd),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .wb_data(wb_data),
        .reg_write(reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ---------------- ALU ----------------
    alu alu_u (
        .opcode(opcode),
        .operand_a(rs1_data),
        .operand_b(rs2_data),
        .result(alu_result),
        .zero_flag(zero_flag),
        .div_by_zero(div_by_zero)
    );

    // ---------------- Bus access ----------------
always @(*) begin
    bus_valid = mem_access;
    bus_write = is_store;
    bus_addr  = alu_result;
    bus_wdata = rs2_data;
end



    // ---------------- Writeback ----------------
    assign wb_data =
        (is_load)  ? bus_rdata :
                     alu_result;

    assign reg_write = ~is_store & ~is_load;

endmodule
