import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance, ImageChops

def create_rich_gradient(w, h, stops):
    img = Image.new("RGBA", (w, h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        c1 = stops[0]
        c2 = stops[-1]
        for i in range(len(stops) - 1):
            if stops[i][0] <= t <= stops[i+1][0]:
                c1 = stops[i]
                c2 = stops[i+1]
                break
        seg_t = 0.0 if c2[0] == c1[0] else (t - c1[0]) / (c2[0] - c1[0])
        r = int(c1[1][0] * (1 - seg_t) + c2[1][0] * seg_t)
        g = int(c1[1][1] * (1 - seg_t) + c2[1][1] * seg_t)
        b = int(c1[1][2] * (1 - seg_t) + c2[1][2] * seg_t)
        a = int(c1[1][3] * (1 - seg_t) + c2[1][3] * seg_t)
        draw.line([(0, y), (w, y)], fill=(r, g, b, a))
    return img

def draw_sparkle(img, cx, cy, radius, color=(255, 255, 255, 255)):
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    for r in range(radius, 0, -2):
        alpha = int(color[3] * (1 - r / radius) * 0.5)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(color[0], color[1], color[2], alpha))
    
    pts_v = [(cx, cy - radius * 2.2), (cx + radius * 0.2, cy), (cx, cy + radius * 2.2), (cx - radius * 0.2, cy)]
    pts_h = [(cx - radius * 2.2, cy), (cx, cy - radius * 0.2), (cx + radius * 2.2, cy), (cx, cy + radius * 0.2)]
    draw.polygon(pts_v, fill=color)
    draw.polygon(pts_h, fill=color)
    
    # Diagonal sparkles
    rd = int(radius * 0.75)
    draw.line([(cx - rd, cy - rd), (cx + rd, cy + rd)], fill=color, width=2)
    draw.line([(cx - rd, cy + rd), (cx + rd, cy - rd)], fill=color, width=2)
    
    draw.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=(255, 255, 255, 255))
    return Image.alpha_composite(img, overlay)

def render_dynamic_title_word(
    text,
    font,
    gradient_stops,
    depth=28,
    stroke_dark=(22, 8, 2, 255),
    stroke_dark_w=18,
    stroke_gold=(255, 240, 140, 255),
    stroke_gold_w=8,
    letter_spacing=10,
    arch_power=0.00016
):
    dummy = Image.new("RGBA", (1, 1))
    ddraw = ImageDraw.Draw(dummy)
    
    char_bboxes = []
    char_widths = []
    total_w = 0
    max_h = 0
    
    for ch in text:
        bb = ddraw.textbbox((0, 0), ch, font=font, stroke_width=stroke_dark_w)
        w = (bb[2] - bb[0]) + letter_spacing
        h = bb[3] - bb[1]
        char_widths.append(w)
        char_bboxes.append(bb)
        total_w += w
        if h > max_h:
            max_h = h
            
    margin = stroke_dark_w * 4 + 50
    arch_max_lift = 35
    img_w = total_w + margin * 2
    img_h = max_h + margin * 2 + depth + arch_max_lift + 30
    
    positions = []
    cur_x = margin
    center_x = margin + total_w / 2
    
    for i, ch in enumerate(text):
        char_cx = cur_x + char_widths[i] / 2
        dist_from_center = char_cx - center_x
        arch_y = (dist_from_center ** 2) * arch_power
        
        bb = char_bboxes[i]
        x_pos = cur_x - bb[0]
        y_pos = margin - bb[1] + arch_y + 15
        positions.append((x_pos, y_pos))
        cur_x += char_widths[i]

    # Layer 1: Massive Deep 3D Extrusion
    ext_layer = Image.new("RGBA", (img_w, img_h), (0, 0, 0, 0))
    edraw = ImageDraw.Draw(ext_layer)
    
    for d in range(depth, 0, -1):
        ratio = d / depth
        sr = int(gradient_stops[-1][1][0] * 0.65 * (1 - ratio * 0.7))
        sg = int(gradient_stops[-1][1][1] * 0.65 * (1 - ratio * 0.7))
        sb = int(gradient_stops[-1][1][2] * 0.65 * (1 - ratio * 0.7))
        
        for i, ch in enumerate(text):
            xp, yp = positions[i]
            edraw.text(
                (xp, yp + d), ch, font=font,
                fill=(sr, sg, sb, 255),
                stroke_width=stroke_dark_w,
                stroke_fill=stroke_dark
            )

    # Layer 2: Gold/Cyan inner rim
    rim_layer = Image.new("RGBA", (img_w, img_h), (0, 0, 0, 0))
    rdraw = ImageDraw.Draw(rim_layer)
    for i, ch in enumerate(text):
        xp, yp = positions[i]
        rdraw.text(
            (xp, yp), ch, font=font,
            fill=(0, 0, 0, 0),
            stroke_width=stroke_dark_w + stroke_gold_w,
            stroke_fill=stroke_gold
        )
    
    # Layer 3: Dark outer stroke
    dark_stroke_layer = Image.new("RGBA", (img_w, img_h), (0, 0, 0, 0))
    dsdraw = ImageDraw.Draw(dark_stroke_layer)
    for i, ch in enumerate(text):
        xp, yp = positions[i]
        dsdraw.text(
            (xp, yp), ch, font=font,
            fill=(0, 0, 0, 0),
            stroke_width=stroke_dark_w,
            stroke_fill=stroke_dark
        )
        
    # Layer 4: Front face gradient
    face_mask = Image.new("L", (img_w, img_h), 0)
    fdraw = ImageDraw.Draw(face_mask)
    for i, ch in enumerate(text):
        xp, yp = positions[i]
        fdraw.text((xp, yp), ch, font=font, fill=255)
        
    grad_surf = create_rich_gradient(img_w, img_h, gradient_stops)
    
    # Gloss highlight on top half of letters
    gloss = Image.new("RGBA", (img_w, img_h), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(gloss)
    text_top = int(margin)
    gloss_h = int(max_h * 0.45)
    for y in range(text_top, text_top + gloss_h + 30):
        t = (y - text_top) / max(1, gloss_h + 30)
        alpha = int((1.0 - t * 0.85) * 210)
        gdraw.line([(0, y), (img_w, y)], fill=(255, 255, 255, alpha))
    grad_surf = Image.alpha_composite(grad_surf, gloss)
    
    front_face = Image.new("RGBA", (img_w, img_h), (0, 0, 0, 0))
    front_face.paste(grad_surf, (0, 0), face_mask)
    
    # Composite layers
    res = Image.alpha_composite(ext_layer, rim_layer)
    res = Image.alpha_composite(res, dark_stroke_layer)
    res = Image.alpha_composite(res, front_face)
    
    bbox = res.getbbox()
    if bbox:
        res = res.crop((bbox[0] - 10, bbox[1] - 10, bbox[2] + 10, bbox[3] + 10))
    return res

def generate_perfect_logo():
    src_path = "assets/images/dragons_block_logo.png"
    # Backup original if not already backed up
    backup_path = "assets/images/dragons_block_logo_original.png"
    if not os.path.exists(backup_path):
        import shutil
        shutil.copyfile(src_path, backup_path)
        print("Backed up original logo to", backup_path)
        
    orig = Image.open(backup_path).convert("RGBA")
    
    cw = 1200
    ch = 1260
    canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    
    # Cube sizing & position
    cube_w = 970
    cube_h = int(orig.height * (cube_w / orig.width))
    cube_resized = orig.resize((cube_w, cube_h), Image.Resampling.LANCZOS)
    
    cube_x = (cw - cube_w) // 2
    cube_y = 12
    
    # Radiant warm & cool magical aura behind cube
    glow = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    gdraw.ellipse([cube_x + 360, cube_y + 80, cube_x + 940, cube_y + 640], fill=(255, 215, 0, 60))
    gdraw.ellipse([cube_x + 60, cube_y + 240, cube_x + 600, cube_y + 780], fill=(56, 189, 248, 55))
    glow = glow.filter(ImageFilter.GaussianBlur(70))
    canvas = Image.alpha_composite(canvas, glow)
    
    # Paste cube
    canvas.paste(cube_resized, (cube_x, cube_y), cube_resized)
    
    font_path = "C:/Windows/Fonts/impact.ttf"
    font_dragons = ImageFont.truetype(font_path, 178)
    font_block = ImageFont.truetype(font_path, 172)
    
    # Stops for "DRAGONS" (Epic Chiseled Gold)
    gold_stops = [
        (0.00, (255, 255, 255, 255)),
        (0.12, (255, 252, 195, 255)),
        (0.35, (254, 220, 50, 255)),
        (0.65, (245, 158, 11, 255)),
        (0.88, (180, 83, 9, 255)),
        (1.00, (105, 35, 4, 255)),
    ]
    
    # Stops for "BLOCK" (Electric Cyan & Diamond Blue)
    cyan_stops = [
        (0.00, (255, 255, 255, 255)),
        (0.14, (224, 242, 254, 255)),
        (0.35, (56, 189, 248, 255)),
        (0.65, (2, 132, 199, 255)),
        (0.88, (30, 64, 175, 255)),
        (1.00, (15, 23, 42, 255)),
    ]
    
    # Render words
    title_dragons = render_dynamic_title_word(
        "DRAGONS",
        font_dragons,
        gold_stops,
        depth=28,
        stroke_dark=(22, 8, 2, 255),
        stroke_dark_w=18,
        stroke_gold=(255, 240, 140, 255),
        stroke_gold_w=8,
        letter_spacing=10,
        arch_power=0.00015
    )
    
    title_block = render_dynamic_title_word(
        "BLOCK",
        font_block,
        cyan_stops,
        depth=25,
        stroke_dark=(4, 14, 32, 255),
        stroke_dark_w=18,
        stroke_gold=(186, 230, 253, 255),
        stroke_gold_w=8,
        letter_spacing=18,
        arch_power=0.00012
    )
    
    dx = (cw - title_dragons.width) // 2
    dy = 750
    
    bx = (cw - title_block.width) // 2
    by = dy + int(title_dragons.height * 0.65) # tighter interlock!
    
    # Ambient & drop shadows under text
    shadow_layer = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    d_mask = title_dragons.split()[3]
    b_mask = title_block.split()[3]
    
    black_d = Image.new("RGBA", title_dragons.size, (0, 0, 0, 250))
    shadow_layer.paste(black_d, (dx, dy + 20), d_mask)
    
    black_b = Image.new("RGBA", title_block.size, (0, 0, 0, 250))
    shadow_layer.paste(black_b, (bx, by + 20), b_mask)
    
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(18))
    canvas = Image.alpha_composite(canvas, shadow_layer)
    
    # Paste words
    canvas.paste(title_dragons, (dx, dy), title_dragons)
    canvas.paste(title_block, (bx, by), title_block)
    
    # Sparkles
    canvas = draw_sparkle(canvas, dx + 78, dy + 52, 20, (255, 255, 230, 255))
    canvas = draw_sparkle(canvas, dx + int(title_dragons.width * 0.52), dy + 42, 16, (255, 255, 255, 255))
    canvas = draw_sparkle(canvas, dx + title_dragons.width - 72, dy + 56, 20, (255, 255, 200, 255))
    
    canvas = draw_sparkle(canvas, bx + 70, by + 48, 18, (224, 242, 254, 255))
    canvas = draw_sparkle(canvas, bx + int(title_block.width * 0.5), by + 42, 17, (255, 255, 255, 255))
    canvas = draw_sparkle(canvas, bx + title_block.width - 65, by + 52, 19, (224, 242, 254, 255))
    
    canvas = draw_sparkle(canvas, cube_x + 550, cube_y + 245, 14, (255, 255, 255, 255))
    canvas = draw_sparkle(canvas, cube_x + 480, cube_y + 510, 15, (255, 255, 220, 255))
    
    # Crop to content with comfortable padding
    bbox = canvas.getbbox()
    final_canvas = canvas.crop((bbox[0] - 15, bbox[1] - 15, bbox[2] + 15, bbox[3] + 15))
    
    # Save as both dragons_block_logo_new.png and OVERWRITE dragons_block_logo.png
    out_new = "assets/images/dragons_block_logo_new.png"
    out_main = "assets/images/dragons_block_logo.png"
    final_canvas.save(out_new, "PNG", optimize=True)
    final_canvas.save(out_main, "PNG", optimize=True)
    print(f"Master logo saved to {out_main} and {out_new} with size {final_canvas.size}")

if __name__ == "__main__":
    generate_perfect_logo()
