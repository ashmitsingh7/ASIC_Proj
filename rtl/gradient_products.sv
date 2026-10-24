module gradient_products #(
    parameter int XW = 4,
    parameter int YW = 4
) (
    input  logic clk,
    input  logic rst_n,
    input  logic signed [10:0] ix,
    input  logic signed [10:0] iy,
    input  logic [XW-1:0] in_x,
    input  logic [YW-1:0] in_y,
    input  logic in_valid,
    output logic [19:0] pxx,
    output logic [19:0] pyy,
    output logic signed [20:0] pxy,
    output logic [XW-1:0] out_x,
    output logic [YW-1:0] out_y,
    output logic out_valid
);
    logic [19:0] ix_sq_comb;
    logic [19:0] iy_sq_comb;
    logic signed [20:0] ixiy_comb;

    always_comb begin
        ix_sq_comb = ix * ix;
        iy_sq_comb = iy * iy;
        ixiy_comb = ix * iy;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pxx <= '0;
            pyy <= '0;
            pxy <= '0;
            out_x <= '0;
            out_y <= '0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                pxx <= ix_sq_comb;
                pyy <= iy_sq_comb;
                pxy <= ixiy_comb;
                out_x <= in_x;
                out_y <= in_y;
            end
        end
    end
endmodule
