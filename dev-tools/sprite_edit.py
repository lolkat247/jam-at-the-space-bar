#!/usr/bin/env python3
"""Edit existing sprites via text instructions using Google Gemini."""

import argparse
import os
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
from google.genai.types import GenerateContentConfig, Modality
from PIL import Image as PILImage
import io

from sprite_gen import load_api_key, sanitize_filename, postprocess

# --- Constants ---
PROMPT_PREFIX = "pixel art, 16-bit, space themed, maintain pixel art style, "
PROMPT_SUFFIX = ", snes style, game asset"


def main() -> None:
    parser = argparse.ArgumentParser(description="Edit sprites via text instructions.")
    parser.add_argument("image", help="Path to the input image")
    parser.add_argument("instruction", help="Text instruction for the edit")
    parser.add_argument(
        "--final",
        action="store_true",
        help="Use gemini-3-pro-image-preview for higher quality output",
    )
    parser.add_argument(
        "--no-postprocess",
        action="store_true",
        help="Skip background removal and color quantization",
    )
    parser.add_argument(
        "--raw",
        action="store_true",
        help="Use the instruction as-is, bypassing prefix/suffix wrapping",
    )
    args = parser.parse_args()

    if not os.path.exists(args.image):
        parser.error(f"Image not found: {args.image}")

    input_image = PILImage.open(args.image)

    if args.raw:
        full_prompt = args.instruction
    else:
        full_prompt = PROMPT_PREFIX + args.instruction + PROMPT_SUFFIX

    api_key = load_api_key()
    client = genai.Client(api_key=api_key)
    model = "gemini-3-pro-image-preview" if args.final else "gemini-3.1-flash-image-preview"

    print(f"Editing image with {model}...")
    response = client.models.generate_content(
        model=model,
        contents=[input_image, full_prompt],
        config=GenerateContentConfig(
            response_modalities=[Modality.TEXT, Modality.IMAGE],
        ),
    )

    image = None
    if not response.parts:
        print("Model returned an empty response. It may have refused the prompt.", file=sys.stderr)
        sys.exit(1)
    for part in response.parts:
        if part.text is not None:
            print(part.text)
        elif part.inline_data is not None:
            image = PILImage.open(io.BytesIO(part.inline_data.data))

    if image is None:
        print("No image was generated.", file=sys.stderr)
        sys.exit(1)

    if not args.no_postprocess:
        image = postprocess(image)

    output_dir = os.path.join(os.path.dirname(__file__), "sprite-gen-output")
    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.join(output_dir, f"{sanitize_filename(args.instruction)}.png")
    image.save(filename)
    print(filename)


if __name__ == "__main__":
    main()
