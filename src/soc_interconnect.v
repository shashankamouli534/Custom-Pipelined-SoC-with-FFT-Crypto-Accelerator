module soc_interconnect (
    input  wire        clk,

    // CPU bus
    input  wire        cpu_valid,
    input  wire        cpu_write,
    input  wire [18:0] cpu_addr,
    input  wire [18:0] cpu_wdata,
    output reg  [18:0] cpu_rdata,

    // RAM
    output reg         ram_valid,
    output reg         ram_write,
    output reg  [18:0] ram_addr,
    output reg  [18:0] ram_wdata,
    input  wire [18:0] ram_rdata,

    // FFT
    output reg         fft_valid,
    output reg         fft_write,
    output reg  [18:0] fft_addr,
    output reg  [18:0] fft_wdata,
    input  wire [18:0] fft_rdata,

    // Crypto
    output reg         crypto_valid,
    output reg         crypto_write,
    output reg  [18:0] crypto_addr,
    output reg  [18:0] crypto_wdata,
    input  wire [18:0] crypto_rdata
);

    always @(*) begin
        // Defaults
        ram_valid    = 0;
        fft_valid    = 0;
        crypto_valid = 0;

        ram_write    = 0;
        fft_write    = 0;
        crypto_write = 0;

        cpu_rdata    = 19'd0;

        if (cpu_valid) begin
            case (cpu_addr[18:16])
                3'b111: begin // FFT
                    fft_valid = 1;
                    fft_write = cpu_write;
                    fft_addr  = cpu_addr;
                    fft_wdata = cpu_wdata;
                    cpu_rdata = fft_rdata;
                end

                3'b110: begin // Crypto
                    crypto_valid = 1;
                    crypto_write = cpu_write;
                    crypto_addr  = cpu_addr;
                    crypto_wdata = cpu_wdata;
                    cpu_rdata    = crypto_rdata;
                end

                default: begin // RAM
                    ram_valid = 1;
                    ram_write = cpu_write;
                    ram_addr  = cpu_addr;
                    ram_wdata = cpu_wdata;
                    cpu_rdata = ram_rdata;
                end
            endcase
        end
    end

endmodule
