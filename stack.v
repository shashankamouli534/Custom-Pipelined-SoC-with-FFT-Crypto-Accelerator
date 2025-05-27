module stack(
input clk,rst,call,ret,
output reg [7:0]sp,
output [18:0] stack_data
    );
    reg [18:0] stack [0:255];
    parameter isp= 8'h38;
    integer i=0;
    initial begin
        for ( i=0;i<256;i=i+1)
        stack[i]=19'h0;
    end
    always@(posedge clk or negedge rst)begin
    if (!rst)sp<=isp;
    else begin
    if (call)sp<=sp-1;
    if (ret)sp<=sp+1;
    end
    end
    assign stack_data=stack[sp];
endmodule
