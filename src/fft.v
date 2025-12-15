module fft_accel (
    input  wire        clk,
    input  wire        rst_n,

    // Bus
    input  wire        bus_valid,
    input  wire        bus_write,
    input  wire [18:0] bus_addr,
    input  wire [18:0] bus_wdata,
    output wire [18:0] bus_rdata,

    // Memory
    output reg         mem_valid,
    output reg         mem_write,
    output reg  [18:0] mem_addr,
    output reg  [18:0] mem_wdata,
    input  wire [18:0] mem_rdata
);

    reg [18:0] regs [0:3]; // CTRL, STATUS, IN_BASE, OUT_BASE

    register_file_iface #(.REG_COUNT(4)) rf (
        .clk(clk), .rst_n(rst_n),
        .bus_valid(bus_valid),
        .bus_write(bus_write),
        .bus_addr(bus_addr),
        .bus_wdata(bus_wdata),
        .bus_rdata(bus_rdata),
        .regs(regs)
    );

    wire start = regs[0][0];
    wire [18:0] in_base  = regs[2];
    wire [18:0] out_base = regs[3];

    reg [2:0] idx;
    reg [2:0] state;
    reg [18:0] buffer [0:7];

    localparam IDLE=0, LOAD=1, WAIT=2, STORE=3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            regs[1] <= 0;
            mem_valid <= 0;
        end else begin
            case (state)
                IDLE: begin
                    regs[1] <= 0;
                    if (start) begin
                        idx <= 0;
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    mem_valid <= 1;
                    mem_write <= 0;
                    mem_addr  <= in_base + idx;
                    state <= WAIT;
                end

                WAIT: begin
                    buffer[idx] <= mem_rdata;
                    idx <= idx + 1;
                    mem_valid <= 0;
                    state <= (idx == 7) ? STORE : LOAD;
                end

                STORE: begin
    mem_valid <= 1;
    mem_write <= 1;
    mem_addr  <= out_base + idx;
    mem_wdata <= buffer[idx];
    idx <= idx + 1;

    if (idx == 7) begin
        regs[1][0] <= 1'b1; // DONE
        state <= IDLE;
        mem_valid <= 0;
    end
end

            endcase
        end
    end
endmodule
