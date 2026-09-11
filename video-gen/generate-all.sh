#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${ROOT}/output"

for prompt in "${ROOT}"/prompts/*.txt; do
    name="$(basename "${prompt}" .txt)"
    out="${ROOT}/output/${name}.mp4"

    echo
    echo "========================================"
    echo "Generating: ${name}"
    echo "========================================"

    "${ROOT}/video.sh" \
        "$(cat "${prompt}")" \
        "${out}"
done
