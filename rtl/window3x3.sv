module window3x3 #(
    parameter int IMAGE_WIDTH  = 16,
    parameter int IMAGE_HEIGHT = 16,
    parameter int XW = (IMAGE_WIDTH  <= 1) ? 1 : $clog2(IMAGE_WIDTH),
    parameter int YW = (IMAGE_HEIGHT <= 1) ? 1 : $clog2(IMAGE_HEIGHT)
) (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [7:0]   pixel_in,
    input  logic         pixel_valid,
    output logic [7:0]   p00, p01, p02,
    output logic [7:0]   p10, p11, p12,
    output logic [7:0]   p20, p21, p22,
    output logic [XW-1:0] win_x,
    output logic [YW-1:0] win_y,
    output logic         win_valid
);
    logic [7:0] line1 [0:IMAGE_WIDTH-1];
    logic [7:0] line2 [0:IMAGE_WIDTH-1];
    logic [7:0] top_older, top_previous;
    logic [7:0] mid_older, mid_previous;
    logic [7:0] bot_older, bot_previous;
    logic [XW-1:0] column;
    logic [YW-1:0] row;
    localparam logic [XW-1:0] LAST_COLUMN = IMAGE_WIDTH - 1;
    localparam logic [YW-1:0] LAST_ROW = IMAGE_HEIGHT - 1;
    integer index;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            column <= '0;
            row <= '0;
            top_older <= '0; top_previous <= '0;
            mid_older <= '0; mid_previous <= '0;
            bot_older <= '0; bot_previous <= '0;
            p00 <= '0; p01 <= '0; p02 <= '0;
            p10 <= '0; p11 <= '0; p12 <= '0;
            p20 <= '0; p21 <= '0; p22 <= '0;
            win_x <= '0;
            win_y <= '0;
            win_valid <= 1'b0;
            for (index = 0; index < IMAGE_WIDTH; index = index + 1) begin
                line1[index] <= '0;
                line2[index] <= '0;
            end
        end else begin
            win_valid <= 1'b0;
            if (pixel_valid) begin
                line2[column] <= line1[column];
                line1[column] <= pixel_in;
                p00 <= top_older;
                p01 <= top_previous;
                p02 <= line2[column];
                p10 <= mid_older;
                p11 <= mid_previous;
                p12 <= line1[column];
                p20 <= bot_older;
                p21 <= bot_previous;
                p22 <= pixel_in;
                win_x <= column - 1'b1;
                win_y <= row - 1'b1;
                win_valid <= (row >= 2) && (column >= 2);
                if (column == LAST_COLUMN) begin
                    column <= '0;
                    top_older <= '0; top_previous <= '0;
                    mid_older <= '0; mid_previous <= '0;
                    bot_older <= '0; bot_previous <= '0;
                    if (row == LAST_ROW)
                        row <= '0;
                    else
                        row <= row + 1'b1;
                end else begin
                    column <= column + 1'b1;
                    top_older <= top_previous;
                    top_previous <= line2[column];
                    mid_older <= mid_previous;
                    mid_previous <= line1[column];
                    bot_older <= bot_previous;
                    bot_previous <= pixel_in;
                end
            end
        end
    end
endmodule
