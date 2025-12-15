module soc_top (
    input wire clk,
    input wire rst_n
);

    // ============================================================
    // CPU <-> SoC Bus
    // ============================================================
    wire        cpu_valid;
    wire        cpu_write;
    wire [18:0] cpu_addr;
    wire [18:0] cpu_wdata;
    wire [18:0] cpu_rdata;

    // ============================================================
    // Interconnect <-> Peripherals
    // ============================================================
    wire        ram_bus_valid;
    wire        ram_bus_write;
    wire [18:0] ram_bus_addr;
    wire [18:0] ram_bus_wdata;
    wire [18:0] ram_bus_rdata;

    wire        fft_bus_valid;
    wire        fft_bus_write;
    wire [18:0] fft_bus_addr;
    wire [18:0] fft_bus_wdata;
    wire [18:0] fft_bus_rdata;

    wire        crypto_bus_valid;
    wire        crypto_bus_write;
    wire [18:0] crypto_bus_addr;
    wire [18:0] crypto_bus_wdata;
    wire [18:0] crypto_bus_rdata;

    // ============================================================
    // Accelerator memory ports
    // ============================================================
    wire        fft_mem_valid;
    wire        fft_mem_write;
    wire [18:0] fft_mem_addr;
    wire [18:0] fft_mem_wdata;
    wire [18:0] fft_mem_rdata;

    wire        crypto_mem_valid;
    wire        crypto_mem_write;
    wire [18:0] crypto_mem_addr;
    wire [18:0] crypto_mem_wdata;
    wire [18:0] crypto_mem_rdata;

    // ============================================================
    // Arbiter <-> RAM
    // ============================================================
    wire        ram_valid;
    wire        ram_write;
    wire [18:0] ram_addr;
    wire [18:0] ram_wdata;
    wire [18:0] ram_rdata;

    // ============================================================
    // CPU
    // ============================================================
    cpu_core cpu (
        .clk(clk),
        .rst_n(rst_n),
        .bus_valid(cpu_valid),
        .bus_write(cpu_write),
        .bus_addr(cpu_addr),
        .bus_wdata(cpu_wdata),
        .bus_rdata(cpu_rdata)
    );

    // ============================================================
    // SoC Interconnect (register access)
    // ============================================================
    soc_interconnect interconnect (
        .clk(clk),

        .cpu_valid(cpu_valid),
        .cpu_write(cpu_write),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_rdata(cpu_rdata),

        .ram_valid(ram_bus_valid),
        .ram_write(ram_bus_write),
        .ram_addr(ram_bus_addr),
        .ram_wdata(ram_bus_wdata),
        .ram_rdata(ram_bus_rdata),

        .fft_valid(fft_bus_valid),
        .fft_write(fft_bus_write),
        .fft_addr(fft_bus_addr),
        .fft_wdata(fft_bus_wdata),
        .fft_rdata(fft_bus_rdata),

        .crypto_valid(crypto_bus_valid),
        .crypto_write(crypto_bus_write),
        .crypto_addr(crypto_bus_addr),
        .crypto_wdata(crypto_bus_wdata),
        .crypto_rdata(crypto_bus_rdata)
    );

    // ============================================================
    // FFT Accelerator
    // ============================================================
    fft_accel fft (
        .clk(clk),
        .rst_n(rst_n),

        .bus_valid(fft_bus_valid),
        .bus_write(fft_bus_write),
        .bus_addr(fft_bus_addr),
        .bus_wdata(fft_bus_wdata),
        .bus_rdata(fft_bus_rdata),

        .mem_valid(fft_mem_valid),
        .mem_write(fft_mem_write),
        .mem_addr(fft_mem_addr),
        .mem_wdata(fft_mem_wdata),
        .mem_rdata(fft_mem_rdata)
    );

    // ============================================================
    // Crypto Accelerator
    // ============================================================
    crypto_accel crypto (
        .clk(clk),
        .rst_n(rst_n),

        .bus_valid(crypto_bus_valid),
        .bus_write(crypto_bus_write),
        .bus_addr(crypto_bus_addr),
        .bus_wdata(crypto_bus_wdata),
        .bus_rdata(crypto_bus_rdata),

        .mem_valid(crypto_mem_valid),
        .mem_write(crypto_mem_write),
        .mem_addr(crypto_mem_addr),
        .mem_wdata(crypto_mem_wdata),
        .mem_rdata(crypto_mem_rdata)
    );

    // ============================================================
    // Accelerator Memory Arbiter
    // ============================================================
    accel_mem_arbiter arb (
        .clk(clk),

        .cpu_valid(ram_bus_valid),
        .cpu_write(ram_bus_write),
        .cpu_addr(ram_bus_addr),
        .cpu_wdata(ram_bus_wdata),
        .cpu_rdata(ram_bus_rdata),

        .fft_valid(fft_mem_valid),
        .fft_write(fft_mem_write),
        .fft_addr(fft_mem_addr),
        .fft_wdata(fft_mem_wdata),
        .fft_rdata(fft_mem_rdata),

        .crypto_valid(crypto_mem_valid),
        .crypto_write(crypto_mem_write),
        .crypto_addr(crypto_mem_addr),
        .crypto_wdata(crypto_mem_wdata),
        .crypto_rdata(crypto_mem_rdata),

        .ram_valid(ram_valid),
        .ram_write(ram_write),
        .ram_addr(ram_addr),
        .ram_wdata(ram_wdata),
        .ram_rdata(ram_rdata)
    );

    // ============================================================
    // RAM
    // ============================================================
    ram ram_inst (
        .clk(clk),
        .mem_valid(ram_valid),
        .mem_write(ram_write),
        .mem_addr(ram_addr),
        .mem_wdata(ram_wdata),
        .mem_rdata(ram_rdata)
    );

endmodule
