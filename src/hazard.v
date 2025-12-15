module hazard_unit(
    input [2:0] rs1,
    input [2:0] rs2,
    input [2:0] ex_rd,
    input ex_reg_write,
    input [2:0] mem_rd,
    input mem_reg_write,
    output reg stall,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
        // Forwarding logic
        forward_a = (ex_reg_write && (ex_rd == rs1)) ? 2'b10 :
                   (mem_reg_write && (mem_rd == rs1)) ? 2'b01 : 2'b00;
                   
        forward_b = (ex_reg_write && (ex_rd == rs2)) ? 2'b10 :
                   (mem_reg_write && (mem_rd == rs2)) ? 2'b01 : 2'b00;
        
        // Load-use hazard
        stall = (ex_reg_write && (ex_rd == rs1 || ex_rd == rs2));
    end
endmodule