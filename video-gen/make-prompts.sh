#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS="${ROOT}/prompts"

mkdir -p "${PROMPTS}"

write_prompt() {
    local file="$1"
    local title="$2"
    local body="$3"

    local path="${PROMPTS}/${file}"

    if [[ -e "${path}" ]]; then
        echo "skip: ${file} already exists"
        return
    fi

    cat > "${path}" <<EOF
# ${title}

${body}
EOF

    echo "created: ${file}"
}

write_prompt \
"01-modern-skin.txt" \
"Modern Skin" \
"A slow cinematic macro tracking shot across a contemporary computer motherboard.

Precision-machined aluminum heatsinks, black integrated circuits, clean green circuit boards and tiny surface-mount components fill the frame.

The camera moves slowly and deliberately across the surface.

The scene should feel clinical, cold, precise and contemporary.

Realistic macro photography, shallow depth of field, subtle reflections, restrained movement, no text, no people."

write_prompt \
"02-industrial-substrate.txt" \
"Industrial Substrate" \
"A modern computer motherboard begins to separate physically into layers.

Beneath the printed circuit board is an older industrial technological substrate made from ceramic relays, brass gears, copper contacts, cloth-insulated wiring and telephone-exchange components.

The transformation is continuous and mechanical rather than a dissolve.

Cold modern electronics gradually give way to warm amber metals and tactile electromechanical machinery.

Slow macro camera movement, realistic materials, restrained mechanical motion, cinematic lighting, no text, no people."

write_prompt \
"03-dawn-of-glass.txt" \
"Dawn of Glass" \
"The camera descends deeper beneath a layer of brass gears and electromechanical relays.

Rows of glowing vacuum tubes appear underneath.

Orange filaments pulse faintly inside clear glass envelopes while punched paper tape moves slowly through nearby machinery.

Copper wiring and ceramic sockets surround the tubes.

The technology feels older, warmer and more physical with every layer.

Slow cinematic macro movement, realistic glass and metal, dark background, warm filament light, no text, no people."

write_prompt \
"04-electromechanical-depth.txt" \
"Electromechanical Depth" \
"A dense mechanical computing layer hidden beneath early vacuum tube electronics.

Rotating shafts, stepping relays, cam mechanisms, brass linkages, perforated metal plates and electromechanical counters operate in a tightly packed machine.

The camera slowly moves inward through the machinery as if descending through geological technological strata.

Every component should appear functional rather than decorative.

Industrial realism, close macro photography, restrained motion, oily metal, ceramic insulation, copper wiring, no text, no people."

write_prompt \
"05-organic-machinery.txt" \
"Organic Machinery" \
"The mechanical computing machinery gradually gives way to structures that appear partly engineered and partly biological.

Copper conductors branch like vascular systems.

Flexible translucent tubes carry faintly glowing fluid between mechanical components.

Metallic housings merge into fibrous tissue-like structures.

Mechanical gears remain visible but are increasingly integrated with living-looking material.

The transition must be gradual and physically continuous.

Biotechnological realism, subdued illumination, slow macro camera motion, intricate physical detail, no text, no people."

write_prompt \
"06-neural-core.txt" \
"Neural Core" \
"At the deepest layer of the technological structure is a dense neural-mechanical core.

Bioluminescent nerve-like fibers intertwine with microscopic gears, copper conductors and tiny mechanical switches.

Slow electrical pulses travel through branching organic networks.

The machinery appears ancient, biological and computational at the same time.

The camera approaches the luminous core slowly without revealing any obvious central processor.

Dark environment, subtle blue-green bioluminescence, realistic wet and metallic materials, restrained motion, no text, no people."

echo
echo "Prompt files are in:"
echo "  ${PROMPTS}"
echo
echo "List them with:"
echo "  ls -1 prompts/"
