import numpy as np
from scipy.io import wavfile
from PIL import Image, ImageDraw
import os

# Common parameters for sounds
sample_rate = 44100  # Standard audio sample rate (Hz)

def generate_pop_sound():
    """Generate a short bubble pop sound as WAV."""
    duration = 0.1
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    freq = 2000
    audio = np.sin(2 * np.pi * freq * t)
    envelope = np.exp(-10 * t / duration)
    audio = audio * envelope
    audio = (audio * 32767).astype(np.int16)
    wavfile.write("assets/sounds/pop.wav", sample_rate, audio)

def generate_background_music():
    """Generate ambient space background music as WAV."""
    duration = 10.0
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    freqs = [100, 150, 200]
    audio = np.zeros_like(t)
    for freq in freqs:
        audio += np.sin(2 * np.pi * freq * t) / len(freqs)
    noise = np.random.normal(0, 0.1, len(t))
    audio = audio * 0.8 + noise * 0.2
    fade_samples = int(sample_rate * 0.5)
    fade_in = np.linspace(0, 1, fade_samples)
    fade_out = np.linspace(1, 0, fade_samples)
    envelope = np.ones_like(t)
    envelope[:fade_samples] = fade_in
    envelope[-fade_samples:] = fade_out
    audio = audio * envelope
    audio = (audio * 32767).astype(np.int16)
    wavfile.write("assets/sounds/background.wav", sample_rate, audio)

def generate_level_complete_sound():
    """Generate celebratory sound as WAV."""
    duration = 1.0
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    freqs = [440, 523.25, 659.25]
    audio = np.zeros_like(t)
    segment_duration = duration / len(freqs)
    for i, freq in enumerate(freqs):
        start = int(i * sample_rate * segment_duration)
        end = int((i + 1) * sample_rate * segment_duration)
        segment_t = t[start:end] - (i * segment_duration)
        audio[start:end] += np.sin(2 * np.pi * freq * segment_t)
    envelope = np.exp(-3 * t / duration)
    audio = audio * envelope
    audio = (audio * 32767).astype(np.int16)
    wavfile.write("assets/sounds/level_complete.wav", sample_rate, audio)

def generate_error_sound():
    """Generate error buzz as WAV."""
    duration = 0.3
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    freq1, freq2 = 300, 320
    audio = 0.5 * np.sin(2 * np.pi * freq1 * t) + 0.5 * np.sin(2 * np.pi * freq2 * t)
    noise = np.random.normal(0, 0.2, len(t))
    audio = audio * 0.8 + noise * 0.2
    envelope = np.exp(-15 * t / duration)
    audio = audio * envelope
    audio = (audio * 32767).astype(np.int16)
    wavfile.write("assets/sounds/error.wav", sample_rate, audio)

def generate_star_texture():
    """Generate a star.png with a white star on a transparent background."""
    size = (64, 64)
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.ellipse((16, 16, 48, 48), fill=(255, 255, 255, 255))
    image.save("assets/textures/star.png", "PNG")

def generate_planet_texture():
    """Generate a planet.jpg with a blue-green gradient."""
    size = (128, 128)
    image = Image.new("RGB", size, (0, 0, 0))
    draw = ImageDraw.Draw(image)
    for y in range(size[1]):
        for x in range(size[0]):
            distance = ((x - size[0]/2)**2 + (y - size[1]/2)**2)**0.5
            if distance < size[0]/2:
                blue = int(50 + 100 * (1 - distance / (size[0]/2)))
                green = int(100 + 100 * (1 - distance / (size[0]/2)))
                image.putpixel((x, y), (0, green, blue))
    image.save("assets/textures/planet.jpg", "JPEG", quality=95)

def generate_bubble_texture():
    """Generate a bubble.png with a semi-transparent blue circle."""
    size = (64, 64)
    image = Image.new("RGBA", size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.ellipse((8, 8, 56, 56), fill=(100, 149, 237, 128))
    image.save("assets/textures/bubble.png", "PNG")

if __name__ == "__main__":
    os.makedirs("assets/sounds", exist_ok=True)
    os.makedirs("assets/textures", exist_ok=True)
    generate_pop_sound()
    generate_background_music()
    generate_level_complete_sound()
    generate_error_sound()
    generate_star_texture()
    generate_planet_texture()
    generate_bubble_texture()
    print("Generated all assets in assets/sounds/ and assets/textures/")
