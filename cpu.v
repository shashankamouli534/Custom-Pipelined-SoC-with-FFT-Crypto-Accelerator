module cpu(input clk, input rst);
    // Pipeline registers
    reg [18:0] if_id_pc, id_ex_pc, ex_mem_pc, mem_wb_pc;
    reg [18:0] if_id_instr, id_ex_instr, ex_mem_instr, mem_wb_instr;
    reg [18:0] id_ex_rs1_data, id_ex_rs2_data;
    reg [18:0] ex_mem_alu_result, mem_wb_alu_result;
    reg [18:0] ex_mem_rs2_data, mem_wb_mem_data;
    reg mem_wb_rd,ex_mem_rd,id_ex_rd;
    reg [14:0] id_ex_immediate;
    // Control signals
    reg [4:0] id_ex_opcode, ex_mem_opcode, mem_wb_opcode;
    reg id_ex_reg_write, ex_mem_reg_write, mem_wb_reg_write;
    reg id_ex_mem_write, ex_mem_mem_write;
    reg id_ex_mem_read, ex_mem_mem_read;
    reg id_ex_fft, ex_mem_fft;
    reg id_ex_crypto, ex_mem_crypto;
    
    // Hazard and exception
    wire stall;
    wire [1:0] forward_a, forward_b;
    wire exception;
    wire [18:0] handler_address;
    
    // Memory interface
    wire [18:0] mem_read_data;
    wire [18:0] pc, instruction;
    wire [18:0] branch_target;
    wire branch_taken;
    
    // IF Stage
    if_stage fetch(
        .clk(clk), .rst(rst),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .stall(stall),
        .exception(exception),
        .handler_address(handler_address),
        .pc(pc),
        .instruction(instruction)
    );
    
    // ID Stage
    wire [18:0] id_rs1_data, id_rs2_data, id_immediate;
    wire [4:0] id_opcode;
    wire [2:0] id_rd, id_rs1, id_rs2;
    wire id_fft, id_crypto;
    
    id_stage decode(
        .clk(clk), .rst(rst),
        .instruction(if_id_instr),
        .wb_data(mem_wb_alu_result),
        .reg_write(mem_wb_reg_write),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .opcode(id_opcode),
        .rd(id_rd),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .immediate(id_immediate),
        .fft(id_fft),
        .crypto(id_crypto)
    );
    
    // EX Stage
    wire [18:0] ex_alu_result;
    wire ex_zero_flag, ex_overflow_a, ex_overflow_s, ex_div_zero;
    
    alu exec(
        .opcode(id_ex_opcode),
        .operand_a(forward_a == 2'b00 ? id_ex_rs1_data : 
                  (forward_a == 2'b01 ? ex_mem_alu_result : mem_wb_alu_result)),
        .operand_b(forward_b == 2'b00 ? id_ex_rs2_data : 
                  (forward_b == 2'b01 ? ex_mem_alu_result : mem_wb_alu_result)),
        .result(ex_alu_result),
        .zero_flag(ex_zero_flag),
        .divided_by_0(ex_div_zero),
        .overflow_a(ex_overflow_a),
        .overflow_s(ex_overflow_s),
        .fft_strt(id_ex_fft),
        .crypto_en(id_ex_crypto)
    );
    
    branch_unit branch(
        .opcode(id_ex_opcode),
        .zero_flag(ex_zero_flag),
        .overflow_a(ex_overflow_a),
        .overflow_s(ex_overflow_s),
        .pc(id_ex_pc),
        .offset(id_ex_immediate[14:0]),
        .branch_taken(branch_taken),
        .target_address(branch_target)
    );
    
    // MEM Stage
    mem_stage memory_access(
        .clk(clk),
        .addr(ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),
        .fft_strt(ex_mem_fft),
        .crypto_en(ex_mem_crypto),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .rd_data(id_ex_rd),
        .mem_write(ex_mem_mem_write),
        .mem_read(ex_mem_mem_read),
        .read_data(mem_read_data),
        .fft_key(),
        .crypto_key()
    );
    
    // WB Stage
    wire [18:0] wb_result;
    
    wb_stage write_back(
        .alu_result(mem_wb_alu_result),
        .mem_data(mem_wb_mem_data),
        .result_src(2'b00),
        .result(wb_result)
    );
    
    // Hazard Unit
    hazard_unit hazard(
        .rs1(id_rs1), .rs2(id_rs2),
        .ex_rd(id_ex_rd), .mem_rd(ex_mem_rd),
        .ex_reg_write(id_ex_reg_write),
        .mem_reg_write(ex_mem_reg_write),
        .ex_mem_read(id_ex_mem_read),
        .fft(ex_mem_fft),
        .crypto(ex_mem_crypto),
        .exception(exception),
        .stall(stall),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    
    // Exception Unit
    exception_unit exc(
        .opcode(ex_mem_opcode),
        .divided_by_0(ex_div_zero),
        .overflow_a(ex_overflow_a),
        .overflow_s(ex_overflow_s),
        .exception(exception),
        .handler_address(handler_address)
    );
    
    // Stack Module
    wire [18:0] stack_data;
    stack call_stack(
        .clk(clk), .rst(rst),
        .call(id_ex_opcode == 5'b01101),
        .ret(id_ex_opcode == 5'b01110),
        .stack_data(stack_data)
    );

    // Pipeline registers
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // IF/ID
            if_id_pc <= 0;
            if_id_instr <= 0;
            
            // ID/EX
            id_ex_pc <= 0;
            id_ex_instr <= 0;
            id_ex_rs1_data <= 0;
            id_ex_rs2_data <= 0;
            id_ex_opcode <= 0;
            id_ex_rd <= 0;
            id_ex_reg_write <= 0;
            id_ex_mem_write <= 0;
            id_ex_mem_read <= 0;
            id_ex_fft <= 0;
            id_ex_crypto <= 0;
            
            // EX/MEM
            ex_mem_pc <= 0;
            ex_mem_alu_result <= 0;
            ex_mem_rs2_data <= 0;
            ex_mem_opcode <= 0;
            ex_mem_rd <= 0;
            ex_mem_reg_write <= 0;
            ex_mem_mem_write <= 0;
            ex_mem_mem_read <= 0;
            ex_mem_fft <= 0;
            ex_mem_crypto <= 0;
            
            // MEM/WB
            mem_wb_pc <= 0;
            mem_wb_alu_result <= 0;
            mem_wb_mem_data <= 0;
            mem_wb_opcode <= 0;
            mem_wb_rd <= 0;
            mem_wb_reg_write <= 0;
        end
        else if (!stall) begin
            // IF/ID
            if_id_pc <= pc;
            if_id_instr <= instruction;
            
            // ID/EX
            id_ex_pc <= if_id_pc;
            id_ex_instr <= if_id_instr;
            id_ex_rs1_data <= id_rs1_data;
            id_ex_rs2_data <= id_rs2_data;
            id_ex_opcode <= id_opcode;
            id_ex_rd <= id_rd;
            id_ex_reg_write <= (id_opcode != 5'b00000);
            id_ex_mem_write <= (id_opcode == 5'b01010);
            id_ex_mem_read <= (id_opcode == 5'b01011);
            id_ex_fft <= id_fft;
            id_ex_crypto <= id_crypto;
            
            // EX/MEM
            ex_mem_pc <= id_ex_pc;
            ex_mem_alu_result <= ex_alu_result;
            ex_mem_rs2_data <= id_ex_rs2_data;
            ex_mem_opcode <= id_ex_opcode;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_write <= id_ex_mem_write;
            ex_mem_mem_read <= id_ex_mem_read;
            ex_mem_fft <= id_ex_fft;
            ex_mem_crypto <= id_ex_crypto;
            
            // MEM/WB
            mem_wb_pc <= ex_mem_pc;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_mem_data <= mem_read_data;
            mem_wb_opcode <= ex_mem_opcode;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
        end
        
        if (exception) begin
            if_id_instr <= 0;
            id_ex_opcode <= 0;
            ex_mem_opcode <= 0;
        end
    end
endmodule
