module mem_stage(
input clk,
input [18:0] addr,
input [18:0] write_data,
input fft_strt,crypto_en,
input [18:0] rs1_data,rs2_data,rd_data,
input mem_write,
input mem_read,
output [18:0] read_data,
output fft_key,
output crypto_key
    );
memory m(.clk(clk),.mem_write(mem_write),.mem_read(mem_read),.addr(addr),.write_data(write_data),.read_data(read_data));
fft_unit fft(
    .start(fft_start),
    .input_addr(rs2_data[18:0]),
    .mem_addr(rd_data[9:0]),
    .mem_data_in(mem_read_data),
    .mem_data_out(mem_write_data)
);
crypto_unit aes(
    .start(crypto_start),
    .input_addr(rs2_data[9:0]),
    .result_addr(rd_data[9:0]),
    .mem_data_in(mem_read_data),
    .mem_data_out(mem_write_data)
);
assign fft_key = (addr[18:16] == 3'b111);
assign crypto_key = (addr[18:16] == 3'b110);

endmodule
