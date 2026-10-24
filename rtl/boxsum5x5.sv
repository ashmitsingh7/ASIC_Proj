module boxsum5x5 #(
    parameter int IMAGE_WIDTH = 16,
    parameter int XW = (IMAGE_WIDTH <= 1) ? 1 : $clog2(IMAGE_WIDTH),
    parameter int YW = 4
) (
    input  logic clk,
    input  logic rst_n,
    input  logic [19:0] pxx,
    input  logic [19:0] pyy,
    input  logic signed [20:0] pxy,
    input  logic [XW-1:0] in_x,
    input  logic [YW-1:0] in_y,
    input  logic in_valid,
    output logic [24:0] sxx,
    output logic [24:0] syy,
    output logic signed [25:0] sxy,
    output logic [XW-1:0] out_x,
    output logic [YW-1:0] out_y,
    output logic out_valid
);
    logic [19:0] xx_l1 [0:IMAGE_WIDTH-1];
    logic [19:0] xx_l2 [0:IMAGE_WIDTH-1];
    logic [19:0] xx_l3 [0:IMAGE_WIDTH-1];
    logic [19:0] xx_l4 [0:IMAGE_WIDTH-1];
    logic [19:0] yy_l1 [0:IMAGE_WIDTH-1];
    logic [19:0] yy_l2 [0:IMAGE_WIDTH-1];
    logic [19:0] yy_l3 [0:IMAGE_WIDTH-1];
    logic [19:0] yy_l4 [0:IMAGE_WIDTH-1];
    logic signed [20:0] xy_l1 [0:IMAGE_WIDTH-1];
    logic signed [20:0] xy_l2 [0:IMAGE_WIDTH-1];
    logic signed [20:0] xy_l3 [0:IMAGE_WIDTH-1];
    logic signed [20:0] xy_l4 [0:IMAGE_WIDTH-1];
    logic [22:0] hxx0, hxx1, hxx2, hxx3;
    logic [22:0] hyy0, hyy1, hyy2, hyy3;
    logic signed [23:0] hxy0, hxy1, hxy2, hxy3;
    logic [22:0] vxx_comb, vyy_comb;
    logic signed [23:0] vxy_comb;
    integer index;

    always_comb begin
        vxx_comb = {3'b0, pxx} + {3'b0, xx_l1[in_x]} + {3'b0, xx_l2[in_x]}
                 + {3'b0, xx_l3[in_x]} + {3'b0, xx_l4[in_x]};
        vyy_comb = {3'b0, pyy} + {3'b0, yy_l1[in_x]} + {3'b0, yy_l2[in_x]}
                 + {3'b0, yy_l3[in_x]} + {3'b0, yy_l4[in_x]};
        vxy_comb = $signed({{3{pxy[20]}}, pxy}) + $signed({{3{xy_l1[in_x][20]}}, xy_l1[in_x]})
                 + $signed({{3{xy_l2[in_x][20]}}, xy_l2[in_x]})
                 + $signed({{3{xy_l3[in_x][20]}}, xy_l3[in_x]})
                 + $signed({{3{xy_l4[in_x][20]}}, xy_l4[in_x]});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hxx0 <= '0; hxx1 <= '0; hxx2 <= '0; hxx3 <= '0;
            hyy0 <= '0; hyy1 <= '0; hyy2 <= '0; hyy3 <= '0;
            hxy0 <= '0; hxy1 <= '0; hxy2 <= '0; hxy3 <= '0;
            sxx <= '0; syy <= '0; sxy <= '0;
            out_x <= '0; out_y <= '0; out_valid <= 1'b0;
            for (index = 0; index < IMAGE_WIDTH; index = index + 1) begin
                xx_l1[index] <= '0; xx_l2[index] <= '0; xx_l3[index] <= '0; xx_l4[index] <= '0;
                yy_l1[index] <= '0; yy_l2[index] <= '0; yy_l3[index] <= '0; yy_l4[index] <= '0;
                xy_l1[index] <= '0; xy_l2[index] <= '0; xy_l3[index] <= '0; xy_l4[index] <= '0;
            end
        end else begin
            out_valid <= 1'b0;
            if (in_valid) begin
                xx_l4[in_x] <= xx_l3[in_x]; xx_l3[in_x] <= xx_l2[in_x]; xx_l2[in_x] <= xx_l1[in_x]; xx_l1[in_x] <= pxx;
                yy_l4[in_x] <= yy_l3[in_x]; yy_l3[in_x] <= yy_l2[in_x]; yy_l2[in_x] <= yy_l1[in_x]; yy_l1[in_x] <= pyy;
                xy_l4[in_x] <= xy_l3[in_x]; xy_l3[in_x] <= xy_l2[in_x]; xy_l2[in_x] <= xy_l1[in_x]; xy_l1[in_x] <= pxy;
                sxx <= {2'b0, vxx_comb} + {2'b0, hxx0} + {2'b0, hxx1} + {2'b0, hxx2} + {2'b0, hxx3};
                syy <= {2'b0, vyy_comb} + {2'b0, hyy0} + {2'b0, hyy1} + {2'b0, hyy2} + {2'b0, hyy3};
                sxy <= $signed({{2{vxy_comb[23]}}, vxy_comb}) + $signed({{2{hxy0[23]}}, hxy0})
                     + $signed({{2{hxy1[23]}}, hxy1}) + $signed({{2{hxy2[23]}}, hxy2})
                     + $signed({{2{hxy3[23]}}, hxy3});
                out_x <= in_x - 2;
                out_y <= in_y - 2;
                out_valid <= (in_x >= 5) && (in_y >= 5);
                if (in_x == 1) begin
                    hxx0 <= vxx_comb; hxx1 <= '0; hxx2 <= '0; hxx3 <= '0;
                    hyy0 <= vyy_comb; hyy1 <= '0; hyy2 <= '0; hyy3 <= '0;
                    hxy0 <= vxy_comb; hxy1 <= '0; hxy2 <= '0; hxy3 <= '0;
                end else begin
                    hxx3 <= hxx2; hxx2 <= hxx1; hxx1 <= hxx0; hxx0 <= vxx_comb;
                    hyy3 <= hyy2; hyy2 <= hyy1; hyy1 <= hyy0; hyy0 <= vyy_comb;
                    hxy3 <= hxy2; hxy2 <= hxy1; hxy1 <= hxy0; hxy0 <= vxy_comb;
                end
            end
        end
    end
endmodule
