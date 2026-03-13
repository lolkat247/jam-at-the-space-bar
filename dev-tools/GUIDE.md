# Dev Tools Guide

## sprite_gen.py

Generates consistent 16-bit space-themed pixel art sprites using Google Gemini image generation.

### Setup

```bash
pip install -r dev-tools/requirements.txt
```

Set your API key in `dev-tools/.env`:
```
GEMINI_API_KEY=your_key_here
```

### Usage

```bash
python3 dev-tools/sprite_gen.py "A basketball fruit"
```

### Arguments

| Argument | Default | Description |
|---|---|---|
| `prompt` | (required) | What to generate |
| `--size` | `512` | Target pixel grid size (16–1024) |
| `--final` | off | Use gemini-3-pro-image-preview for higher quality output |
| `--no-postprocess` | off | Skip background removal and color quantization |

### Examples

```bash
# 32x32 sprite for in-game use
python3 dev-tools/sprite_gen.py "A basketball fruit" --size 32

# 16x16 tiny sprite
python3 dev-tools/sprite_gen.py "A glowing space grape" --size 16

# High quality with pro model
python3 dev-tools/sprite_gen.py "A space tavern bartender" --size 16 --final

# Raw model output without post-processing
python3 dev-tools/sprite_gen.py "A space jellyfish" --no-postprocess
```

### Output

Images are saved to `dev-tools/sprite-gen-output/<prompt>.png`.

### How it works

1. Sends prompt to Gemini with space-themed pixel art prefix/suffix
2. Prompt includes size hints so the model generates appropriate detail level
3. Post-processes: flood-fill background removal from edges, edge erosion, 32-color quantize

### Models

| Flag | Model | Use case |
|---|---|---|
| (default) | `gemini-3.1-flash-image-preview` | Fast iteration, free tier |
| `--final` | `gemini-3-pro-image-preview` | Final assets, higher quality |
