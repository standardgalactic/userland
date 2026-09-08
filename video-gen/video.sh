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
