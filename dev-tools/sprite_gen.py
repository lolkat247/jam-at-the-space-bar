#!/usr/bin/env python3
"""Generate consistent 16-bit space-themed pixel art sprites using Google Gemini."""

import argparse
import os
import re
import sys

# --- Dependency check ---
_MISSING = []
_PKG_MAP = {"PIL": "Pillow", "google.genai": "google-genai"}
for _pkg in ("google.genai", "PIL"):
    try:
        __import__(_pkg)
    except (ImportError, Exception):
        _MISSING.append(_PKG_MAP.get(_pkg, _pkg))
if _MISSING:
    print(
        f"Missing or broken dependencies: {', '.join(_MISSING)}\n"
        f"Install/upgrade them with:\n  pip install --upgrade {' '.join(_MISSING)}",
        file=sys.stderr,
    )
    sys.exit(1)

from google import genai
from PIL import Image as PILImage
import io

# --- Constants ---
PROMPT_PREFIX = (
    "pixel art, 16-bit, space themed, retro game sprite, "
    "clean pixel edges, plain white background, centered, "
)
PROMPT_SUFFIX = ", snes style, game asset"


def sanitize_filename(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")[:80]


def load_api_key() -> str:
    # Check environment first, then .env file
    key = os.environ.get("GEMINI_API_KEY")
    if key:
        return key
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    if os.path.exists(env_path):
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line.startswith("GEMINI_API_KEY="):
                    return line.split("=", 1)[1]
    print("GEMINI_API_KEY not found. Set it in your environment or in dev-tools/.env", file=sys.stderr)
    sys.exit(1)


def remove_background(image: PILImage.Image, tolerance: int = 30, erode: int = 2) -> PILImage.Image:
    """Remove background via flood-fill from edges, then erode fringe pixels."""
    from collections import deque

    image = image.convert("RGBA")
    pixels = image.load()
    w, h = image.size

    # Sample background color from corners
    corners = [pixels[0, 0], pixels[w - 1, 0], pixels[0, h - 1], pixels[w - 1, h - 1]]
    bg_color = max(set(corners), key=corners.count)

    def matches_bg(x, y):
        r, g, b, a = pixels[x, y]
        return (abs(r - bg_color[0]) <= tolerance and
                abs(g - bg_color[1]) <= tolerance and
                abs(b - bg_color[2]) <= tolerance)

    # Flood-fill from all edge pixels that match the background
    visited = set()
    queue = deque()
    for x in range(w):
        for y in (0, h - 1):
            if matches_bg(x, y):
                queue.append((x, y))
                visited.add((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if matches_bg(x, y) and (x, y) not in visited:
                queue.append((x, y))
                visited.add((x, y))

    while queue:
        x, y = queue.popleft()
        pixels[x, y] = (0, 0, 0, 0)
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in visited and matches_bg(nx, ny):
                visited.add((nx, ny))
                queue.append((nx, ny))

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


def postprocess(image: PILImage.Image) -> PILImage.Image:
    image = remove_background(image)
    return image.quantize(colors=32).convert("RGBA")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate 16-bit space pixel art sprites.")
    parser.add_argument("prompt", help="The sprite description")
    parser.add_argument(
        "--size",
        type=int,
        default=512,
        help="Target pixel grid size, e.g. 16, 32, 64, 512 (default: 512)",
    )
    parser.add_argument(
        "--final",
        action="store_true",
        help="Use gemini-3-pro-image-preview for higher quality output",
    )
    parser.add_argument(
        "--no-postprocess",
        action="store_true",
        help="Skip color quantization post-processing",
    )
    parser.add_argument(
        "--raw",
        action="store_true",
        help="Use the prompt as-is, bypassing prefix/suffix wrapping",
    )
    args = parser.parse_args()

    if args.size < 16 or args.size > 1024:
        parser.error("--size must be between 16 and 1024")

    api_key = load_api_key()
    client = genai.Client(api_key=api_key)

    # Tell the model what pixel grid to target
    if args.size <= 16:
        size_hint = "16x16 grid, very chunky blocks, minimal detail, "
    elif args.size <= 32:
        size_hint = "32x32 grid, chunky pixels, simple shapes, "
    elif args.size <= 64:
        size_hint = "64x64 grid, visible pixel blocks, "
    elif args.size <= 128:
        size_hint = "128x128 grid, detailed, "
    else:
        size_hint = ""

    if args.raw:
        full_prompt = args.prompt
    else:
        full_prompt = PROMPT_PREFIX + size_hint + args.prompt + PROMPT_SUFFIX

    print(f"Generating sprite (targeting {args.size}x{args.size} pixel grid)...")
    response = client.models.generate_content(
        model="gemini-3-pro-image-preview" if args.final else "gemini-3.1-flash-image-preview",
        contents=[full_prompt],
    )

    image = None
    if not response.parts:
        print("Model returned an empty response. It may have refused the prompt.", file=sys.stderr)
        sys.exit(1)
    for part in response.parts:
        if part.text is not None:
            print(part.text)
        elif part.inline_data is not None:
            image_data = part.inline_data.data
            image = PILImage.open(io.BytesIO(image_data))

    if image is None:
        print("No image was generated.", file=sys.stderr)
        sys.exit(1)

    if not args.no_postprocess:
        image = postprocess(image)

    output_dir = os.path.join(os.path.dirname(__file__), "sprite-gen-output")
    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.join(output_dir, f"{sanitize_filename(args.prompt)}.png")
    image.save(filename)
    print(filename)


if __name__ == "__main__":
    main()
