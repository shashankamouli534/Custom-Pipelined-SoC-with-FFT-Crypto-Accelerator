module interrupt_controller (
    input  wire        clk,
    input  wire        rst_n,

    // Interrupt sources
    input  wire        irq_fft,
    input  wire        irq_crypto,
    input  wire        irq_timer,

    // Bus interface
    input  wire        bus_valid,
    input  wire        bus_write,
    input  wire [18:0] bus_addr,
    input  wire [18:0] bus_wdata,
    output reg  [18:0] bus_rdata,

    // To CPU
    output wire        irq
);

    reg [2:0] irq_status;

    assign irq = |irq_status;  // any interrupt active

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            irq_status <= 3'b000;
        else begin
            // Latch interrupts
            if (irq_fft)    irq_status[0] <= 1'b1;
            if (irq_crypto) irq_status[1] <= 1'b1;
            if (irq_timer)  irq_status[2] <= 1'b1;

            // Acknowledge (clear)
            if (bus_valid && bus_write && bus_addr[3:2] == 2'b01)
                irq_status <= irq_status & ~bus_wdata[2:0];
        end
    end

    always @(*) begin
        bus_rdata = 19'd0;
        if (bus_valid && !bus_write) begin
            case (bus_addr[3:2])
                2'b00: bus_rdata = {16'd0, irq_status};
            endcase
        end
    end

endmodule
