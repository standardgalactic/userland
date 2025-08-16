from PIL import Image, ImageDraw
import os

def generate_star_texture():
    """Generate a star.png with a white star on a transparent background."""
    size = (64, 64)  # Small size for point sprites
    image = Image.new("RGBA", size, (0, 0, 0, 0))  # Transparent background
    draw = ImageDraw.Draw(image)
    # Draw a white star (simple circle for prototype)
    draw.ellipse((16, 16, 48, 48), fill=(255, 255, 255, 255))
    image.save("assets/textures/star.png", "PNG")

def generate_planet_texture():
    """Generate a planet.jpg with a blue-green gradient."""
    size = (128, 128)  # Suitable for sphere texture
    image = Image.new("RGB", size, (0, 0, 0))
    draw = ImageDraw.Draw(image)
    # Gradient effect: blue to green
    for y in range(size[1]):
        for x in range(size[0]):
            distance = ((x - size[0]/2)**2 + (y - size[1]/2)**2)**0.5
            if distance < size[0]/2:
                # Blue-green gradient based on distance
                blue = int(50 + 100 * (1 - distance / (size[0]/2)))
                green = int(100 + 100 * (1 - distance / (size[0]/2)))
                image.putpixel((x, y), (0, green, blue))
    image.save("assets/textures/planet.jpg", "JPEG", quality=95)

def generate_bubble_texture():
    """Generate a bubble.png with a semi-transparent blue circle."""
    size = (64, 64)
    image = Image.new("RGBA", size, (0, 0, 0, 0))  # Transparent background
    draw = ImageDraw.Draw(image)
    # Semi-transparent blue circle
    draw.ellipse((8, 8, 56, 56), fill=(100, 149, 237, 128))  # Cornflower blue, 50% opacity
    image.save("assets/textures/bubble.png", "PNG")

if __name__ == "__main__":
    # Create output directory
    os.makedirs("assets/textures", exist_ok=True)
    # Generate textures
    generate_star_texture()
    generate_planet_texture()
    generate_bubble_texture()
    print("Generated star.png, planet.jpg, and bubble.png in assets/textures/")
