module harris_response #(
    parameter int XW = 4,
    parameter int YW = 4,
    parameter logic [7:0] K_Q8 = 8'd10
) (
    input logic clk,
    input logic rst_n,
    input logic [24:0] sxx,
    input logic [24:0] syy,
    input logic signed [25:0] sxy,
    input logic [XW-1:0] in_x,
    input logic [YW-1:0] in_y,
    input logic in_valid,
    output logic signed [53:0] response,
    output logic [XW-1:0] out_x,
    output logic [YW-1:0] out_y,
    output logic out_valid
);
    logic [49:0] determinant_comb;
    logic signed [51:0] cross_square_comb;
    logic [25:0] trace_comb;
    logic [51:0] trace_square_comb;
    logic [59:0] penalty_product_comb;
    logic [51:0] penalty_comb;
    logic signed [53:0] response_comb;

    always_comb begin
        determinant_comb = sxx * syy;
        cross_square_comb = sxy * sxy;
        trace_comb = {1'b0, sxx} + {1'b0, syy};
        trace_square_comb = trace_comb * trace_comb;
        penalty_product_comb = K_Q8 * trace_square_comb;
        penalty_comb = penalty_product_comb[59:8];
        response_comb = $signed({4'b0, determinant_comb})
                      - $signed({2'b0, cross_square_comb})
                      - $signed({2'b0, penalty_comb});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            response <= '0;
            out_x <= '0;
            out_y <= '0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                response <= response_comb;
                out_x <= in_x;
                out_y <= in_y;
            end
        end
    end
endmodule
