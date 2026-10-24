#!/usr/bin/env bash
set -euo pipefail
project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
build_dir="$project_root/build"
mkdir -p "$build_dir"
rtl=("$project_root"/rtl/*.sv)
iverilog -g2012 -s tb_sobel_grad -o "$build_dir/tb_sobel_grad.vvp" "${rtl[@]}" "$project_root/tb/unit_testbenches/tb_sobel_grad.sv"
vvp "$build_dir/tb_sobel_grad.vvp"
iverilog -g2012 -s tb_harris -o "$build_dir/tb_harris.vvp" "${rtl[@]}" "$project_root/tb/tb_harris.sv"
for pattern_name in constant horizontal vertical diagonal corner checkerboard random; do
    vector_dir="$build_dir/vectors_$pattern_name"
    python3 "$project_root/model/generate_vectors.py" --pattern "$pattern_name" --width 16 --height 16 --output-dir "$vector_dir"
    vvp "$build_dir/tb_harris.vvp" +INPUT="$vector_dir/input_vectors.hex" +EXPECTED="$vector_dir/expected_corners.txt"
done
echo "Regression PASS"
