module bus_interface (
    input  wire        clk,
    input  wire        rst_n,

    // Requests from CPU pipeline
    input  wire        req_valid,
    input  wire        req_write,
    input  wire [18:0] req_addr,
    input  wire [18:0] req_wdata,

    // Response to CPU pipeline
    output reg  [18:0] resp_rdata,

    // SoC bus
    output reg         bus_valid,
    output reg         bus_write,
    output reg  [18:0] bus_addr,
    output reg  [18:0] bus_wdata,
    input  wire [18:0] bus_rdata
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bus_valid  <= 1'b0;
            bus_write  <= 1'b0;
            bus_addr   <= 19'd0;
            bus_wdata  <= 19'd0;
            resp_rdata <= 19'd0;
        end else begin
            bus_valid <= req_valid;
            bus_write <= req_write;
            bus_addr  <= req_addr;
            bus_wdata <= req_wdata;

            if (req_valid && !req_write)
                resp_rdata <= bus_rdata;
        end
    end

endmodule
