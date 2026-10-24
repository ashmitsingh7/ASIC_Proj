# Arithmetic analysis

All arithmetic is integer exact through thresholding. Pixels are unsigned 8-bit values in `[0,255]`.

| Stage | Quantity | Signedness and width | Conservative range |
|---|---|---:|---:|
| Sobel | `Ix`, `Iy` | signed 11-bit | `[-1020,1020]` |
| Products | `Pxx`, `Pyy` | unsigned 20-bit | `[0,1,040,400]` |
| Products | `Pxy` | signed 21-bit | `[-1,040,400,1,040,400]` |
| 5-row sum | `Pxx`, `Pyy` | unsigned 23-bit | `[0,5,202,000]` |
| 5-row sum | `Pxy` | signed 24-bit | `[-5,202,000,5,202,000]` |
| 5x5 sum | `Sxx`, `Syy` | unsigned 25-bit | `[0,26,010,000]` |
| 5x5 sum | `Sxy` | signed 26-bit | `[-26,010,000,26,010,000]` |
| Response | determinant | unsigned 50-bit | `[0,676,520,100,000,000]` |
| Response | `Sxy²`, trace² | signed/unsigned 52-bit | non-negative, below `2^52` |
| Response | final `R` | signed 54-bit | safely contains all supported `K_Q8` values |

`k` uses unsigned Q0.8 (`K_Q8/256`); the default `K_Q8=10` represents `0.0390625`. The penalty is `(K_Q8 * trace²) >> 8`, truncating only the fractional Q0.8 product. The Python reference performs the identical floor shift. The threshold has the same integer scale as `R`; a pixel is asserted exactly when `R > THRESHOLD`.
