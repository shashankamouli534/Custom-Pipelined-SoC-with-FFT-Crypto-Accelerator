`timescale 1ns/1ps
module cpu_tb();
reg clk;
reg rst;
cpu dut(.clk(clk), .rst(rst));

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, cpu_tb);
    rst = 1;
    #100 rst = 0;
    #10000 $finish;
end
endmodule
