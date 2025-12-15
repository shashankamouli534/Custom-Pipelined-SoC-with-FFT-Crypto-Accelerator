module accel_mem_arbiter (
    input  wire        clk,

    // CPU
    input  wire        cpu_valid,
    input  wire        cpu_write,
    input  wire [18:0] cpu_addr,
    input  wire [18:0] cpu_wdata,
    output reg  [18:0] cpu_rdata,

    // FFT
    input  wire        fft_valid,
    input  wire        fft_write,
    input  wire [18:0] fft_addr,
    input  wire [18:0] fft_wdata,
    output reg  [18:0] fft_rdata,

    // Crypto
    input  wire        crypto_valid,
    input  wire        crypto_write,
    input  wire [18:0] crypto_addr,
    input  wire [18:0] crypto_wdata,
    output reg  [18:0] crypto_rdata,

    // RAM
    output reg         ram_valid,
    output reg         ram_write,
    output reg  [18:0] ram_addr,
    output reg  [18:0] ram_wdata,
    input  wire [18:0] ram_rdata
);

    always @(*) begin
        ram_valid  = 0;
        ram_write  = 0;
        ram_addr   = 0;
        ram_wdata  = 0;

        cpu_rdata    = 0;
        fft_rdata    = 0;
        crypto_rdata = 0;

        // Priority: CPU > FFT > Crypto
        if (cpu_valid) begin
            ram_valid = 1;
            ram_write = cpu_write;
            ram_addr  = cpu_addr;
            ram_wdata = cpu_wdata;
            cpu_rdata = ram_rdata;
        end
        else if (fft_valid) begin
            ram_valid = 1;
            ram_write = fft_write;
            ram_addr  = fft_addr;
            ram_wdata = fft_wdata;
            fft_rdata = ram_rdata;
        end
        else if (crypto_valid) begin
            ram_valid = 1;
            ram_write = crypto_write;
            ram_addr  = crypto_addr;
            ram_wdata = crypto_wdata;
            crypto_rdata = ram_rdata;
        end
    end

endmodule
