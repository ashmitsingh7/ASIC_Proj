#!/usr/bin/env bash
set -euo pipefail
project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
if ! command -v genus >/dev/null 2>&1; then
    echo "SKIP: Cadence Genus is not on PATH. Source the university Cadence setup, then rerun."
    exit 0
fi
if [[ -z "${STD_CELL_LIB:-}" ]]; then
    echo "ERROR: set STD_CELL_LIB to the approved standard-cell Liberty file."
    exit 2
fi
mkdir -p "$project_root/build/genus"
genus -files "$project_root/cadence/genus/run_genus.tcl" | tee "$project_root/build/genus/genus.log"
