module exception_unit(
input [4:0] opcode,
input divided_by_0,
input overflow_a,overflow_s,
output reg exception,
output reg [18:0] handler_address
    );
    always@(*)begin
    exception=0;
    handler_address=19'd0;
    
    if (opcode==5'b00011&& divided_by_0==1)begin
        exception=1'b1;
        handler_address=19'h7fff0;
        end
    else if ((opcode==5'd0&&overflow_a)||(opcode==5'd1&&overflow_s))begin
        exception=1'b1;
        handler_address=19'h7fff1;
        end    
end    
endmodule
