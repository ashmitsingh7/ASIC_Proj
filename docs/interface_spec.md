# Interface and streaming contract

`harris_top` accepts `pixel_in` only on cycles where `pixel_valid` is high. Samples are raster ordered, left-to-right then top-to-bottom, with fixed parameterized `IMAGE_WIDTH` and `IMAGE_HEIGHT`. A low `pixel_valid` is a stall: counters, line buffers, and all downstream state hold. After exactly `IMAGE_WIDTH*IMAGE_HEIGHT` accepted samples, the next accepted sample starts a new frame automatically.

`corner_valid` marks each legal integrated response. `corner_x` and `corner_y` are its original image coordinate and `corner_out` is its binary decision. The Sobel stage removes the outer one-pixel border and the 5x5 integration removes a further two pixels, so legal output coordinates are `x in [3, IMAGE_WIDTH-4]` and `y in [3, IMAGE_HEIGHT-4]`. Images smaller than 7 in either dimension produce no valid outputs.

The design has a fixed six-register-stage latency from a complete 3x3 input window to the threshold output. Since input valid may stall, latency in wall-clock cycles varies only by those explicit stalls; latency in accepted datapath transactions is deterministic.
