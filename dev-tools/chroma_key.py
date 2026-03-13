#!/usr/bin/env python3
"""Remove a chroma key color from an image and replace it with transparency."""

import argparse
import os
import sys
from PIL import Image as PILImage


def chroma_key(image: PILImage.Image, target_r: int, target_g: int, target_b: int, tolerance: int, erode: int = 0) -> PILImage.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    w, h = image.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if (abs(r - target_r) <= tolerance and
                abs(g - target_g) <= tolerance and
                abs(b - target_b) <= tolerance):
                pixels[x, y] = (0, 0, 0, 0)
    # Erode: remove opaque pixels that neighbor transparent ones
    for _ in range(erode):
        to_clear = []
        for y in range(h):
            for x in range(w):
                if pixels[x, y][3] == 0:
                    continue
                for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and pixels[nx, ny][3] == 0:
                        to_clear.append((x, y))
                        break
        for x, y in to_clear:
            pixels[x, y] = (0, 0, 0, 0)
    return image


def main() -> None:
    parser = argparse.ArgumentParser(description="Remove a chroma key color from an image.")
    parser.add_argument("image", help="Path to the input image")
    parser.add_argument(
        "--color",
        default="00FF00",
        help="Hex color to remove (default: 00FF00 / neon green)",
    )
    parser.add_argument(
        "--tolerance",
        type=int,
        default=40,
        help="Color matching tolerance 0-255 (default: 40)",
    )
    parser.add_argument(
        "--erode",
        type=int,
        default=0,
        help="Pixels to erode inward from transparent edges (default: 0)",
    )
    parser.add_argument(
        "-o", "--output",
        help="Output path (default: same directory with _keyed suffix)",
    )
    args = parser.parse_args()

    if not os.path.exists(args.image):
        parser.error(f"Image not found: {args.image}")

    hex_color = args.color.lstrip("#")
    target_r = int(hex_color[0:2], 16)
    target_g = int(hex_color[2:4], 16)
    target_b = int(hex_color[4:6], 16)

    image = PILImage.open(args.image)
    result = chroma_key(image, target_r, target_g, target_b, args.tolerance, args.erode)

    if args.output:
        output_path = args.output
    else:
        base, ext = os.path.splitext(args.image)
        output_path = f"{base}_keyed{ext}"

    result.save(output_path)
    print(output_path)


if __name__ == "__main__":
    main()
