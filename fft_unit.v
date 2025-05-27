module fft_unit(
input clk,rst,start,
input [18:0] input_addr,mem_data_in,
output reg done,mem_write,
output reg [9:0] mem_addr,
output reg [18:0] mem_data_out
    );
parameter N=8;parameter stages=3;parameter data=19;
reg[data-1:0] buffer_real [0:N-1];
reg[data-1:0] buffer_imag [0:N-1];

reg[data-1:0] twiddle_real [0:N];
reg[data-1:0] twiddle_imag [0:N];

reg [3:0] state;
reg [2:0] stage,bfg,bfp,ele_cnt;

integer index_a;
integer index_b;
integer twiddle_index;

            task butterfly(input [2:0] a,b,input[18:0]wr,wi);
            reg[18:0] ar,ai,br,bi;
            reg [37:0] tr,ti;
            begin
            ar=buffer_real[a];
            ai=buffer_imag[a];
            br=buffer_real[b];
            bi=buffer_imag[b];
            
            tr=(br*wr)-(bi*wi);
            ti=(br*wi)+(bi*wr);
            tr=tr+(1<<18);
            ti=ti+(1<<18);
            
            buffer_real[b]=ar-(tr>>19);
            buffer_imag[b]=ai-(tr>>19);
            buffer_real[a]=ar-(tr>>19);
            buffer_imag[a]=ai-(tr>>19);
            end
            endtask



initial begin
    twiddle_real[0]=19'd1;twiddle_imag[0]=19'd0;
    twiddle_real[1]=19'h0BF4E;twiddle_imag[1]=19'h4BF4E;//0100 1011 1111 0100 1110
    twiddle_real[2]=19'h0;twiddle_imag[1]=19'h40000;
    twiddle_real[3]=19'h4BF4E;twiddle_imag[1]=19'h0BF4E;
    end
localparam idle=4'd0,load_real=4'd1,load_imag=4'd2,stage_1=4'd3,stage_2=4'd4,stage_3=4'd5,store_real=4'd4,store_imag=4'd7,done_1=4'd8;

always@(posedge clk or negedge rst)begin
if(!rst) begin
    state<=idle;
    done<=0;
    mem_addr<=0;
    mem_write<=0;
    ele_cnt<=0;
    end
else case(state)
    idle:begin
        done<=0;
        if(start)begin
            mem_addr<=input_addr;
            ele_cnt<=0;
            state<=load_real;
            end
        end
    load_real:begin
        buffer_real[ele_cnt]<=mem_data_in;
        mem_addr<=mem_addr+1;
        state<=load_imag;
        end
    load_imag:begin
        buffer_imag[ele_cnt]<=mem_data_in;
        ele_cnt<=ele_cnt+1;
        if(ele_cnt==7)begin
            stage<=0;
            bfg<=0;
            state<=stage_1;
            end
        else begin
            mem_addr<=mem_addr+1;
            state<=load_real;
            end
        end
    stage_1,stage_2,stage_3:begin
        if (stage<3)begin
            index_a=bfg+bfp;
            index_b=index_a+(1<<stage);
            twiddle_index=bfp*(N>>(stage+1));
            butterfly(index_a,index_b,twiddle_real[twiddle_index],twiddle_imag[twiddle_index]);
                if(bfp<(1<<stage)-1)begin
                    bfp<=bfp+1;
                    end
                else begin
                    bfg<=bfg+(2<<stage);
                    if(bfg>=8-(2<<stage))begin
                        stage<=stage+1;
                        bfg<=0;
                        end
                    bfp<=0;
                    end
                    end
        else begin
            ele_cnt<=0;
            mem_addr<=input_addr;
            state<=store_real;
            end
        end
     store_real:begin
        mem_data_out<=buffer_real[ele_cnt];
        mem_write<=1;
        state<=store_imag;
        end
     store_imag:begin
        mem_data_out<=buffer_imag[ele_cnt];
        mem_addr<=mem_addr+1;
        ele_cnt<=ele_cnt+1;
        if(ele_cnt==7)begin
            mem_write<=0;
            state<=done_1;
            end
        else begin
            state<=store_real;
            end
        end
     done_1:begin
        done<=1;
        state<=idle;
        end
     endcase
end
endmodule
 