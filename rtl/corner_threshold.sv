module corner_threshold #(
    parameter int XW = 4,
    parameter int YW = 4,
    parameter logic signed [53:0] THRESHOLD = 54'sd1000000
) (
    input logic clk,
    input logic rst_n,
    input logic signed [53:0] response,
    input logic [XW-1:0] in_x,
    input logic [YW-1:0] in_y,
    input logic in_valid,
    output logic corner,
    output logic [XW-1:0] out_x,
    output logic [YW-1:0] out_y,
    output logic out_valid
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            corner <= 1'b0;
            out_x <= '0;
            out_y <= '0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                corner <= (response > THRESHOLD);
                out_x <= in_x;
                out_y <= in_y;
            end
        end
    end
endmodule
