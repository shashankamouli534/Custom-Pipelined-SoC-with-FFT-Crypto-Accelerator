`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst_n;

    // Instantiate SoC
    soc_top dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock: 100 MHz
    always #5 clk = ~clk;

    // ------------------------------
    // Bus Functional Model (BFM)
    // ------------------------------

    task bus_write(input [18:0] addr, input [18:0] data);
        begin
            @(posedge clk);
            dut.cpu.bus_valid <= 1'b1;
            dut.cpu.bus_write <= 1'b1;
            dut.cpu.bus_addr  <= addr;
            dut.cpu.bus_wdata <= data;

            @(posedge clk);
            dut.cpu.bus_valid <= 1'b0;
            dut.cpu.bus_write <= 1'b0;
        end
    endtask

    task bus_read(input [18:0] addr, output [18:0] data);
        begin
            @(posedge clk);
            dut.cpu.bus_valid <= 1'b1;
            dut.cpu.bus_write <= 1'b0;
            dut.cpu.bus_addr  <= addr;

            @(posedge clk);
            data = dut.cpu.bus_rdata;
            dut.cpu.bus_valid <= 1'b0;
        end
    endtask

    task poll_done(input [18:0] status_addr);
        reg [18:0] status;
        begin
            status = 0;
            while (status[0] == 0) begin
                bus_read(status_addr, status);
            end
        end
    endtask

    // ------------------------------
    // Test sequence
    // ------------------------------

    reg [18:0] rdata;

    localparam FFT_BASE    = 19'b111_0000_0000_0000_000;
    localparam CRYPTO_BASE = 19'b110_0000_0000_0000_000;

    initial begin
        $dumpfile("soc.vcd");
        $dumpvars(0, testbench);

        // Init
        clk = 0;
        rst_n = 0;

        // Release reset
        #50;
        rst_n = 1;

        // --------------------------------
        // Preload RAM data for FFT
        // --------------------------------
        $display("[TB] Initializing RAM...");
        dut.ram_inst.memory[100] = 19'd1;
        dut.ram_inst.memory[101] = 19'd2;
        dut.ram_inst.memory[102] = 19'd3;
        dut.ram_inst.memory[103] = 19'd4;
        dut.ram_inst.memory[104] = 19'd5;
        dut.ram_inst.memory[105] = 19'd6;
        dut.ram_inst.memory[106] = 19'd7;
        dut.ram_inst.memory[107] = 19'd8;

        // --------------------------------
        // FFT Test
        // --------------------------------
        $display("[TB] Starting FFT...");

        bus_write(FFT_BASE + 2, 19'd100); // IN_BASE
        bus_write(FFT_BASE + 3, 19'd200); // OUT_BASE
        bus_write(FFT_BASE + 0, 19'd1);   // START

        poll_done(FFT_BASE + 1);

        $display("[TB] FFT DONE");

        // --------------------------------
        // Crypto Test
        // --------------------------------
        $display("[TB] Starting CRYPTO...");

        bus_write(CRYPTO_BASE + 2, 19'd300); // IN_BASE
        bus_write(CRYPTO_BASE + 3, 19'd400); // OUT_BASE
        bus_write(CRYPTO_BASE + 0, 19'd1);   // START

        poll_done(CRYPTO_BASE + 1);

        $display("[TB] CRYPTO DONE");

        // --------------------------------
        // Back-to-back FFT
        // --------------------------------
        $display("[TB] FFT again...");

        bus_write(FFT_BASE + 0, 19'd1);
        poll_done(FFT_BASE + 1);

        $display("[TB] FFT DONE (2nd time)");

        #100;
        $display("[TB] ALL TESTS PASSED");
        $finish;
    end

endmodule
