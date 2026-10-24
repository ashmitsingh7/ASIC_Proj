#!/usr/bin/env python3
import argparse
from pathlib import Path
from harris_reference import THRESHOLD_DEFAULT, harris_fixed, pattern


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pattern", default="corner", choices=["constant", "horizontal", "vertical", "diagonal", "corner", "checkerboard", "random"])
    parser.add_argument("--width", type=int, default=16)
    parser.add_argument("--height", type=int, default=16)
    parser.add_argument("--threshold", type=int, default=THRESHOLD_DEFAULT)
    parser.add_argument("--seed", type=int, default=20261023)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    image = pattern(args.pattern, args.width, args.height, args.seed)
    result = harris_fixed(image, threshold=args.threshold)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    (args.output_dir / "input_vectors.hex").write_text("".join(f"{value:02x}\n" for row in image for value in row))
    (args.output_dir / "expected_corners.txt").write_text("".join(f"{x} {y} {corner}\n" for x, y, corner in result.corners))
    (args.output_dir / "summary.txt").write_text(
        f"pattern={args.pattern}\nwidth={args.width}\nheight={args.height}\nthreshold={args.threshold}\noutputs={len(result.corners)}\ncorners={sum(corner for _, _, corner in result.corners)}\n")


if __name__ == "__main__":
    main()
