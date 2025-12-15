module boot_rom (
    input  wire        clk,
    input  wire [18:0] addr,
    output reg  [18:0] data
);

    reg [18:0] rom [0:255];

    initial begin
        $readmemh("boot.hex", rom);
    end

    always @(posedge clk) begin
        data <= rom[addr[7:0]];
    end

endmodule
