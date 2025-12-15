module register_file_iface #(
    parameter REG_COUNT = 4,          // number of registers
    parameter ADDR_LSB  = 2            // word alignment
)(
    input  wire        clk,
    input  wire        rst_n,

    // Bus interface
    input  wire        bus_valid,
    input  wire        bus_write,
    input  wire [18:0] bus_addr,
    input  wire [18:0] bus_wdata,
    output reg  [18:0] bus_rdata,

    // Register file
    output reg  [18:0] regs [0:REG_COUNT-1]
);

    wire [$clog2(REG_COUNT)-1:0] reg_sel;
    assign reg_sel = bus_addr[ADDR_LSB +: $clog2(REG_COUNT)];

    integer i;

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < REG_COUNT; i = i + 1)
                regs[i] <= 19'd0;
        end else if (bus_valid && bus_write) begin
            regs[reg_sel] <= bus_wdata;
        end
    end

    // Read logic
    always @(*) begin
        bus_rdata = 19'd0;
        if (bus_valid && !bus_write) begin
            bus_rdata = regs[reg_sel];
        end
    end

endmodule
