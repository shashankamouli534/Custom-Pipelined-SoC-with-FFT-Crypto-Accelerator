module mem_stage (
    input  wire        clk,

    input  wire [18:0] addr,
    input  wire [18:0] write_data,
    input  wire        mem_write,
    input  wire        mem_read,

    // Data bus interface
    output reg         dbus_valid,
    output reg         dbus_write,
    output reg  [18:0] dbus_addr,
    output reg  [18:0] dbus_wdata,
    input  wire [18:0] dbus_rdata,

    output reg  [18:0] read_data
);

    always @(posedge clk) begin
        dbus_valid <= mem_read | mem_write;
        dbus_write <= mem_write;
        dbus_addr  <= addr;
        dbus_wdata <= write_data;
    end

    // Capture load data
    always @(posedge clk) begin
        if (mem_read)
            read_data <= dbus_rdata;
    end

endmodule
