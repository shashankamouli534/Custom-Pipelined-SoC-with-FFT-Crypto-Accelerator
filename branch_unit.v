module branch_unit(
input [4:0] opcode,
input zero_flag,overflow_a,overflow_s,
input [18:0] pc,
input [14:0] offset,
output reg branch_taken,
output [18:0] target_address
    );
    wire signed [18:0] sign_extended={{4{offset[14]}},offset};
    always@(*)begin
    case(opcode)
    5'b01010:branch_taken=1'b1;
    5'b01011:branch_taken=zero_flag||overflow_a;
    5'b01100:branch_taken=~zero_flag||overflow_s;
    default:branch_taken=0;
    endcase
    end
    

    
    assign target_address= pc+(sign_extended);
    
endmodule
