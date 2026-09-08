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
