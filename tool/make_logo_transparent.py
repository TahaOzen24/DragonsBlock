from PIL import Image

path = r'c:\Users\tahaozen\Desktop\DragonsBlock\assets\images\dragons_block_logo.png'
# Re-copy from generated source if needed, then process original RGB once more
src = r'C:\Users\tahaozen\.cursor\projects\c-Users-tahaozen-Desktop-DragonsBlock\assets\dragons_block_logo_clear.png'
im = Image.open(src).convert('RGBA')
pixels = im.load()
w, h = im.size

# Pass 1: kill light background
for y in range(h):
    for x in range(w):
        r, g, b, a = pixels[x, y]
        avg = (r + g + b) / 3.0
        mx, mn = max(r, g, b), min(r, g, b)
        if avg >= 205 and (mx - mn) < 40:
            pixels[x, y] = (r, g, b, 0)
        elif avg >= 185 and (mx - mn) < 30:
            t = (avg - 185) / 20.0
            pixels[x, y] = (r, g, b, int(255 * max(0.0, 1.0 - t)))

# Pass 2: remove white fringe next to transparent pixels
fringe_removed = 0
for y in range(1, h - 1):
    for x in range(1, w - 1):
        r, g, b, a = pixels[x, y]
        if a == 0:
            continue
        avg = (r + g + b) / 3.0
        # bright desaturated edge near transparency
        neighbors = [
            pixels[x - 1, y][3], pixels[x + 1, y][3],
            pixels[x, y - 1][3], pixels[x, y + 1][3],
        ]
        near_clear = any(n < 20 for n in neighbors)
        if near_clear and avg > 170 and (max(r, g, b) - min(r, g, b)) < 45:
            pixels[x, y] = (r, g, b, 0)
            fringe_removed += 1
        elif near_clear and avg > 150 and (max(r, g, b) - min(r, g, b)) < 35:
            pixels[x, y] = (r, g, b, max(0, a // 3))

im.save(path, 'PNG')
print('corner', im.getpixel((5, 5)))
print('fringe_removed', fringe_removed)
print('ok', path)
