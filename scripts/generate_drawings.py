import os
import math
import struct
import zlib

class Canvas:
    def __init__(self, w=512, h=512):
        self.w = w
        self.h = h
        # RGBA buffer: initialized to fully transparent (0, 0, 0, 0)
        self.buffer = bytearray(w * h * 4)

    def set_pixel(self, x, y, r, g, b, a):
        if 0 <= x < self.w and 0 <= y < self.h:
            idx = (y * self.w + x) * 4
            # Alpha blend if already has color
            cur_a = self.buffer[idx + 3]
            if cur_a == 0:
                self.buffer[idx] = r
                self.buffer[idx + 1] = g
                self.buffer[idx + 2] = b
                self.buffer[idx + 3] = a
            else:
                alpha = a / 255.0
                inv_a = 1.0 - alpha
                self.buffer[idx] = int(r * alpha + self.buffer[idx] * inv_a)
                self.buffer[idx + 1] = int(g * alpha + self.buffer[idx + 1] * inv_a)
                self.buffer[idx + 2] = int(b * alpha + self.buffer[idx + 2] * inv_a)
                self.buffer[idx + 3] = min(255, int(cur_a + a * (1 - cur_a / 255.0)))

    def draw_thick_pixel(self, cx, cy, rad, r=25, g=25, b=30, a=255):
        irad = int(math.ceil(rad))
        for dy in range(-irad, irad + 1):
            for dx in range(-irad, irad + 1):
                dist = math.hypot(dx, dy)
                if dist <= rad:
                    falloff = max(0.0, min(1.0, rad + 0.5 - dist))
                    alpha = int(a * falloff)
                    if alpha > 0:
                        self.set_pixel(cx + dx, cy + dy, r, g, b, alpha)

    def draw_line(self, x0, y0, x1, y1, width=3.0, color=(25, 25, 30, 255)):
        dist = math.hypot(x1 - x0, y1 - y0)
        steps = max(1, int(dist * 2))
        rad = width / 2.0
        for i in range(steps + 1):
            t = i / steps
            x = int(round(x0 + t * (x1 - x0)))
            y = int(round(y0 + t * (y1 - y0)))
            self.draw_thick_pixel(x, y, rad, color[0], color[1], color[2], color[3])

    def draw_polyline(self, points, width=3.0, closed=False, color=(25, 25, 30, 255)):
        for i in range(len(points) - 1):
            self.draw_line(points[i][0], points[i][1], points[i+1][0], points[i+1][1], width, color)
        if closed and len(points) > 2:
            self.draw_line(points[-1][0], points[-1][1], points[0][0], points[0][1], width, color)

    def draw_circle(self, cx, cy, radius, width=3.0, color=(25, 25, 30, 255)):
        steps = max(36, int(radius * 4))
        pts = []
        for i in range(steps):
            th = 2 * math.pi * i / steps
            pts.append((cx + radius * math.cos(th), cy + radius * math.sin(th)))
        self.draw_polyline(pts, width=width, closed=True, color=color)

    def draw_arc(self, cx, cy, radius, start_deg, end_deg, width=3.0, color=(25, 25, 30, 255)):
        steps = max(12, int(abs(end_deg - start_deg) * radius / 60))
        pts = []
        s_rad = math.radians(start_deg)
        e_rad = math.radians(end_deg)
        for i in range(steps + 1):
            th = s_rad + (e_rad - s_rad) * (i / steps)
            pts.append((cx + radius * math.cos(th), cy + radius * math.sin(th)))
        self.draw_polyline(pts, width=width, closed=False, color=color)

    def draw_ellipse(self, cx, cy, rx, ry, width=3.0, rotation=0, color=(25, 25, 30, 255)):
        steps = max(36, int(max(rx, ry) * 3))
        pts = []
        rot = math.radians(rotation)
        cos_r = math.cos(rot)
        sin_r = math.sin(rot)
        for i in range(steps):
            th = 2 * math.pi * i / steps
            lx = rx * math.cos(th)
            ly = ry * math.sin(th)
            gx = cx + (lx * cos_r - ly * sin_r)
            gy = cy + (lx * sin_r + ly * cos_r)
            pts.append((gx, gy))
        self.draw_polyline(pts, width=width, closed=True, color=color)

    def draw_bezier(self, p0, p1, p2, p3=None, steps=40, width=3.0, color=(25, 25, 30, 255)):
        pts = []
        for i in range(steps + 1):
            t = i / steps
            inv_t = 1.0 - t
            if p3 is None:
                # Quadratic bezier
                x = inv_t*inv_t * p0[0] + 2*inv_t*t * p1[0] + t*t * p2[0]
                y = inv_t*inv_t * p0[1] + 2*inv_t*t * p1[1] + t*t * p2[1]
            else:
                # Cubic bezier
                x = inv_t**3 * p0[0] + 3*inv_t**2 * t * p1[0] + 3*inv_t * t**2 * p2[0] + t**3 * p3[0]
                y = inv_t**3 * p0[1] + 3*inv_t**2 * t * p1[1] + 3*inv_t * t**2 * p2[1] + t**3 * p3[1]
            pts.append((x, y))
        self.draw_polyline(pts, width=width, closed=False, color=color)

    def save_png(self, filepath):
        raw_data = bytearray()
        stride = self.w * 4
        for y in range(self.h):
            raw_data.append(0) # Filter byte 0 (None)
            row_start = y * stride
            raw_data.extend(self.buffer[row_start : row_start + stride])

        compressed = zlib.compress(raw_data, level=6)

        def chunk(ctype, data):
            crc = zlib.crc32(ctype + data) & 0xffffffff
            return struct.pack('>I', len(data)) + ctype + data + struct.pack('>I', crc)

        png = bytearray()
        png.extend(b'\x89PNG\r\n\x1a\n') # PNG signature
        # IHDR
        ihdr_data = struct.pack('>IIBBBBB', self.w, self.h, 8, 6, 0, 0, 0)
        png.extend(chunk(b'IHDR', ihdr_data))
        # IDAT
        png.extend(chunk(b'IDAT', compressed))
        # IEND
        png.extend(chunk(b'IEND', b''))

        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'wb') as f:
            f.write(png)

# Generator functions for each drawing
def gen_anime_boy(c):
    # Head contour
    c.draw_bezier((160, 200), (160, 340), (230, 420), (256, 440), width=3.5)
    c.draw_bezier((352, 200), (352, 340), (282, 420), (256, 440), width=3.5)
    # Ears
    c.draw_arc(155, 280, 25, 90, 270, width=3.0)
    c.draw_arc(357, 280, 25, -90, 90, width=3.0)
    # Anime Hair spikes
    c.draw_polyline([(130, 220), (110, 160), (170, 140), (160, 80), (220, 100), (256, 50), (292, 100), (352, 80), (342, 140), (402, 160), (382, 220)], width=4.0)
    # Bangs
    c.draw_polyline([(140, 190), (190, 260), (210, 210), (256, 280), (300, 210), (320, 260), (370, 190)], width=3.5)
    # Eyes
    c.draw_bezier((180, 270), (205, 255), (235, 270), width=4.5)
    c.draw_ellipse(207, 285, 14, 18, width=3.0)
    c.draw_circle(204, 280, 5, width=2.0)
    c.draw_bezier((277, 270), (307, 255), (332, 270), width=4.5)
    c.draw_ellipse(305, 285, 14, 18, width=3.0)
    c.draw_circle(302, 280, 5, width=2.0)
    # Eyebrows
    c.draw_line(180, 250, 230, 245, width=3.5)
    c.draw_line(282, 245, 332, 250, width=3.5)
    # Nose & mouth
    c.draw_line(254, 325, 250, 335, width=3.0)
    c.draw_bezier((235, 370), (256, 385), (277, 370), width=3.5)
    # Neck & Collar
    c.draw_line(205, 415, 190, 480, width=3.5)
    c.draw_line(307, 415, 322, 480, width=3.5)
    c.draw_polyline([(190, 480), (256, 450), (322, 480)], width=3.0)

def gen_anime_girl_eye(c):
    # Dramatic anime eye
    # Top thick curved eyelid with eyelash points
    c.draw_bezier((90, 250), (230, 140), (410, 220), width=8.0)
    c.draw_polyline([(390, 210), (440, 180), (405, 235)], width=5.0)
    c.draw_polyline([(280, 160), (300, 130), (310, 170)], width=4.0)
    c.draw_polyline([(170, 180), (160, 150), (195, 185)], width=4.0)
    # Bottom subtle eyelid
    c.draw_bezier((150, 350), (260, 390), (370, 330), width=5.0)
    c.draw_line(350, 345, 375, 365, width=3.0)
    # Large Iris
    c.draw_ellipse(260, 270, 85, 100, width=4.5)
    # Huge anime highlights
    c.draw_circle(230, 230, 30, width=3.0)
    c.draw_circle(300, 310, 18, width=2.5)
    c.draw_circle(235, 325, 12, width=2.5)
    # Pupil inside
    c.draw_ellipse(265, 280, 38, 48, width=4.0)
    # Upper crease
    c.draw_bezier((140, 190), (240, 140), (360, 180), width=3.5)
    # Eyebrow
    c.draw_bezier((80, 120), (240, 70), (420, 120), width=6.0)

def gen_cartoon_dragon(c):
    # Head
    c.draw_circle(240, 180, 70, width=4.0)
    # Snout
    c.draw_bezier((180, 180), (120, 190), (130, 240), (200, 240), width=4.0)
    c.draw_circle(150, 210, 6, width=3.0) # Nostril
    # Horns
    c.draw_bezier((260, 120), (300, 70), (340, 90), width=4.5)
    c.draw_bezier((280, 135), (320, 90), (340, 90), width=3.0)
    # Cute large eye
    c.draw_circle(220, 165, 22, width=3.5)
    c.draw_circle(215, 160, 8, width=2.5)
    # Dragon body
    c.draw_bezier((250, 250), (340, 290), (320, 420), (260, 440), width=4.0)
    c.draw_bezier((200, 240), (170, 340), (190, 420), (260, 440), width=4.0)
    # Belly plates
    c.draw_bezier((195, 300), (230, 320), (265, 300), width=3.0)
    c.draw_bezier((190, 350), (230, 370), (275, 350), width=3.0)
    c.draw_bezier((200, 400), (240, 415), (280, 395), width=3.0)
    # Back spikes
    c.draw_polyline([(300, 190), (330, 195), (310, 220)], width=3.5)
    c.draw_polyline([(320, 250), (350, 260), (325, 285)], width=3.5)
    c.draw_polyline([(325, 320), (360, 335), (320, 360)], width=3.5)
    # Tail
    c.draw_bezier((260, 440), (360, 470), (430, 420), (440, 360), width=4.0)
    c.draw_bezier((440, 360), (410, 380), (340, 420), (280, 420), width=3.0)
    # Tail spade
    c.draw_polyline([(440, 360), (470, 350), (450, 380), (440, 360)], width=3.5)
    # Wings
    c.draw_bezier((260, 240), (330, 160), (400, 170), width=3.5)
    c.draw_polyline([(400, 170), (370, 210), (360, 210), (330, 245), (280, 260)], width=3.0)

def gen_cartoon_puppy(c):
    # Head
    c.draw_circle(256, 200, 95, width=4.0)
    # Floppy ears
    c.draw_bezier((180, 150), (100, 180), (120, 300), (170, 260), width=4.0)
    c.draw_bezier((332, 150), (412, 180), (392, 300), (342, 260), width=4.0)
    # Eyes
    c.draw_circle(215, 185, 16, width=4.0)
    c.draw_circle(212, 180, 5, width=2.0)
    c.draw_circle(297, 185, 16, width=4.0)
    c.draw_circle(294, 180, 5, width=2.0)
    # Muzzle & nose
    c.draw_ellipse(256, 240, 22, 15, width=4.0)
    c.draw_bezier((256, 255), (256, 275), (235, 275), width=3.5)
    c.draw_bezier((256, 255), (256, 275), (277, 275), width=3.5)
    # Tongue
    c.draw_arc(256, 280, 14, 0, 180, width=3.0)
    # Body & Paws
    c.draw_bezier((180, 280), (170, 420), (200, 440), width=4.0)
    c.draw_bezier((332, 280), (342, 420), (312, 440), width=4.0)
    c.draw_arc(220, 435, 25, 180, 360, width=3.5)
    c.draw_arc(292, 435, 25, 180, 360, width=3.5)
    # Collar & Tag
    c.draw_bezier((185, 290), (256, 320), (327, 290), width=4.0)
    c.draw_circle(256, 325, 12, width=3.0)

def gen_animal_lion(c):
    # Majestic Lion Face & Mane
    # Outer fluffy mane
    for angle in range(0, 360, 20):
        rad = math.radians(angle)
        r1 = 175
        r2 = 215
        x1 = 256 + r1 * math.cos(rad)
        y1 = 256 + r1 * math.sin(rad)
        x2 = 256 + r2 * math.cos(rad + 0.15)
        y2 = 256 + r2 * math.sin(rad + 0.15)
        x3 = 256 + r1 * math.cos(rad + 0.3)
        y3 = 256 + r1 * math.sin(rad + 0.3)
        c.draw_bezier((x1, y1), (x2, y2), (x3, y3), width=3.5)
    # Face outline
    c.draw_bezier((170, 200), (160, 320), (256, 360), width=4.0)
    c.draw_bezier((342, 200), (352, 320), (256, 360), width=4.0)
    # Ears
    c.draw_arc(175, 170, 28, 160, 330, width=3.5)
    c.draw_arc(337, 170, 28, 210, 380, width=3.5)
    # Eyes
    c.draw_bezier((195, 240), (220, 230), (235, 245), width=4.0)
    c.draw_circle(215, 245, 10, width=3.0)
    c.draw_bezier((317, 240), (292, 230), (277, 245), width=4.0)
    c.draw_circle(297, 245, 10, width=3.0)
    # Nose
    c.draw_polyline([(240, 290), (272, 290), (256, 315)], width=4.0, closed=True)
    c.draw_line(256, 315, 256, 335, width=3.5)
    c.draw_bezier((256, 335), (230, 345), (210, 330), width=3.5)
    c.draw_bezier((256, 335), (282, 345), (302, 330), width=3.5)
    # Whiskers
    c.draw_line(190, 320, 140, 315, width=2.5)
    c.draw_line(190, 330, 135, 335, width=2.5)
    c.draw_line(322, 320, 372, 315, width=2.5)
    c.draw_line(322, 330, 377, 335, width=2.5)

def gen_flower_rose(c):
    # Center rose spiral
    c.draw_bezier((256, 170), (280, 160), (285, 190), (256, 200), width=3.5)
    c.draw_bezier((256, 200), (230, 210), (225, 180), (256, 170), width=3.5)
    # Inner petals
    c.draw_bezier((235, 165), (256, 140), (290, 160), (305, 195), width=3.5)
    c.draw_bezier((305, 195), (315, 235), (270, 250), (240, 245), width=3.5)
    c.draw_bezier((240, 245), (205, 230), (200, 185), (235, 165), width=3.5)
    # Outer blossom petals
    c.draw_bezier((210, 160), (160, 190), (180, 260), (230, 285), width=4.0)
    c.draw_bezier((230, 285), (256, 310), (295, 285), width=4.0)
    c.draw_bezier((295, 285), (345, 260), (355, 190), (305, 165), width=4.0)
    c.draw_bezier((220, 150), (256, 120), (295, 145), width=4.0)
    # Stem
    c.draw_bezier((256, 305), (250, 380), (265, 450), width=4.5)
    # Thorns
    c.draw_polyline([(252, 360), (235, 355), (254, 375)], width=3.0)
    c.draw_polyline([(260, 410), (280, 405), (262, 425)], width=3.0)
    # Leaves
    c.draw_bezier((254, 380), (210, 370), (170, 400), width=3.5)
    c.draw_bezier((170, 400), (210, 420), (257, 395), width=3.5)
    c.draw_line(255, 388, 170, 400, width=2.0) # Leaf vein

def gen_nature_mountain(c):
    # Majestic Mountain with Sun and Trees
    # Sun
    c.draw_circle(256, 140, 45, width=3.5)
    # Foreground peaks
    c.draw_polyline([(40, 420), (180, 180), (320, 420)], width=4.5)
    c.draw_polyline([(180, 180), (200, 260), (160, 310), (210, 370), (190, 420)], width=3.0) # Ridge
    c.draw_polyline([(240, 420), (360, 210), (472, 420)], width=4.5)
    c.draw_polyline([(360, 210), (340, 290), (380, 340), (350, 420)], width=3.0) # Ridge
    # Pine trees in foreground
    for tx in [90, 140, 390, 430]:
        c.draw_polyline([(tx, 380), (tx - 20, 420), (tx + 20, 420)], width=3.0, closed=True)
        c.draw_polyline([(tx, 360), (tx - 15, 395), (tx + 15, 395)], width=3.0, closed=True)
    # Horizon ground line
    c.draw_line(20, 420, 492, 420, width=4.0)

def gen_vehicle_sports_car(c):
    # Sleek aerodynamic car
    # Wheels
    c.draw_circle(140, 360, 38, width=4.5)
    c.draw_circle(140, 360, 22, width=3.0)
    c.draw_circle(380, 360, 38, width=4.5)
    c.draw_circle(380, 360, 22, width=3.0)
    # Underbody & wheel arches
    c.draw_line(178, 360, 342, 360, width=4.0)
    c.draw_arc(140, 360, 46, 170, 370, width=3.5)
    c.draw_arc(380, 360, 46, 170, 370, width=3.5)
    # Front bumper & Hood
    c.draw_bezier((50, 360), (60, 310), (130, 280), (200, 260), width=4.5)
    c.draw_line(50, 360, 94, 360, width=4.0)
    # Windshield & Roof
    c.draw_bezier((200, 260), (250, 180), (340, 180), width=4.5)
    # Rear window & Trunk & Spoiler
    c.draw_bezier((340, 180), (410, 230), (455, 270), width=4.5)
    c.draw_bezier((455, 270), (470, 310), (450, 360), width=4.5)
    c.draw_line(426, 360, 450, 360, width=4.0)
    # Spoiler
    c.draw_polyline([(435, 230), (455, 210), (475, 215), (460, 250)], width=3.5)
    # Window glass frame
    c.draw_polyline([(215, 255), (255, 195), (330, 195), (385, 255)], width=3.0, closed=True)
    c.draw_line(295, 195, 295, 255, width=3.0)
    # Headlight & Door line
    c.draw_polyline([(80, 295), (120, 285), (105, 305)], width=3.0, closed=True)
    c.draw_bezier((290, 260), (290, 330), (280, 355), width=3.0)

def gen_superhero_mask(c):
    # Iconic Superhero Cowl / Shield
    c.draw_circle(256, 256, 190, width=5.0)
    c.draw_circle(256, 256, 150, width=4.0)
    c.draw_circle(256, 256, 110, width=4.0)
    c.draw_circle(256, 256, 70, width=4.0)
    # 5-pointed Star in center
    star_pts = []
    for i in range(10):
        r = 65 if i % 2 == 0 else 28
        ang = -math.pi/2 + i * (math.pi / 5)
        star_pts.append((256 + r * math.cos(ang), 256 + r * math.sin(ang)))
    c.draw_polyline(star_pts, width=4.0, closed=True)

def gen_cute_boba(c):
    # Kawaii Boba Drink Cup
    # Cup rim
    c.draw_ellipse(256, 150, 95, 24, width=4.5)
    # Cup body tapering down
    c.draw_bezier((161, 150), (170, 360), (190, 430), (256, 440), width=4.5)
    c.draw_bezier((351, 150), (342, 360), (322, 430), (256, 440), width=4.5)
    # Domed lid
    c.draw_bezier((161, 150), (165, 80), (347, 80), (351, 150), width=4.5)
    # Big straw
    c.draw_polyline([(240, 60), (250, 20), (275, 20), (265, 60)], width=4.0)
    # Boba pearls
    for px, py in [(220, 395), (255, 410), (290, 395), (235, 360), (275, 365)]:
        c.draw_circle(px, py, 14, width=3.5)
    # Kawaii smiley eyes & blush
    c.draw_arc(215, 260, 16, 180, 360, width=4.0)
    c.draw_arc(297, 260, 16, 180, 360, width=4.0)
    c.draw_arc(256, 280, 14, 0, 180, width=3.5) # Smile
    c.draw_line(185, 285, 205, 285, width=3.0) # Blush
    c.draw_line(307, 285, 327, 285, width=3.0)

def gen_beginner_coffee_cup(c):
    # Simple beginner coffee mug
    c.draw_ellipse(240, 180, 85, 22, width=4.0)
    c.draw_bezier((155, 180), (155, 340), (240, 360), width=4.5)
    c.draw_bezier((325, 180), (325, 340), (240, 360), width=4.5)
    # Handle
    c.draw_bezier((325, 210), (410, 220), (400, 310), (315, 320), width=4.5)
    c.draw_bezier((325, 235), (385, 240), (375, 295), (318, 305), width=3.5)
    # Steam waves
    c.draw_bezier((210, 140), (195, 100), (225, 70), width=3.0)
    c.draw_bezier((250, 135), (235, 95), (265, 65), width=3.0)
    c.draw_bezier((290, 140), (275, 100), (305, 70), width=3.0)
    # Saucer plate
    c.draw_ellipse(240, 375, 130, 25, width=4.0)

def gen_advanced_realistic_eye(c):
    # Hyper-detailed eye sketch
    c.draw_bezier((70, 256), (200, 140), (420, 240), width=5.5)
    c.draw_bezier((70, 256), (220, 370), (420, 240), width=5.0)
    # Tear duct
    c.draw_polyline([(70, 256), (55, 260), (75, 270)], width=3.5)
    # Iris & pupil with detailed radiating spokes
    c.draw_circle(256, 256, 75, width=4.5)
    c.draw_circle(256, 256, 30, width=4.5) # Pupil
    # Highlight
    c.draw_circle(235, 230, 14, width=3.0)
    # Radiating iris fibers
    for ang in range(0, 360, 15):
        rad = math.radians(ang)
        x1 = 256 + 32 * math.cos(rad)
        y1 = 256 + 32 * math.sin(rad)
        x2 = 256 + 72 * math.cos(rad)
        y2 = 256 + 72 * math.sin(rad)
        c.draw_line(x1, y1, x2, y2, width=1.8)
    # Eyelashes
    for lx in range(120, 400, 25):
        t = (lx - 120) / 280.0
        ly = 256 - math.sin(t * math.pi) * 105
        c.draw_bezier((lx, ly), (lx + 8, ly - 35), (lx + 20, ly - 45), width=3.0)
    # Lower lashes
    for lx in range(140, 380, 35):
        t = (lx - 140) / 240.0
        ly = 256 + math.sin(t * math.pi) * 100
        c.draw_bezier((lx, ly), (lx + 4, ly + 22), (lx + 10, ly + 28), width=2.5)

# Tutorial stages for Anime Eye
def gen_tutorial_stage1(c):
    # Guideline circles and arcs
    c.draw_circle(256, 256, 90, width=2.5, color=(140, 140, 160, 200))
    c.draw_line(150, 256, 362, 256, width=2.0, color=(140, 140, 160, 200))
    c.draw_line(256, 150, 256, 362, width=2.0, color=(140, 140, 160, 200))
    c.draw_bezier((130, 260), (256, 160), (380, 230), width=4.0)

def gen_tutorial_stage2(c):
    gen_tutorial_stage1(c)
    # Iris and bottom lid
    c.draw_ellipse(256, 270, 60, 75, width=4.0)
    c.draw_bezier((170, 340), (256, 370), (340, 330), width=4.0)

def gen_tutorial_stage3(c):
    gen_tutorial_stage2(c)
    # Highlights and pupil
    c.draw_circle(235, 240, 20, width=3.0)
    c.draw_circle(280, 305, 12, width=2.5)
    c.draw_ellipse(260, 280, 26, 34, width=3.5)

def gen_tutorial_stage4(c):
    # Clean final inking
    c.draw_bezier((130, 260), (256, 160), (380, 230), width=6.5)
    c.draw_polyline([(365, 220), (410, 195), (385, 245)], width=4.5)
    c.draw_ellipse(256, 270, 60, 75, width=4.5)
    c.draw_bezier((170, 340), (256, 370), (340, 330), width=4.5)
    c.draw_circle(235, 240, 20, width=3.0)
    c.draw_circle(280, 305, 12, width=2.5)
    c.draw_ellipse(260, 280, 26, 34, width=4.0)
    c.draw_bezier((150, 190), (256, 150), (360, 185), width=3.5) # Eyelid crease
    c.draw_bezier((120, 120), (256, 80), (390, 120), width=5.5) # Brow

def main():
    items = [
        ('assets/drawings/anime_boy.png', gen_anime_boy),
        ('assets/drawings/anime_girl_eye.png', gen_anime_girl_eye),
        ('assets/drawings/cartoon_dragon.png', gen_cartoon_dragon),
        ('assets/drawings/cartoon_puppy.png', gen_cartoon_puppy),
        ('assets/drawings/animal_lion.png', gen_animal_lion),
        ('assets/drawings/flower_rose.png', gen_flower_rose),
        ('assets/drawings/nature_mountain.png', gen_nature_mountain),
        ('assets/drawings/vehicle_sports_car.png', gen_vehicle_sports_car),
        ('assets/drawings/superhero_mask.png', gen_superhero_mask),
        ('assets/drawings/cute_boba.png', gen_cute_boba),
        ('assets/drawings/beginner_coffee_cup.png', gen_beginner_coffee_cup),
        ('assets/drawings/advanced_realistic_eye.png', gen_advanced_realistic_eye),
        # Tutorials
        ('assets/drawings/tutorial_eye_step1.png', gen_tutorial_stage1),
        ('assets/drawings/tutorial_eye_step2.png', gen_tutorial_stage2),
        ('assets/drawings/tutorial_eye_step3.png', gen_tutorial_stage3),
        ('assets/drawings/tutorial_eye_step4.png', gen_tutorial_stage4),
    ]

    for path, func in items:
        c = Canvas(512, 512)
        func(c)
        c.save_png(path)
        print(f"Generated {path}")

if __name__ == '__main__':
    main()

def gen_app_logo(c):
    # App Logo: Stylized Camera viewfinder frame + pencil tip + glowing star/sparkle
    # Circular emblem with inner drawing
    c.draw_circle(256, 256, 210, width=8.0, color=(108, 92, 231, 255)) # Deep purple
    c.draw_circle(256, 256, 195, width=4.0, color=(9, 132, 227, 255)) # Blue
    # Camera viewfinder corners
    d = 120
    arm = 35
    for cx, cy, sx, sy in [
        (256 - d, 256 - d, 1, 1),
        (256 + d, 256 - d, -1, 1),
        (256 - d, 256 + d, 1, -1),
        (256 + d, 256 + d, -1, -1),
    ]:
        c.draw_polyline([(cx, cy + sy * arm), (cx, cy), (cx + sx * arm, cy)], width=6.0, color=(108, 92, 231, 255))
    # Stylized Pencil diagonally crossing
    c.draw_polyline([
        (180, 340), (160, 360), (190, 360), (180, 340) # Lead point
    ], width=4.0, closed=True, color=(25, 25, 30, 255))
    c.draw_polyline([
        (180, 340), (320, 200), (350, 230), (210, 370), (180, 340) # Shaft
    ], width=5.0, closed=True, color=(108, 92, 231, 255))
    # Sparkle / Magic Trace Star
    for px, py in [(340, 150), (160, 180), (350, 340)]:
        c.draw_line(px - 15, py, px + 15, py, width=3.5, color=(9, 132, 227, 255))
        c.draw_line(px, py - 15, px, py + 15, width=3.5, color=(9, 132, 227, 255))

def generate_logo():
    c = Canvas(512, 512)
    gen_app_logo(c)
    c.save_png('assets/images/app_logo.png')
    print("Generated assets/images/app_logo.png")

if __name__ == '__main__':
    generate_logo()
