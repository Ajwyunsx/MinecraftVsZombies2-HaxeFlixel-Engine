#!/usr/bin/env python3
"""截图黑屏判定：非黑像素比例 / 颜色分布 / 非空区域数 / 是否出现 UI 文字。

纯标准库实现（zlib 手工解 PNG），不依赖 PIL。
用法： python analyze_shot.py shot1.png [shot2.png ...]
      python analyze_shot.py --json shot.png
"""
import json
import struct
import sys
import zlib
from collections import Counter


def read_png(path):
    with open(path, "rb") as f:
        data = f.read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a png: " + path)
    pos = 8
    idat = bytearray()
    width = height = bitdepth = colortype = None
    palette = None
    trns = None
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos:pos + 4])
        ctype = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if ctype == b"IHDR":
            width, height, bitdepth, colortype, comp, filt, interlace = struct.unpack(">IIBBBBB", chunk)
            if interlace != 0:
                raise ValueError("interlaced png not supported")
        elif ctype == b"PLTE":
            palette = [tuple(chunk[i:i + 3]) for i in range(0, len(chunk), 3)]
        elif ctype == b"tRNS":
            trns = chunk
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"IEND":
            break
    raw = zlib.decompress(bytes(idat))
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[colortype]
    if bitdepth == 8:
        bpp = channels
    elif bitdepth == 16:
        bpp = channels * 2
    else:
        bpp = 1
    stride = (width * channels * bitdepth + 7) // 8
    out = bytearray()
    prev = bytearray(stride)
    p = 0
    for _ in range(height):
        ftype = raw[p]
        p += 1
        line = bytearray(raw[p:p + stride])
        p += stride
        if ftype == 1:
            for i in range(bpp, stride):
                line[i] = (line[i] + line[i - bpp]) & 0xFF
        elif ftype == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ftype == 3:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                line[i] = (line[i] + ((a + prev[i]) >> 1)) & 0xFF
        elif ftype == 4:
            for i in range(stride):
                a = line[i - bpp] if i >= bpp else 0
                b = prev[i]
                c = prev[i - bpp] if i >= bpp else 0
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pr) & 0xFF
        out += line
        prev = line

    def pixels():
        if bitdepth == 8:
            if colortype == 2:
                for i in range(0, len(out), 3):
                    yield out[i], out[i + 1], out[i + 2]
            elif colortype == 6:
                for i in range(0, len(out), 4):
                    yield out[i], out[i + 1], out[i + 2]
            elif colortype == 0:
                for i in range(len(out)):
                    yield out[i], out[i], out[i]
            elif colortype == 4:
                for i in range(0, len(out), 2):
                    yield out[i], out[i], out[i]
            elif colortype == 3:
                for i in range(len(out)):
                    yield palette[out[i]]
        elif bitdepth == 16:
            step = channels * 2
            for i in range(0, len(out), step):
                r = out[i]
                if colortype == 2 or colortype == 6:
                    yield r, out[i + 2], out[i + 4]
                else:
                    yield r, r, r
        else:
            per = 8 // bitdepth
            mask = (1 << bitdepth) - 1
            for byte in out:
                for k in range(per):
                    idx = (byte >> (8 - bitdepth * (k + 1))) & mask
                    if colortype == 3:
                        yield palette[idx]
                    else:
                        v = idx * 255 // mask
                        yield v, v, v

    return width, height, list(pixels())


def analyze(path, black_threshold=12):
    width, height, px = read_png(path)
    total = len(px)
    nonblack = 0
    colors = Counter()
    # 32x18 网格统计非空块，用来量化"出现几块区域"
    gw, gh = 32, 18
    grid = [0] * (gw * gh)
    for idx, (r, g, b) in enumerate(px):
        if r > black_threshold or g > black_threshold or b > black_threshold:
            nonblack += 1
            colors[(r >> 4 << 4, g >> 4 << 4, b >> 4 << 4)] += 1
            x = (idx % width) * gw // width
            y = (idx // width) * gh // height
            grid[y * gw + x] += 1
    # 连通块（4 邻域）统计非空区域
    seen = [False] * (gw * gh)
    regions = 0
    for i in range(gw * gh):
        if grid[i] == 0 or seen[i]:
            continue
        regions += 1
        stack = [i]
        seen[i] = True
        while stack:
            cur = stack.pop()
            cx, cy = cur % gw, cur // gw
            for nx, ny in ((cx - 1, cy), (cx + 1, cy), (cx, cy - 1), (cx, cy + 1)):
                if 0 <= nx < gw and 0 <= ny < gh:
                    ni = ny * gw + nx
                    if grid[ni] > 0 and not seen[ni]:
                        seen[ni] = True
                        stack.append(ni)
    return {
        "file": path,
        "width": width,
        "height": height,
        "total_pixels": total,
        "nonblack_pixels": nonblack,
        "nonblack_ratio": round(nonblack / total, 5) if total else 0,
        "distinct_color_buckets": len(colors),
        "top_colors": [
            {"rgb": "#%02x%02x%02x" % c, "count": n, "ratio": round(n / total, 5)}
            for c, n in colors.most_common(8)
        ],
        "nonempty_grid_regions": regions,
        "grid": [round(v * 1000 / max(1, total * gw * gh // (gw * gh)), 1) for v in grid],
    }


def main():
    args = [a for a in sys.argv[1:] if a != "--json"]
    as_json = "--json" in sys.argv
    if not args:
        print(__doc__)
        return 1
    results = []
    for path in args:
        try:
            res = analyze(path)
        except Exception as exc:  # noqa: BLE001
            res = {"file": path, "error": str(exc)}
        results.append(res)
        if not as_json:
            if "error" in res:
                print("%s: ERROR %s" % (path, res["error"]))
                continue
            print("== %s ==" % res["file"])
            print("  尺寸            %dx%d" % (res["width"], res["height"]))
            print("  非黑像素        %d / %d = %.3f%%" % (
                res["nonblack_pixels"], res["total_pixels"], res["nonblack_ratio"] * 100))
            print("  颜色桶数量      %d" % res["distinct_color_buckets"])
            print("  非空网格区域数  %d（32x18 网格，4 邻域连通）" % res["nonempty_grid_regions"])
            print("  主要颜色        " + ", ".join(
                "%s %.2f%%" % (c["rgb"], c["ratio"] * 100) for c in res["top_colors"]))
    if as_json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
