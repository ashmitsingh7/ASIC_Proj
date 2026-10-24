`timescale 1ns/1ps
module tb_harris;
    localparam int IMAGE_WIDTH = 16;
    localparam int IMAGE_HEIGHT = 16;
    localparam int XW = $clog2(IMAGE_WIDTH);
    localparam int YW = $clog2(IMAGE_HEIGHT);
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic [7:0] pixel_in = '0;
    logic pixel_valid = 1'b0;
    logic corner_out, corner_valid;
    logic [XW-1:0] corner_x;
    logic [YW-1:0] corner_y;
    integer input_file, expected_file, status;
    integer input_value, expected_x, expected_y, expected_corner;
    integer drive_count, observed_count, failures;
    string input_path, expected_path;

    harris_top #(.IMAGE_WIDTH(IMAGE_WIDTH), .IMAGE_HEIGHT(IMAGE_HEIGHT)) dut (
        .clk, .rst_n, .pixel_in, .pixel_valid, .corner_out, .corner_valid, .corner_x, .corner_y);

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst_n && corner_valid) begin
            status = $fscanf(expected_file, "%d %d %d\n", expected_x, expected_y, expected_corner);
            if (status != 3) begin
                $display("FAIL unexpected valid output at cycle %0t", $time / 10);
                failures = failures + 1;
            end else if ((corner_x !== expected_x[XW-1:0]) || (corner_y !== expected_y[YW-1:0]) || (corner_out !== expected_corner[0])) begin
                $display("FAIL cycle=%0t expected=(%0d,%0d,%0d) actual=(%0d,%0d,%0d)",
                         $time / 10, expected_x, expected_y, expected_corner, corner_x, corner_y, corner_out);
                failures = failures + 1;
            end
            observed_count = observed_count + 1;
        end
    end

    initial begin
        if (!$value$plusargs("INPUT=%s", input_path)) input_path = "build/input_vectors.hex";
        if (!$value$plusargs("EXPECTED=%s", expected_path)) expected_path = "build/expected_corners.txt";
        input_file = $fopen(input_path, "r");
        expected_file = $fopen(expected_path, "r");
        if ((input_file == 0) || (expected_file == 0)) $fatal(1, "unable to open vector files");
        failures = 0;
        drive_count = 0;
        observed_count = 0;
        repeat (3) @(negedge clk);
        rst_n = 1'b1;
        while ($fscanf(input_file, "%h\n", input_value) == 1) begin
            if ((drive_count != 0) && ((drive_count % 7) == 0)) begin
                pixel_valid = 1'b0;
                @(negedge clk);
            end
            pixel_in = input_value[7:0];
            pixel_valid = 1'b1;
            drive_count = drive_count + 1;
            @(negedge clk);
        end
        pixel_valid = 1'b0;
        repeat (20) @(negedge clk);
        status = $fscanf(expected_file, "%d %d %d\n", expected_x, expected_y, expected_corner);
        if (status == 3) begin
            $display("FAIL missing output beginning at (%0d,%0d)", expected_x, expected_y);
            failures = failures + 1;
        end
        $fclose(input_file);
        $fclose(expected_file);
        if (failures != 0) $fatal(1, "tb_harris failed: %0d mismatches", failures);
        $display("PASS tb_harris inputs=%0d outputs=%0d", drive_count, observed_count);
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "simulation timeout");
    end
endmodule
