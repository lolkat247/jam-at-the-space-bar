#!/usr/bin/env python3
"""Generate consistent 16-bit space-themed pixel art sprites using HuggingFace models."""

import argparse
import os
import re
import sys

# --- Dependency check ---
_MISSING = []
_PKG_MAP = {"PIL": "Pillow"}
for _pkg in ("torch", "diffusers", "PIL", "safetensors", "peft", "accelerate"):
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

import torch
from diffusers import StableDiffusionXLPipeline, LCMScheduler
from PIL import Image

# --- Constants ---
PROMPT_PREFIX = (
    "pixel art, 16-bit, space themed, retro game sprite, "
    "clean pixel edges, limited color palette, dark space background, "
)
PROMPT_SUFFIX = ", snes style, game asset, sprite sheet style"
NEGATIVE_PROMPT = (
    "3d render, realistic, blurry, photo, watermark, text, "
    "smooth, gradient, high resolution, modern, oil painting"
)


def get_device() -> str:
    if torch.cuda.is_available():
        return "cuda"
    if torch.backends.mps.is_available():
        return "mps"
    return "cpu"


def build_pipeline(device: str) -> StableDiffusionXLPipeline:
    dtype = torch.float16 if device != "cpu" else torch.float32

    pipe = StableDiffusionXLPipeline.from_pretrained(
        "stabilityai/stable-diffusion-xl-base-1.0",
        torch_dtype=dtype,
    )
    pipe.scheduler = LCMScheduler.from_config(pipe.scheduler.config)

    # Load LoRA adapters
    pipe.load_lora_weights(
        "latent-consistency/lcm-lora-sdxl",
        adapter_name="lcm",
    )
    pipe.load_lora_weights(
        "nerijs/pixel-art-xl",
        adapter_name="pixel",
    )
    pipe.set_adapters(["lcm", "pixel"], adapter_weights=[1.0, 1.2])

    pipe = pipe.to(device)
    return pipe


def postprocess(image: Image.Image) -> Image.Image:
    small = image.resize((64, 64), Image.NEAREST)
    big = small.resize((512, 512), Image.NEAREST)
    return big.quantize(colors=32).convert("RGBA")


def sanitize_filename(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")[:80]


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate 16-bit space pixel art sprites.")
    parser.add_argument("prompt", help="The sprite description")
    parser.add_argument("--seed", type=int, default=42, help="Generation seed (default: 42)")
    parser.add_argument(
        "--no-postprocess",
        action="store_true",
        help="Skip pixelation/quantization post-processing",
    )
    args = parser.parse_args()

    device = get_device()
    print(f"Using device: {device}")

    print("Loading model and LoRA adapters...")
    pipe = build_pipeline(device)

    full_prompt = PROMPT_PREFIX + args.prompt + PROMPT_SUFFIX
    generator = torch.Generator(device=device).manual_seed(args.seed)

    print("Generating sprite...")
    result = pipe(
        prompt=full_prompt,
        negative_prompt=NEGATIVE_PROMPT,
        num_inference_steps=8,
        guidance_scale=1.5,
        width=512,
        height=512,
        generator=generator,
    )
    image = result.images[0]

    if not args.no_postprocess:
        image = postprocess(image)

    output_dir = os.path.join(os.path.dirname(__file__), "sprite-gen-output")
    os.makedirs(output_dir, exist_ok=True)
    filename = os.path.join(output_dir, f"output_{sanitize_filename(args.prompt)}.png")
    image.save(filename)
    print(filename)


if __name__ == "__main__":
    main()
