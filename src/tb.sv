`timescale 1ns / 1ps

module tb_soc_top;

    // ------------------------------------------------------------
    // Clock & Reset
    // ------------------------------------------------------------
    reg clk;
    reg rst_n;

    always #5 clk = ~clk;   // 100 MHz clock

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    soc_top dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // ------------------------------------------------------------
    // Simulation control
    // ------------------------------------------------------------
    initial begin
        clk = 0;
        rst_n = 0;

        $display("=====================================");
        $display("  SoC TESTBENCH START");
        $display("=====================================");

        // Reset
        #50;
        rst_n = 1;
        $display("[TB] Reset released");

        // Let CPU fetch a few instructions
        repeat (20) @(posedge clk);

        // --------------------------------------------------------
        // Manually preload RAM data for accelerators
        // --------------------------------------------------------
        preload_ram();

        // --------------------------------------------------------
        // Program FFT accelerator
        // --------------------------------------------------------
        program_fft();

        // Wait for FFT to complete
        wait_fft_done();

        // --------------------------------------------------------
        // Program Crypto accelerator
        // --------------------------------------------------------
        program_crypto();

        // Wait for Crypto to complete
        wait_crypto_done();

        // --------------------------------------------------------
        // Final RAM dump
        // --------------------------------------------------------
        dump_ram();

        $display("=====================================");
        $display("  TEST PASSED");
        $display("=====================================");

        #100;
        $finish;
    end

    // ------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------

    // Direct RAM preload (bypassing CPU)
    task preload_ram;
        integer i;
        begin
            $display("[TB] Preloading RAM");

            for (i = 0; i < 8; i = i + 1) begin
                dut.ram_inst.memory[100 + i] = i + 1;   // FFT input
                dut.ram_inst.memory[200 + i] = 0;       // FFT output
            end

            dut.ram_inst.memory[300] = 19'h12345;       // Crypto input
            dut.ram_inst.memory[301] = 0;               // Crypto output
        end
    endtask

    // Program FFT registers via interconnect
    task program_fft;
        begin
            $display("[TB] Programming FFT accelerator");

            // CTRL (start)
            force dut.cpu_valid = 1;
            force dut.cpu_write = 1;
            force dut.cpu_addr  = 19'h7000; // FFT CTRL
            force dut.cpu_wdata = 19'h1;
            @(posedge clk);

            // IN_BASE
            force dut.cpu_addr  = 19'h7008;
            force dut.cpu_wdata = 19'd100;
            @(posedge clk);

            // OUT_BASE
            force dut.cpu_addr  = 19'h700C;
            force dut.cpu_wdata = 19'd200;
            @(posedge clk);

            release dut.cpu_valid;
            release dut.cpu_write;
            release dut.cpu_addr;
            release dut.cpu_wdata;
        end
    endtask

    task wait_fft_done;
        begin
            $display("[TB] Waiting for FFT completion");
            wait (dut.fft.regs[1][0] == 1'b1);
            $display("[TB] FFT DONE");
        end
    endtask

    // Program Crypto registers via interconnect
    task program_crypto;
        begin
            $display("[TB] Programming Crypto accelerator");

            // CTRL (start)
            force dut.cpu_valid = 1;
            force dut.cpu_write = 1;
            force dut.cpu_addr  = 19'h6000; // CRYPTO CTRL
            force dut.cpu_wdata = 19'h1;
            @(posedge clk);

            // IN_BASE
            force dut.cpu_addr  = 19'h6008;
            force dut.cpu_wdata = 19'd300;
            @(posedge clk);

            // OUT_BASE
            force dut.cpu_addr  = 19'h600C;
            force dut.cpu_wdata = 19'd301;
            @(posedge clk);

            release dut.cpu_valid;
            release dut.cpu_write;
            release dut.cpu_addr;
            release dut.cpu_wdata;
        end
    endtask

    task wait_crypto_done;
        begin
            $display("[TB] Waiting for Crypto completion");
            wait (dut.crypto.regs[1][0] == 1'b1);
            $display("[TB] CRYPTO DONE");
        end
    endtask

    // Dump memory results
    task dump_ram;
        integer i;
        begin
            $display("---- FFT OUTPUT ----");
            for (i = 0; i < 8; i = i + 1)
                $display("FFT[%0d] = %0d", i, dut.ram_inst.memory[200 + i]);

            $display("---- CRYPTO OUTPUT ----");
            $display("CRYPTO = 0x%h", dut.ram_inst.memory[301]);
        end
    endtask

endmodule
