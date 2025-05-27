module crypto_unit(
input clk,rst,start,
input [18:0] input_addr,result_addr,
output reg done,
output reg [9:0] mem_addr,
input [18:0] mem_data_in,
output reg mem_write,
output reg [18:0] mem_data_out
    );
    localparam idle=2'd0,load=2'd1,process=2'd2,store=2'd3;
    reg[127:0] state_reg;
    reg [2:0] word_cnt;//6
    reg [1:0] phase;
    reg[3:0] round;
    reg [7:0] s_box [0:31];
    
    initial begin
        s_box[0] = 8'h3A; s_box[1] = 8'h7F; s_box[2] = 8'hC2; s_box[3] = 8'h19;
        s_box[4] = 8'hA5; s_box[5] = 8'h6E; s_box[6] = 8'hD3; s_box[7] = 8'h40;
        s_box[8] = 8'hB7; s_box[9] = 8'h9C; s_box[10] = 8'h2D; s_box[11] = 8'h53;
        s_box[12] = 8'h0A; s_box[13] = 8'hE1; s_box[14] = 8'h8F; s_box[15] = 8'h76;
        s_box[16] = 8'hDA; s_box[17] = 8'h24; s_box[18] = 8'h95; s_box[19] = 8'h61;
        s_box[20] = 8'h3D; s_box[21] = 8'h87; s_box[22] = 8'hB3; s_box[23] = 8'hF2;
        s_box[24] = 8'h14; s_box[25] = 8'hC8; s_box[26] = 8'h9A; s_box[27] = 8'h0E;
        s_box[28] = 8'h7B; s_box[29] = 8'h5D; s_box[30] = 8'hE9; s_box[31] = 8'h36;
    end
    
    function [7:0] get_s_box(input [7:0]byte);
            get_s_box=s_box[byte[4:0]];
            endfunction
            
    function [127:0] sub_bytes(input [127:0] data);
            integer i;
            reg [127:0] tmp;
            begin
                for(i=0;i<16;i=i+1)
                    tmp[8*i+:8]=get_s_box(data[8*i+:8]);
                    sub_bytes=tmp;
                    end
            endfunction
     function [127:0] shift_rows (input [127:0] data);
            reg[127:0] tmp;
            begin
            tmp[127:120]=data[127:120];
            tmp[119:112]=data[87:80];
            tmp[111:104]=data[47:40];
            tmp[103:96]=data[7:0];
            tmp[95:0]=data[95:0];
            shift_rows=tmp;
            end
            endfunction
    reg [127:0] key= 128'h11111111111111111111111111111111;
        
    always@(posedge clk or negedge rst)begin
    if(!rst) begin
        phase<=idle;
        done<=0;
        mem_addr<=0;
        mem_write<=0;
        word_cnt<=0;
        end
    else
        case(phase)
            idle:begin
                 done<=0;
                 mem_write<=0;
                 if(start)begin
                    if (input_addr[18:16] == 3'b110) 
                    mem_addr <= input_addr[9:0];                   
                    word_cnt<=0;
                    state_reg<=0;
                    phase<=load;
                    end
            end
            load:begin
                state_reg<={state_reg[108:0],mem_data_in};
                if(word_cnt==6)begin
                    state_reg<=state_reg^key;
                    round<=1;
                    phase<=process;
                    end
                else begin
                    mem_addr<=mem_addr+1;
                    word_cnt<=word_cnt+1;
                    end
                end
                
            process:begin
                if(round<=5)begin
                    state_reg <= shift_rows(sub_bytes(state_reg));
                    round<=round+1;
                    end
                 else begin
                    mem_addr<=result_addr;
                    word_cnt<=0;
                    phase<=store;
                    end
                 end
            store:begin  
                mem_data_out<=state_reg[18:0];
                state_reg[18:0]<=state_reg>>19;
                mem_write<=1;
                if(word_cnt==6)begin
                    done<=1;
                    mem_write<=0;
                    phase<=idle;
                    end
                else begin
                    word_cnt<=word_cnt+1;
                    mem_addr<=mem_addr+1;
                    end
                end
                endcase
                
 end   
endmodule
