#!/usr/bin/env bash
set -euo pipefail
project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
verilator --lint-only --sv --Wall -Wno-fatal --top-module harris_top "$project_root"/rtl/*.sv
echo "Lint PASS"
