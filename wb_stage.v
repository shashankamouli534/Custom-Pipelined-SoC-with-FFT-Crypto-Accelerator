module wb_stage(
input [18:0]alu_result,
input [18:0] mem_data,
input [1:0] result_src,
output [18:0] result
    );
    assign result=(result_src==2'b00)?alu_result:(result_src==2'b01)?mem_data:19'd0;
endmodule
