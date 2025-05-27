module regfile(
input clk,
input [2:0]rd_addr,
input [2:0]rs1_addr,
input [2:0]rs2_addr,
input [18:0]wb_data,
input reg_write,
output [18:0] rs1_data,
output [18:0] rs2_data
);
    reg [18:0] registers [0:7];  // 8 registers
    
    always@(posedge clk)begin
        if (reg_write && rd_addr!=0)
        registers[rd_addr]<=wb_data;
    end
    
    assign rs1_data = registers[rs1_addr];
    assign rs2_data = registers[rs2_addr];
endmodule