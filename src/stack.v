module stack_ctrl(
    input clk,
    input rst_n,
    input call,
    input ret,
    output reg [18:0] sp,
    output [18:0] stack_data
);
    reg [18:0] stack [0:255];
    parameter INITIAL_SP = 19'h1FFFF;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) sp <= INITIAL_SP;
        else begin
            if (call) sp <= sp - 1;
            if (ret) sp <= sp + 1;
        end
    end
    
    assign stack_data = stack[sp];
endmodule