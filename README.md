# Streaming Harris Corner Detection ASIC

Synthesizable SystemVerilog implementation of an 8-bit raster-stream Harris detector with 3x3 Sobel gradients, exact gradient products, 5x5 box integration, Q0.8 Harris constant, and binary threshold output.

## Quick start

```bash
cd /home/singh/ASIC_Proj
make regression
make lint
```

`make synthesis` uses Genus only after the university environment is loaded and `STD_CELL_LIB` points to the approved Liberty file. The `cadence/` scripts intentionally require explicit course PDK variables; no technology paths are guessed or copied into the repository.

See `docs/interface_spec.md`, `docs/arithmetic_analysis.md`, and `docs/verification_plan.md` for the numerical and streaming contracts.
