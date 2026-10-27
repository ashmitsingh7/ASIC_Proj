# Streaming Harris Corner Detection ASIC

Synthesizable SystemVerilog implementation of an 8-bit raster-stream Harris detector with 3x3 Sobel gradients, exact gradient products, 5x5 box integration, Q0.8 Harris constant, and binary threshold output.

## Quick start

```bash
cd ASIC_Proj
make regression
make lint
```

`make synthesis` uses Genus only after the university environment is loaded and `STD_CELL_LIB` points to the approved Liberty file. The `cadence/` scripts intentionally require explicit course PDK variables; no technology paths are guessed or copied into the repository.

See `docs/interface_spec.md`, `docs/arithmetic_analysis.md`, and `docs/verification_plan.md` for the numerical and streaming contracts.

## Status

Per `docs/verification_results.md` (executed 2026-10-24):
- ✅ **RTL regression**: Sobel unit test + 7 self-checking 16×16 integration tests PASS
- ✅ **Python model tests**: All 7 patterns PASS; zero output locations at 6×6, one at 7×7 minimum
- ✅ **Verilator lint**: PASS (two intentional warnings: unused Sobel center pixel, discarded Q0.8 fractional bits)
- ❌ **Cadence Genus/Conformal/Tempus/Innovus**: NOT executed (tools absent from PATH; no approved PDK/standard-cell libraries supplied)
- ❌ **GDSII generation**: NOT executed
