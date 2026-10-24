# Architecture

The accelerator uses two pixel line buffers plus horizontal taps to form a 3x3 Sobel window without storing a frame. The Sobel result is converted to three gradient-product streams. `boxsum5x5` uses four line buffers per product and five-entry horizontal shift state to integrate the products over the required 5x5 neighborhood. The response stage evaluates the integer Harris equation and the threshold stage emits a binary decision. No non-maximum suppression is included.

The input path accepts one pixel per clock whenever `pixel_valid` is asserted. All line memories are only image-width deep.
