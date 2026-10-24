# Verification plan

The integration regression generates independent software vectors for constant, horizontal-edge, vertical-edge, diagonal-edge, synthetic-corner, checkerboard, and seeded-random images. It drives a valid gap every seventh pixel, checks every output coordinate and binary decision, and enforces a simulation timeout. The Sobel unit test checks the exact `+1020` and `-1020` extrema.

Run `make regression` for simulation and `make lint` for Verilator static checks. The vector model accepts arbitrary dimensions, including minimum-size images; the supplied RTL regression uses 16x16 because hardware parameters are compile-time constants.
