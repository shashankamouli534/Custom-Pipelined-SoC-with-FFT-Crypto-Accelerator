module memory(
input clk,mem_write,mem_read,
input [18:0]addr,write_data,
output [18:0]read_data
    );
reg [18:0] imem [0:262143];
reg [18:0] dmem [0:262143];
reg [18:0] fft_mem [0:1023];
reg [18:0] crypto_mem [0:1023];
 initial $readmemh("instr.hex",imem);
always @(posedge clk)begin
if (mem_write)begin
    if(addr[18:16]==3'b111)
        fft_mem[addr[9:0]]<=write_data;
    else if(addr[18:16]==3'b110)
        crypto_mem[addr[9:0]]<=write_data;
    else                
        dmem[addr] <= write_data;
        end
end
assign read_data=(mem_read)?
    (addr[18:16]==3'b111)?fft_mem[addr[9:0]]:
    (addr[18:16]==3'b110)?crypto_mem[addr[9:0]]:
    dmem[addr]:0;

 endmodule
