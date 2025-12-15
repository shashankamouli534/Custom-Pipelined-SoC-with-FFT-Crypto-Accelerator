module timer (
    input  wire        clk,
    input  wire        rst_n,

    // Bus interface
    input  wire        bus_valid,
    input  wire        bus_write,
    input  wire [18:0] bus_addr,
    input  wire [18:0] bus_wdata,
    output reg  [18:0] bus_rdata,

    // Interrupt
    output reg         irq_timer
);

    reg [18:0] count;
    reg [18:0] limit;
    reg        enable;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count     <= 0;
            limit     <= 19'd1000;
            enable    <= 0;
            irq_timer <= 0;
        end else begin
            irq_timer <= 0;
            if (enable) begin
                count <= count + 1;
                if (count == limit) begin
                    count <= 0;
                    irq_timer <= 1;
                end
            end

            if (bus_valid && bus_write) begin
                case (bus_addr[3:2])
                    2'b01: limit  <= bus_wdata;
                    2'b10: enable <= bus_wdata[0];
                endcase
            end
        end
    end

    always @(*) begin
        bus_rdata = 19'd0;
        if (bus_valid && !bus_write) begin
            case (bus_addr[3:2])
                2'b00: bus_rdata = count;
                2'b01: bus_rdata = limit;
            endcase
        end
    end

endmodule
