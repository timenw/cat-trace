import struct, zlib

def make_png(w, h, rgb):
    def chk(t, d):
        c = t + d
        return struct.pack('>I', len(d)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = chk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
    raw = b''
    for y in range(h):
        raw += b'\x00'
        for x in range(w):
            raw += bytes(rgb)
    idat = chk(b'IDAT', zlib.compress(raw))
    iend = chk(b'IEND', b'')
    return sig + ihdr + idat + iend

color = (255, 140, 0)
for d, s in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
    with open(f'android/app/src/main/res/mipmap-{d}/ic_launcher.png', 'wb') as f:
        f.write(make_png(s, s, color))
    print(f'Created mipmap-{d}/ic_launcher.png ({s}x{s})')
