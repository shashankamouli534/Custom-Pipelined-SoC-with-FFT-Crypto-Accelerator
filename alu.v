
module alu(
input [4:0]opcode,
input [18:0]operand_a,operand_b,
output reg fft_strt,crypto_en,
output reg [18:0] result,
output reg zero_flag,divided_by_0,
output reg overflow_a,overflow_s
    );
   always@(*)begin
   result = 0;
   zero_flag = 0;
   divided_by_0 = 0;
   case(opcode)

//0  = add
//1  = sub
//2  = mul
//3  = div
//4  = and
//5  = or
//6  = xor
//7  = not
//8  = inc
//9  = dec
//10 = jmp
//11 = beq
//12 = bne
//24 = fft
//25 = enc
//26 = dec(crypto)


   5'b00000:begin
            result=operand_a+operand_b;
            overflow_a = (operand_a[18] == operand_b[18]) && (result[18] != operand_a[18]);
            end
   5'b00001:begin
            result=operand_a-operand_b;
            overflow_s=(operand_a[18]&&operand_b[18]);
            end
   5'b00010:result=operand_a*operand_b;
   5'b00011:begin
       if (operand_b == 0) begin
            divided_by_0 = 1;
            result = 19'H7FFFF;
            end 
       else begin
            result = operand_a / operand_b;
            end
            end 
   5'b00100:result=operand_a&operand_b;
   5'b00101:result=operand_a|operand_b;
   5'b00110:result=operand_a^operand_b;
   5'b00111:result=~operand_a;
   5'b01000:result=operand_a+1;
   5'b01001:result=operand_a-1;
   5'b11000: begin
            fft_strt <= 1;
            result = 19'h0;
        end
    5'b11001: begin
            crypto_en <= 1;
            result = 19'h0; 
        end
    5'b11010: begin
            crypto_en <= 1;
            result = 19'h0;
        end 
    default: result=0;
endcase
if(result==0&&divided_by_0==0)
zero_flag=1;
end

endmodule
