module sobel_grad #(
    parameter int XW = 4,
    parameter int YW = 4
) (
    input  logic clk,
    input  logic rst_n,
    input  logic [7:0] p00, p01, p02,
    input  logic [7:0] p10, p11, p12,
    input  logic [7:0] p20, p21, p22,
    input  logic [XW-1:0] in_x,
    input  logic [YW-1:0] in_y,
    input  logic in_valid,
    output logic signed [10:0] ix,
    output logic signed [10:0] iy,
    output logic [XW-1:0] out_x,
    output logic [YW-1:0] out_y,
    output logic out_valid
);
    logic signed [10:0] gx_comb;
    logic signed [10:0] gy_comb;

    always_comb begin
        gx_comb = $signed({3'b0, p02}) + ($signed({3'b0, p12}) <<< 1) + $signed({3'b0, p22})
                - $signed({3'b0, p00}) - ($signed({3'b0, p10}) <<< 1) - $signed({3'b0, p20});
        gy_comb = $signed({3'b0, p20}) + ($signed({3'b0, p21}) <<< 1) + $signed({3'b0, p22})
                - $signed({3'b0, p00}) - ($signed({3'b0, p01}) <<< 1) - $signed({3'b0, p02});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ix <= '0;
            iy <= '0;
            out_x <= '0;
            out_y <= '0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                ix <= gx_comb;
                iy <= gy_comb;
                out_x <= in_x;
                out_y <= in_y;
            end
        end
    end
endmodule
