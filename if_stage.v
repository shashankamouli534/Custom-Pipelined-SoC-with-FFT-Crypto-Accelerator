module if_stage(
input clk,rst,branch_taken,stall,
input [18:0] branch_target,
input exception,
input [18:0] handler_address,
output [18:0] pc,instruction,
output reg [18:0] epc,
output flush
    );
reg [18:0] pc_reg;


memory mem(.addr(pc_reg),.read_data(instruction),.mem_read(1'b1));

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            pc_reg <= 19'h0;
            epc <= 19'h0;
        end else begin
            if (exception) 
                epc <= pc_reg;            
            if (!stall) begin
                pc_reg <= exception ? handler_address : 
                         branch_taken ? branch_target : 
                         pc_reg + 1;
            end
        end
    end

assign pc = pc_reg;
assign flush = exception;
endmodule