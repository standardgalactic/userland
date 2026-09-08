#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Local Video Generator
# CogVideoX-2B + Diffusers + RTX 5060 / low-VRAM configuration
#
# Installs to:
#     ~/video-gen
#
# Creates:
#     ~/video-gen/.venv/
#     ~/video-gen/generate.py
#     ~/video-gen/video.sh
#     ~/video-gen/prompts/
#     ~/video-gen/output/
# ============================================================

PROJECT="${HOME}/video-gen"

echo
echo "============================================================"
echo " Local Video Generator Installer"
echo "============================================================"
echo
echo "Project directory:"
echo "  ${PROJECT}"
echo

# ------------------------------------------------------------
# System packages
# ------------------------------------------------------------

echo "[1/7] Installing system dependencies..."

sudo apt update

sudo apt install -y \
    python3 \
    python3-venv \
    python3-pip \
    ffmpeg \
    git

# ------------------------------------------------------------
# Check existing PyTorch/CUDA
# ------------------------------------------------------------

echo
echo "[2/7] Checking existing PyTorch/CUDA installation..."

USE_SYSTEM_TORCH=0

if python3 - <<'PY' >/tmp/video-gen-torch-check.txt 2>&1
import torch
assert torch.cuda.is_available()
print(torch.__version__)
print(torch.version.cuda)
print(torch.cuda.get_device_name(0))
print(torch.cuda.get_device_properties(0).total_memory)
PY
then
    USE_SYSTEM_TORCH=1

    echo
    echo "Existing CUDA-enabled PyTorch found:"
    cat /tmp/video-gen-torch-check.txt
    echo
    echo "The virtual environment will reuse this working PyTorch."
else
    echo
    echo "No usable CUDA-enabled system PyTorch detected."
    echo "The installer will install PyTorch inside the virtual environment."
fi

rm -f /tmp/video-gen-torch-check.txt

# ------------------------------------------------------------
# Project directories
# ------------------------------------------------------------

echo
echo "[3/7] Creating project..."

mkdir -p \
    "${PROJECT}" \
    "${PROJECT}/prompts" \
    "${PROJECT}/output"

cd "${PROJECT}"

# ------------------------------------------------------------
# Python environment
# ------------------------------------------------------------

echo
echo "[4/7] Creating Python virtual environment..."

if [[ -d .venv ]]; then
    echo "Existing .venv found."
else
    if [[ "${USE_SYSTEM_TORCH}" -eq 1 ]]; then
        python3 -m venv --system-site-packages .venv
    else
        python3 -m venv .venv
    fi
fi

source .venv/bin/activate

python -m pip install --upgrade \
    pip \
    wheel \
    setuptools

if ! python - <<'PY' >/dev/null 2>&1
import torch
assert torch.cuda.is_available()
PY
then
    echo
    echo "Installing PyTorch..."

    # This intentionally uses PyPI rather than forcing a CUDA version.
    # Your NVIDIA driver supplies the underlying GPU support.
    pip install \
        torch \
        torchvision
fi

# ------------------------------------------------------------
# Video-generation dependencies
# ------------------------------------------------------------

echo
echo "[5/7] Installing video-generation libraries..."

pip install --upgrade \
    diffusers \
    transformers \
    accelerate \
    sentencepiece \
    protobuf \
    safetensors \
    huggingface-hub \
    imageio \
    imageio-ffmpeg \
    pillow

# ------------------------------------------------------------
# Generator
# ------------------------------------------------------------

echo
echo "[6/7] Writing generator..."

cat > "${PROJECT}/generate.py" <<'PY'
#!/usr/bin/env python3

import argparse
import os
import time

import torch

from diffusers import CogVideoXPipeline
from diffusers.utils import export_to_video


MODEL = "zai-org/CogVideoX-2b"


def gib(value):
    return value / (1024 ** 3)


def main():
    parser = argparse.ArgumentParser(
        description="Generate a short video with CogVideoX-2B."
    )

    parser.add_argument(
        "prompt",
        help="Text prompt.",
    )

    parser.add_argument(
        "-o",
        "--output",
        default="output/video.mp4",
        help="Output MP4 filename.",
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=42,
    )

    parser.add_argument(
        "--steps",
        type=int,
        default=20,
        help="Inference steps. Start with 20 for testing.",
    )

    parser.add_argument(
        "--guidance",
        type=float,
        default=6.0,
    )

    parser.add_argument(
        "--fps",
        type=int,
        default=8,
    )

    parser.add_argument(
        "--frames",
        type=int,
        default=49,
    )

    parser.add_argument(
        "--width",
        type=int,
        default=720,
    )

    parser.add_argument(
        "--height",
        type=int,
        default=480,
    )

    args = parser.parse_args()

    if not torch.cuda.is_available():
        raise RuntimeError(
            "CUDA is not available to PyTorch."
        )

    gpu = torch.cuda.get_device_properties(0)

    print()
    print("================================================")
    print(" Local CogVideoX")
    print("================================================")
    print("PyTorch:     ", torch.__version__)
    print("CUDA runtime:", torch.version.cuda)
    print("GPU:         ", torch.cuda.get_device_name(0))
    print("VRAM:        ", f"{gib(gpu.total_memory):.2f} GiB")
    print()

    if torch.cuda.is_bf16_supported():
        dtype = torch.bfloat16
    else:
        dtype = torch.float16

    print("Model:       ", MODEL)
    print("dtype:       ", dtype)
    print("resolution:  ", f"{args.width}x{args.height}")
    print("frames:      ", args.frames)
    print("steps:       ", args.steps)
    print("seed:        ", args.seed)
    print()

    print("Loading model...")
    print(
        "The first run will download the model from Hugging Face."
    )
    print()

    pipe = CogVideoXPipeline.from_pretrained(
        MODEL,
        torch_dtype=dtype,
    )

    # --------------------------------------------------------
    # RTX 5060 / 8 GB VRAM survival settings
    # --------------------------------------------------------

    pipe.enable_sequential_cpu_offload()

    pipe.vae.enable_slicing()
    pipe.vae.enable_tiling()

    # Reduce CPU-memory duplication during attention where possible.
    if hasattr(pipe, "enable_attention_slicing"):
        try:
            pipe.enable_attention_slicing()
        except Exception:
            pass

    generator = torch.Generator(
        device="cpu"
    ).manual_seed(args.seed)

    output_dir = os.path.dirname(args.output)

    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    print("Prompt:")
    print()
    print(args.prompt)
    print()
    print("Generating...")
    print()

    started = time.time()

    result = pipe(
        prompt=args.prompt,
        height=args.height,
        width=args.width,
        num_frames=args.frames,
        num_inference_steps=args.steps,
        guidance_scale=args.guidance,
        generator=generator,
    )

    frames = result.frames[0]

    elapsed = time.time() - started

    print()
    print("Encoding MP4...")

    export_to_video(
        frames,
        args.output,
        fps=args.fps,
    )

    print()
    print("================================================")
    print(" Finished")
    print("================================================")
    print("Output:", args.output)
    print("Time:  ", f"{elapsed:.1f} seconds")
    print()


if __name__ == "__main__":
    main()
PY

chmod +x "${PROJECT}/generate.py"

# ------------------------------------------------------------
# Bash frontend
# ------------------------------------------------------------

cat > "${PROJECT}/video.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${HERE}/.venv/bin/activate"

if [[ $# -lt 1 ]]; then
    cat <<EOF

Local CogVideoX video generator

Usage:

    ./video.sh "prompt"

    ./video.sh "prompt" output/name.mp4

Examples:

    ./video.sh \
      "A spacecraft drifting silently above an alien planet."

    ./video.sh \
      "\$(cat prompts/archaeology.txt)" \
      output/archaeology.mp4

Advanced options can be passed directly to generate.py:

    python generate.py \
      "prompt" \
      --steps 30 \
      --seed 123 \
      --fps 8 \
      -o output/test.mp4

EOF
    exit 1
fi

PROMPT="$1"

if [[ $# -ge 2 ]]; then
    OUT="$2"
else
    TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
    OUT="${HERE}/output/video-${TIMESTAMP}.mp4"
fi

python "${HERE}/generate.py" \
    "${PROMPT}" \
    --output "${OUT}"
SH

chmod +x "${PROJECT}/video.sh"

# ------------------------------------------------------------
# Initial technological-archaeology prompt
# ------------------------------------------------------------

cat > "${PROJECT}/prompts/archaeology-01.txt" <<'EOF'
A slow cinematic macro tracking shot across a modern computer motherboard.

Precision-machined aluminum heatsinks, clean black electronic components and
contemporary circuitry gradually separate and peel apart, revealing an
impossible older technological substrate hidden underneath.

Beneath the modern electronics are ceramic electrical relays, tiny precision
brass gears, copper contacts and waxed cloth telephone-exchange wiring.

The image transitions gradually from cold silver and black modern technology
into warm amber industrial machinery.

The transformation appears physically continuous rather than a dissolve or
scene change, as though successive technological eras have literally been
constructed underneath one another.

Highly detailed physical materials, realistic macro photography, shallow depth
of field, restrained deliberate camera movement, subtle mechanical movement,
cinematic lighting, no text, no people.
EOF

# ------------------------------------------------------------
# Diagnostic helper
# ------------------------------------------------------------

cat > "${PROJECT}/check-gpu.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${HERE}/.venv/bin/activate"

python - <<'PY'
import torch

print()
print("PyTorch:", torch.__version__)
print("CUDA runtime:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if torch.cuda.is_available():
    p = torch.cuda.get_device_properties(0)

    print("GPU:", torch.cuda.get_device_name(0))
    print(
        "VRAM:",
        round(p.total_memory / 1024**3, 2),
        "GiB",
    )

    print(
        "BF16:",
        torch.cuda.is_bf16_supported(),
    )

print()
PY

echo "nvidia-smi:"
echo

nvidia-smi
SH

chmod +x "${PROJECT}/check-gpu.sh"

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo
echo "[7/7] Checking installation..."
echo

"${PROJECT}/check-gpu.sh"

echo
echo "============================================================"
echo " Installation complete"
echo "============================================================"
echo
echo "Project:"
echo
echo "    cd ${PROJECT}"
echo
echo "First test:"
echo
echo '    ./video.sh "$(cat prompts/archaeology-01.txt)" output/archaeology-01.mp4'
echo
echo "Monitor the GPU from another terminal with:"
echo
echo "    watch -n 1 nvidia-smi"
echo
echo "Open the directory in Windows Explorer with:"
echo
echo "    explorer.exe ."
echo
