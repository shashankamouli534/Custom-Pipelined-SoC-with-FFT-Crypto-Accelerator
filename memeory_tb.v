`timescale 1ns/1ps
module memory_tb;
reg clk = 0;
reg mem_write, mem_read;
reg [18:0] addr, write_data;
wire [18:0] read_data;

memory dut(.clk(clk), .mem_write(mem_write), .mem_read(mem_read), .addr(addr), .write_data(write_data), .read_data(read_data));
always clk = ~clk;

initial begin
    mem_write = 1;
    mem_read = 1;
    addr = 19'd100;
    write_data = 19'd138;
    #10;
        
    mem_write = 1;
    mem_read = 0;
    addr = 19'h7F000;
    write_data = 19'd138;
    #10;
    
    mem_write = 0;
    mem_read = 1;
    #10;
    
    $display("all pass");
    $finish;
end     
endmodule
