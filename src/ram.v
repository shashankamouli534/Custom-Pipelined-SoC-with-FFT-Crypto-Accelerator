module ram (
    input  wire        clk,

    input  wire        mem_valid,
    input  wire        mem_write,
    input  wire [18:0] mem_addr,
    input  wire [18:0] mem_wdata,
    output reg  [18:0] mem_rdata
);

    // 512 KB memory (word addressed)
    reg [18:0] memory [0:262143];

    initial begin
        $readmemh("program.hex", memory);
    end

    always @(posedge clk) begin
        if (mem_valid) begin
            if (mem_write)
                memory[mem_addr] <= mem_wdata;
            mem_rdata <= memory[mem_addr];
        end
    end

endmodule
