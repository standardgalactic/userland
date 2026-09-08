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
