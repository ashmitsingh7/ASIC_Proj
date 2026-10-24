module harris_top #(
    parameter int IMAGE_WIDTH = 16,
    parameter int IMAGE_HEIGHT = 16,
    parameter logic [7:0] K_Q8 = 8'd10,
    parameter logic signed [53:0] THRESHOLD = 54'sd1000000,
    parameter int XW = (IMAGE_WIDTH <= 1) ? 1 : $clog2(IMAGE_WIDTH),
    parameter int YW = (IMAGE_HEIGHT <= 1) ? 1 : $clog2(IMAGE_HEIGHT)
) (
    input logic clk,
    input logic rst_n,
    input logic [7:0] pixel_in,
    input logic pixel_valid,
    output logic corner_out,
    output logic corner_valid,
    output logic [XW-1:0] corner_x,
    output logic [YW-1:0] corner_y
);
    logic [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
    logic [XW-1:0] w_x, g_x, gp_x, b_x, r_x;
    logic [YW-1:0] w_y, g_y, gp_y, b_y, r_y;
    logic w_valid, g_valid, gp_valid, b_valid, r_valid;
    logic signed [10:0] ix, iy;
    logic [19:0] pxx, pyy;
    logic signed [20:0] pxy;
    logic [24:0] sxx, syy;
    logic signed [25:0] sxy;
    logic signed [53:0] response;

    window3x3 #(.IMAGE_WIDTH(IMAGE_WIDTH), .IMAGE_HEIGHT(IMAGE_HEIGHT), .XW(XW), .YW(YW)) u_window (
        .clk, .rst_n, .pixel_in, .pixel_valid, .p00, .p01, .p02, .p10, .p11, .p12, .p20, .p21, .p22,
        .win_x(w_x), .win_y(w_y), .win_valid(w_valid));
    sobel_grad #(.XW(XW), .YW(YW)) u_sobel (
        .clk, .rst_n, .p00, .p01, .p02, .p10, .p11, .p12, .p20, .p21, .p22, .in_x(w_x), .in_y(w_y), .in_valid(w_valid),
        .ix, .iy, .out_x(g_x), .out_y(g_y), .out_valid(g_valid));
    gradient_products #(.XW(XW), .YW(YW)) u_products (
        .clk, .rst_n, .ix, .iy, .in_x(g_x), .in_y(g_y), .in_valid(g_valid), .pxx, .pyy, .pxy,
        .out_x(gp_x), .out_y(gp_y), .out_valid(gp_valid));
    boxsum5x5 #(.IMAGE_WIDTH(IMAGE_WIDTH), .XW(XW), .YW(YW)) u_boxsum (
        .clk, .rst_n, .pxx, .pyy, .pxy, .in_x(gp_x), .in_y(gp_y), .in_valid(gp_valid), .sxx, .syy, .sxy,
        .out_x(b_x), .out_y(b_y), .out_valid(b_valid));
    harris_response #(.XW(XW), .YW(YW), .K_Q8(K_Q8)) u_response (
        .clk, .rst_n, .sxx, .syy, .sxy, .in_x(b_x), .in_y(b_y), .in_valid(b_valid), .response,
        .out_x(r_x), .out_y(r_y), .out_valid(r_valid));
    corner_threshold #(.XW(XW), .YW(YW), .THRESHOLD(THRESHOLD)) u_threshold (
        .clk, .rst_n, .response, .in_x(r_x), .in_y(r_y), .in_valid(r_valid), .corner(corner_out),
        .out_x(corner_x), .out_y(corner_y), .out_valid(corner_valid));
endmodule
