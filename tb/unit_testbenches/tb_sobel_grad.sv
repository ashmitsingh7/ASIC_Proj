`timescale 1ns/1ps
module tb_sobel_grad;
    logic clk = 0, rst_n = 0, in_valid = 0;
    logic [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
    logic signed [10:0] ix, iy;
    logic [3:0] in_x, in_y, out_x, out_y;
    logic out_valid;
    sobel_grad dut (.*);
    always #5 clk = ~clk;
    initial begin
        {p00,p01,p02,p10,p11,p12,p20,p21,p22} = '0;
        #12 rst_n = 1;
        @(negedge clk);
        p02=8'd255; p12=8'd255; p22=8'd255; in_x=4'd3; in_y=4'd4; in_valid=1;
        @(negedge clk); in_valid=0;
        @(posedge clk);
        if (!out_valid || ix !== 11'sd1020 || iy !== 11'sd0 || out_x !== 4'd3 || out_y !== 4'd4) $fatal(1, "positive Sobel case failed");
        @(negedge clk);
        {p00,p01,p02,p10,p11,p12,p20,p21,p22} = '0;
        p00=8'd255; p10=8'd255; p20=8'd255; in_valid=1;
        @(negedge clk); in_valid=0;
        @(posedge clk);
        if (!out_valid || ix !== -11'sd1020) $fatal(1, "negative Sobel case failed");
        $display("PASS tb_sobel_grad");
        $finish;
    end
endmodule
