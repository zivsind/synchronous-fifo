module fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8
)
(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [WIDTH-1:0]      din,
    output logic [WIDTH-1:0]      dout,
    output logic                  full,
    output logic                  empty
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wptr, rptr;
    logic [$clog2(DEPTH+1)-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr  <= '0;
            rptr  <= '0;
            count <= '0;
            dout  <= '0;
        end else begin
            if (wr_en && !full) begin
                mem[wptr] <= din;
                wptr <= (wptr == DEPTH-1) ? 0 : wptr + 1;
            end

            if (rd_en && !empty) begin
                dout <= mem[rptr];
                rptr <= (rptr == DEPTH-1) ? 0 : rptr + 1;
            end

            unique case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

endmodule

