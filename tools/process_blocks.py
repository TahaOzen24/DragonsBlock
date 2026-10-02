import os
import colorsys
from PIL import Image, ImageFilter

brain_dir = r"C:\Users\tahaozen\.gemini\antigravity-ide\brain\972429d6-f651-4256-8abc-da9dfbda8aa4"
output_dir = r"c:\Users\tahaozen\Desktop\son\assets\images\blocks"

# Source files
blue_src = os.path.join(brain_dir, "gem_blue_sapphire_1789709000619.jpg")
red_src = os.path.join(brain_dir, "gem_red_ruby_1789709023822.jpg")
green_src = os.path.join(brain_dir, "gem_green_emerald_1789709044817.jpg")

def make_transparent_and_clean(img, black_thresh=12, feather=18):
    """
    Remove solid black background cleanly with smooth alpha feathering.
    """
    img = img.convert("RGBA")
    datas = img.getdata()
    new_data = []
    
    for item in datas:
        r, g, b, a = item
        # Max brightness of the background pixel
        brightness = max(r, g, b)
        if brightness <= black_thresh:
            new_data.append((0, 0, 0, 0))
        elif brightness < black_thresh + feather:
            alpha = int(255 * (brightness - black_thresh) / feather)
            new_data.append((r, g, b, alpha))
        else:
            new_data.append((r, g, b, 255))
            
    img.putdata(new_data)
    return img

def shift_hue(img, hue_delta):
    """
    Shift the hue of an RGBA image by hue_delta (-1.0 to 1.0) while preserving highlights/saturation.
    """
    img = img.convert("RGBA")
    datas = img.getdata()
    new_data = []
    
    for r, g, b, a in datas:
        if a == 0:
            new_data.append((0, 0, 0, 0))
            continue
        rf, gf, bf = r / 255.0, g / 255.0, b / 255.0
        h, s, v = colorsys.rgb_to_hsv(rf, gf, bf)
        h = (h + hue_delta) % 1.0
        nr, ng, nb = colorsys.hsv_to_rgb(h, s, v)
        new_data.append((int(nr * 255), int(ng * 255), int(nb * 255), a))
        
    img.putdata(new_data)
    return img

print("Processing blocks...")
os.makedirs(output_dir, exist_ok=True)

# 1. Blue Sapphire
img_blue = Image.open(blue_src)
img_blue_trans = make_transparent_and_clean(img_blue)
img_blue_trans = img_blue_trans.resize((256, 256), Image.Resampling.LANCZOS)
img_blue_trans.save(os.path.join(output_dir, "gem_blue.png"))
print("Saved gem_blue.png")

# 2. Red Ruby
img_red = Image.open(red_src)
img_red_trans = make_transparent_and_clean(img_red)
img_red_trans = img_red_trans.resize((256, 256), Image.Resampling.LANCZOS)
img_red_trans.save(os.path.join(output_dir, "gem_red.png"))
print("Saved gem_red.png")

# 3. Green Emerald
img_green = Image.open(green_src)
img_green_trans = make_transparent_and_clean(img_green)
img_green_trans = img_green_trans.resize((256, 256), Image.Resampling.LANCZOS)
img_green_trans.save(os.path.join(output_dir, "gem_green.png"))
print("Saved gem_green.png")

# 4. Cyan Diamond (derived from Blue Sapphire, hue shifted towards cyan ~ -0.10)
img_cyan = shift_hue(img_blue_trans, -0.11)
img_cyan.save(os.path.join(output_dir, "gem_cyan.png"))
print("Saved gem_cyan.png")

# 5. Royal Amethyst Violet (derived from Blue Sapphire, hue shifted towards purple/magenta ~ +0.15)
img_purple = shift_hue(img_blue_trans, 0.16)
img_purple.save(os.path.join(output_dir, "gem_purple.png"))
print("Saved gem_purple.png")

# 6. Radiant Orange (derived from Red Ruby, hue shifted towards orange ~ +0.06)
img_orange = shift_hue(img_red_trans, 0.07)
img_orange.save(os.path.join(output_dir, "gem_orange.png"))
print("Saved gem_orange.png")

# 7. Amber Gold / Topaz (derived from Red Ruby, hue shifted towards yellow ~ +0.13)
img_yellow = shift_hue(img_red_trans, 0.14)
img_yellow.save(os.path.join(output_dir, "gem_yellow.png"))
print("Saved gem_yellow.png")

print("All 7 gems successfully processed!")
