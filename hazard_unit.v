module hazard_unit(
    input [2:0] rs1, rs2, ex_rd, mem_rd,
    input ex_reg_write, mem_reg_write,
    input ex_mem_read,fft,crypto,
    input exception,
    output reg stall,
    output reg [1:0] forward_a, forward_b 
);
    always @(*) begin
        forward_a = (ex_reg_write && (ex_rd == rs1)) ? 2'b10 : 
                   ((mem_reg_write && (mem_rd == rs1)) ? 2'b01 : 2'b00);                  
        forward_b = (ex_reg_write && (ex_rd == rs2)) ? 2'b10 : 
                   ((mem_reg_write && (mem_rd == rs2)) ? 2'b01 : 2'b00);
        stall = ex_mem_read && ((ex_rd == rs1) || (ex_rd == rs2))||fft||crypto||exception ;
    end
endmodule
