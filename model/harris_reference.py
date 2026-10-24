#!/usr/bin/env python3
"""Bit-exact software model for the Harris streaming RTL."""
from dataclasses import dataclass
from typing import List, Optional, Sequence, Tuple

K_Q8_DEFAULT = 10
THRESHOLD_DEFAULT = 1_000_000


@dataclass
class HarrisResult:
    ix: List[List[Optional[int]]]
    iy: List[List[Optional[int]]]
    pxx: List[List[Optional[int]]]
    pyy: List[List[Optional[int]]]
    pxy: List[List[Optional[int]]]
    sxx: List[List[Optional[int]]]
    syy: List[List[Optional[int]]]
    sxy: List[List[Optional[int]]]
    response: List[List[Optional[int]]]
    corners: List[Tuple[int, int, int]]


def blank(height: int, width: int) -> List[List[Optional[int]]]:
    return [[None for _ in range(width)] for _ in range(height)]


def validate_image(image: Sequence[Sequence[int]]) -> Tuple[int, int]:
    if not image or not image[0]:
        raise ValueError("image must be non-empty")
    height, width = len(image), len(image[0])
    if any(len(row) != width for row in image):
        raise ValueError("image rows must have equal width")
    if any(pixel < 0 or pixel > 255 for row in image for pixel in row):
        raise ValueError("pixels must be integers in [0, 255]")
    return height, width


def harris_fixed(image: Sequence[Sequence[int]], k_q8: int = K_Q8_DEFAULT,
                 threshold: int = THRESHOLD_DEFAULT) -> HarrisResult:
    height, width = validate_image(image)
    if not 0 <= k_q8 <= 255:
        raise ValueError("k_q8 must fit unsigned Q0.8")
    ix, iy = blank(height, width), blank(height, width)
    pxx, pyy, pxy = blank(height, width), blank(height, width), blank(height, width)
    sxx, syy, sxy = blank(height, width), blank(height, width), blank(height, width)
    response = blank(height, width)

    for y in range(1, height - 1):
        for x in range(1, width - 1):
            gx = ((image[y - 1][x + 1] + 2 * image[y][x + 1] + image[y + 1][x + 1])
                  - (image[y - 1][x - 1] + 2 * image[y][x - 1] + image[y + 1][x - 1]))
            gy = ((image[y + 1][x - 1] + 2 * image[y + 1][x] + image[y + 1][x + 1])
                  - (image[y - 1][x - 1] + 2 * image[y - 1][x] + image[y - 1][x + 1]))
            ix[y][x], iy[y][x] = gx, gy
            pxx[y][x], pyy[y][x], pxy[y][x] = gx * gx, gy * gy, gx * gy

    corners: List[Tuple[int, int, int]] = []
    for y in range(3, height - 3):
        for x in range(3, width - 3):
            xx = sum(pxx[row][column] for row in range(y - 2, y + 3) for column in range(x - 2, x + 3))
            yy = sum(pyy[row][column] for row in range(y - 2, y + 3) for column in range(x - 2, x + 3))
            xy = sum(pxy[row][column] for row in range(y - 2, y + 3) for column in range(x - 2, x + 3))
            value = xx * yy - xy * xy - ((k_q8 * (xx + yy) * (xx + yy)) >> 8)
            sxx[y][x], syy[y][x], sxy[y][x], response[y][x] = xx, yy, xy, value
            corners.append((x, y, int(value > threshold)))
    return HarrisResult(ix, iy, pxx, pyy, pxy, sxx, syy, sxy, response, corners)


def pattern(name: str, width: int, height: int, seed: int = 1) -> List[List[int]]:
    import random
    if name == "constant":
        return [[73 for _ in range(width)] for _ in range(height)]
    if name == "horizontal":
        return [[0 if y < height // 2 else 255 for _ in range(width)] for y in range(height)]
    if name == "vertical":
        return [[0 if x < width // 2 else 255 for x in range(width)] for _ in range(height)]
    if name == "diagonal":
        return [[255 if x >= y else 0 for x in range(width)] for y in range(height)]
    if name == "corner":
        return [[255 if x >= width // 2 and y >= height // 2 else 0 for x in range(width)] for y in range(height)]
    if name == "checkerboard":
        return [[255 if ((x // 2) + (y // 2)) % 2 else 0 for x in range(width)] for y in range(height)]
    if name == "random":
        rng = random.Random(seed)
        return [[rng.randrange(256) for _ in range(width)] for _ in range(height)]
    raise ValueError(f"unknown pattern: {name}")
