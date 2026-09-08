# Local Video Generator

A small Bash-driven local video generation pipeline using CogVideoX, Hugging Face Diffusers, PyTorch, and `ffmpeg`.

This setup is intended for Linux or WSL with an NVIDIA GPU and is currently configured around an RTX 5060 with roughly 8 GB of VRAM. Because modern video diffusion models are substantially heavier than image diffusion models, the pipeline uses aggressive CPU offloading, VAE slicing, and VAE tiling to keep GPU memory usage within range.

## Current environment

The working test system reports:

```text
PyTorch: 2.13.0+cu130
CUDA runtime: 13.0
CUDA available: True
GPU: NVIDIA GeForce RTX 5060
VRAM: 7.96 GB
```

The project lives at:

```text
~/userland/video-gen
```

The expected structure is:

```text
video-gen/
├── .venv/
├── generate.py
├── video.sh
├── check-gpu.sh
├── README.md
├── prompts/
│   └── archaeology-01.txt
└── output/
```

## Important note about the virtual environment

Do not move the project directory after creating `.venv`.

Python virtual environments contain absolute paths internally. If the project is moved from one directory to another, executables such as `pip` may continue pointing to the old path and fail with errors such as:

```text
bad interpreter
```

or:

```text
No such file or directory
```

If the project has been moved, recreate the virtual environment:

```bash
cd ~/userland/video-gen

deactivate 2>/dev/null || true

rm -rf .venv

python3 -m venv .venv
source .venv/bin/activate
```

Then reinstall the dependencies.

## Installing dependencies

Activate the virtual environment:

```bash
cd ~/userland/video-gen
source .venv/bin/activate
```

Upgrade the packaging tools:

```bash
python -m pip install -U pip wheel setuptools
```

Install the video generation stack:

```bash
python -m pip install -U \
    torch \
    torchvision \
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
```

The `protobuf` package is important. CogVideoX uses a SentencePiece tokenizer, and without protobuf some recent versions of Transformers may incorrectly fall back to trying to interpret `spiece.model` as a tiktoken vocabulary.

That produces an error similar to:

```text
ValueError: Error parsing line ... in tokenizer/spiece.model
```

If that happens, run:

```bash
python -m pip install -U protobuf sentencepiece
```

## Check the GPU

Before generating video, verify that PyTorch sees CUDA:

```bash
python - <<'PY'
import torch

print("torch:", torch.__version__)
print("CUDA runtime:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())

if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))
    print(
        "VRAM:",
        round(
            torch.cuda.get_device_properties(0).total_memory / 1024**3,
            2,
        ),
        "GB",
    )
PY
```

A healthy result should resemble:

```text
torch: 2.13.0+cu130
CUDA runtime: 13.0
CUDA available: True
GPU: NVIDIA GeForce RTX 5060
VRAM: 7.96 GB
```

The exact CUDA runtime version does not need to match the NVIDIA driver version exactly. If PyTorch reports CUDA as available and recognizes the GPU correctly, avoid reinstalling CUDA unnecessarily.

## Test the tokenizer

Before loading the complete model, test the tokenizer separately:

```bash
python - <<'PY'
from transformers import T5Tokenizer

tok = T5Tokenizer.from_pretrained(
    "zai-org/CogVideoX-2b",
    subfolder="tokenizer",
)

print(type(tok))
print(tok("hello from CogVideoX"))
PY
```

If this completes successfully, the tokenizer dependencies are working.

## First generation

Run:

```bash
cd ~/userland/video-gen
source .venv/bin/activate
```

Then generate the first technological archaeology shot:

```bash
./video.sh \
    "$(cat prompts/archaeology-01.txt)" \
    output/archaeology-01.mp4
```

The first run will download the CogVideoX-2B model into the Hugging Face cache, normally under:

```text
~/.cache/huggingface/hub/
```

The model download is large, roughly in the low tens of gigabytes.

Subsequent runs should reuse the cached files.

## Monitoring GPU usage

In another terminal:

```bash
watch -n 1 nvidia-smi
```

Because the GPU has about 8 GB of VRAM, the pipeline deliberately uses sequential CPU offloading.

The relevant configuration in `generate.py` is:

```python
pipe.enable_sequential_cpu_offload()
pipe.vae.enable_slicing()
pipe.vae.enable_tiling()
```

This keeps most model weights in system RAM and transfers only the currently required components onto the GPU.

This is much slower than holding the complete model in VRAM, but it makes the model practical on an 8 GB card.

## Running arbitrary prompts

A direct prompt can be passed to `video.sh`:

```bash
./video.sh \
    "A silent abandoned orbital station drifting above a blue planet, slow cinematic camera movement, realistic lighting" \
    output/station.mp4
```

Prompts can also be stored as text files:

```text
prompts/
├── archaeology-01.txt
├── archaeology-02.txt
├── archaeology-03.txt
└── station.txt
```

Then:

```bash
./video.sh \
    "$(cat prompts/station.txt)" \
    output/station.mp4
```

This is preferable for complex prompts because they can be version controlled and edited independently of the generation command.

## Advanced generation controls

The Bash wrapper uses conservative defaults.

For more direct control, invoke `generate.py`:

```bash
python generate.py \
    "A strange mechanical landscape beneath a modern circuit board" \
    --steps 30 \
    --seed 123 \
    --fps 8 \
    --frames 49 \
    --width 720 \
    --height 480 \
    -o output/test.mp4
```

The most useful parameters are `--seed`, `--steps`, `--frames`, `--fps`, `--width`, and `--height`.

For early testing, keep inference steps relatively low:

```text
20 steps
```

Once a composition works, try:

```text
30–40 steps
```

Increasing inference steps usually costs substantially more time while giving diminishing returns.

## Seeds

A fixed seed allows approximately reproducible generations:

```bash
python generate.py \
    "$(cat prompts/archaeology-01.txt)" \
    --seed 42 \
    -o output/archaeology-seed42.mp4
```

Try variations with:

```text
42
43
44
100
1234
```

For exploratory work, changing the seed is usually more useful than rewriting the entire prompt after every imperfect result.

## Recommended workflow

Rather than asking one model to create a complete long film, treat local video generation as a shot renderer.

A practical structure is:

```text
storyboard
    ↓
one prompt per shot
    ↓
several seeds per shot
    ↓
select strongest result
    ↓
optional image-to-video refinement
    ↓
ffmpeg assembly
    ↓
sound and narration
    ↓
final film
```

For the technological archaeology sequence, for example:

```text
prompts/
├── 01-modern-skin.txt
├── 02-industrial-substrate.txt
├── 03-dawn-of-glass.txt
├── 04-electromechanical-depth.txt
├── 05-organic-machinery.txt
└── 06-neural-core.txt
```

The corresponding videos could be:

```text
output/
├── 01-modern-skin.mp4
├── 02-industrial-substrate.mp4
├── 03-dawn-of-glass.mp4
├── 04-electromechanical-depth.mp4
├── 05-organic-machinery.mp4
└── 06-neural-core.mp4
```

This is much easier to control than trying to generate a continuous thirty-second transformation in one pass.

## Combining generated shots with ffmpeg

Create a file named:

```text
shots.txt
```

containing:

```text
file 'output/01-modern-skin.mp4'
file 'output/02-industrial-substrate.mp4'
file 'output/03-dawn-of-glass.mp4'
```

Then concatenate:

```bash
ffmpeg \
    -f concat \
    -safe 0 \
    -i shots.txt \
    -c copy \
    output/sequence.mp4
```

If the generated clips have incompatible encoding parameters, re-encode:

```bash
ffmpeg \
    -f concat \
    -safe 0 \
    -i shots.txt \
    -c:v libx264 \
    -crf 18 \
    -pix_fmt yuv420p \
    output/sequence.mp4
```

## Inspecting generated video

Use:

```bash
ffprobe output/archaeology-01.mp4
```

or:

```bash
ffprobe -hide_banner output/archaeology-01.mp4
```

From WSL, open the project directory in Windows Explorer with:

```bash
explorer.exe .
```

## If `python` is not found

A correctly created virtual environment should normally provide:

```text
.venv/bin/python
```

Check:

```bash
ls -l .venv/bin/python*
```

If the virtual environment was moved, recreate it rather than patching aliases.

Using:

```bash
alias python=python3
```

works interactively but does not reliably solve commands executed inside shell scripts because Bash aliases are generally not expanded in non-interactive scripts.

Prefer either:

```bash
python
```

from a healthy activated venv, or explicitly:

```bash
.venv/bin/python
```

inside scripts.

## If `pip` points to the wrong directory

Check:

```bash
head -1 .venv/bin/pip
```

If it contains an old project path such as:

```text
#!/home/bonobo/video-gen/.venv/bin/python3
```

while the project is now located at:

```text
/home/bonobo/userland/video-gen
```

the virtual environment was moved.

Delete and recreate `.venv`.

## If the tokenizer crashes inside tiktoken

An error involving:

```text
load_tiktoken_bpe
```

and:

```text
spiece.model
```

usually indicates that Transformers failed to use the SentencePiece conversion path.

Install:

```bash
python -m pip install -U \
    protobuf \
    sentencepiece
```

Then test:

```bash
python - <<'PY'
from transformers import T5Tokenizer

tok = T5Tokenizer.from_pretrained(
    "zai-org/CogVideoX-2b",
    subfolder="tokenizer",
)

print("Tokenizer loaded successfully.")
PY
```

Do not immediately delete the Hugging Face model cache. A tiktoken traceback does not necessarily mean the model file itself is corrupt.

## If CUDA runs out of memory

Keep:

```python
pipe.enable_sequential_cpu_offload()
pipe.vae.enable_slicing()
pipe.vae.enable_tiling()
```

Then reduce the workload.

Try fewer frames:

```bash
--frames 33
```

or a smaller resolution.

Avoid increasing frame count, resolution, and inference steps simultaneously.

Also inspect GPU memory with:

```bash
watch -n 1 nvidia-smi
```

## System RAM

Sequential CPU offloading reduces VRAM pressure by placing much of the model in ordinary system RAM.

This means system RAM becomes important.

Check:

```bash
free -h
```

If RAM fills completely and the system begins heavily swapping, generation may become extremely slow.

## Hugging Face cache

Downloaded model files normally live under:

```text
~/.cache/huggingface/hub/
```

CogVideoX files will resemble:

```text
models--zai-org--CogVideoX-2b/
```

Do not delete this directory between runs unless troubleshooting a genuinely corrupted download.

## Next step: image-to-video

Text-to-video is useful for experimentation, but image-to-video will probably be more valuable for controlled filmmaking.

The intended workflow is:

```text
designed storyboard frame
        ↓
image-to-video model
        ↓
controlled camera or object movement
        ↓
short shot
```

This allows the visual composition to be established first and animation added afterward.

For the technological archaeology film, this should give much stronger continuity than independently generating every shot from text.

The next extension to this project should therefore be:

```text
image-video.sh
```

with usage approximately:

```bash
./image-video.sh \
    reference.png \
    "Slow macro camera movement as the electronic surface separates to expose brass relays beneath." \
    output/animated-reference.mp4
```

## Further extensions

Once the basic CogVideoX pipeline is stable, useful additions include image-to-video generation, interpolation between generated clips, automatic seed sweeps, LoRA support, prompt metadata stored beside each generated video, automatic contact sheets, upscaling, frame interpolation, audio generation, narration, and a `render.sh` script for assembling a complete storyboard.

A later project layout could become:

```text
video-gen/
├── models/
├── prompts/
├── references/
├── shots/
├── output/
├── metadata/
├── generate.py
├── image-video.py
├── video.sh
├── image-video.sh
├── render.sh
└── README.md
```

The goal is not to reproduce a cloud service such as Sora as a single monolithic model. The more useful local approach is a programmable filmmaking pipeline where image generation, video diffusion, interpolation, compositing, audio, and `ffmpeg` remain separate pieces that can be inspected, replaced, automated, and version controlled.

