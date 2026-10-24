#!/usr/bin/env python3
from harris_reference import harris_fixed, pattern


def main() -> None:
    for name in ("constant", "horizontal", "vertical", "diagonal", "corner", "checkerboard", "random"):
        result = harris_fixed(pattern(name, 16, 16, seed=20261023))
        assert len(result.corners) == 100, name
    assert len(harris_fixed(pattern("corner", 6, 6)).corners) == 0
    assert len(harris_fixed(pattern("corner", 7, 7)).corners) == 1
    print("PASS test_reference")


if __name__ == "__main__":
    main()
