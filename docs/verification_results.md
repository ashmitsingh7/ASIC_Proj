# Verification results

Executed on 2026-10-24: `bash scripts/run_regression.sh` passed the Sobel extrema unit test and seven self-checking 16x16 integrations (constant, horizontal, vertical, diagonal, corner, checkerboard, random). Each integrated test drove 256 pixels with valid gaps and checked 100 output coordinates and decisions.

Executed on 2026-10-24: `python3 model/test_reference.py` passed all seven model patterns and confirmed zero output locations at 6x6 and one at the 7x7 minimum. `bash scripts/run_lint.sh` completed successfully with Verilator warnings only for the intentionally unused Sobel center pixel and intentionally discarded Q0.8 fractional bits.

Cadence synthesis, equivalence, STA, physical implementation, and GDSII generation remain unexecuted because `genus`, `conformal`, `tempus`, and `innovus` were absent from `PATH`, and no approved PDK or standard-cell libraries were supplied. The scripts require explicit paths and do not invent technology data.
