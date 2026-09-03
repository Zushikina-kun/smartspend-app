import sys
from pathlib import Path

try:
    from PIL import Image, ImageOps
except Exception as e:
    print("=" * 70)
    print("KIRO IMAGE TOOL - STARTUP ERROR")
    print("=" * 70)
    print("Pillow could not be loaded.")
    print()
    print(f"Error: {e}")
    print()
    print("Run install_pillow.bat, then run this program again.")
    input("Press Enter to close...")
    raise SystemExit(1)

MAX_DIM = 1800
JPEG_QUALITY = 90
WEBP_QUALITY = 92
EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".tif", ".tiff"}

def process_file(src, source_root, output_root):
    try:
        with Image.open(src) as original:
            im = ImageOps.exif_transpose(original)
            old_dims = im.size
            old_bytes = src.stat().st_size

            scale = min(1.0, MAX_DIM / max(im.size))
            if scale < 1:
                im = im.resize(
                    (round(im.width * scale), round(im.height * scale)),
                    Image.Resampling.LANCZOS
                )

            dst = output_root / src.relative_to(source_root)
            dst.parent.mkdir(parents=True, exist_ok=True)

            fmt = (original.format or "").upper()

            if fmt in ("JPEG", "JPG"):
                if im.mode not in ("RGB", "L"):
                    if "A" in im.getbands():
                        bg = Image.new("RGB", im.size, "white")
                        bg.paste(im, mask=im.getchannel("A"))
                        im = bg
                    else:
                        im = im.convert("RGB")
                dst = dst.with_suffix(".jpg")
                im.save(dst, "JPEG", quality=JPEG_QUALITY,
                        optimize=True, progressive=True)

            elif fmt == "PNG":
                dst = dst.with_suffix(".png")
                im.save(dst, "PNG", optimize=True)

            elif fmt == "WEBP":
                dst = dst.with_suffix(".webp")
                im.save(dst, "WEBP", quality=WEBP_QUALITY, method=6)

            else:
                dst = dst.with_suffix(".png")
                if im.mode not in ("L", "RGB", "RGBA"):
                    im = im.convert("RGBA")
                im.save(dst, "PNG", optimize=True)

            return old_bytes, dst.stat().st_size, old_dims, im.size, None
    except Exception as e:
        return 0, 0, None, None, str(e)

def main():
    # Dragged folder = sys.argv[1].
    # Double-click = process folder containing this script.
    if len(sys.argv) >= 2 and sys.argv[1].strip():
        source_root = Path(sys.argv[1]).resolve()
    else:
        source_root = Path(__file__).resolve().parent

    if not source_root.is_dir():
        print(f"ERROR: Not a folder: {source_root}")
        input("Press Enter to close...")
        return 1

    output_root = source_root / "Kiro_Ready"
    output_root.mkdir(exist_ok=True)

    files = [
        p for p in source_root.rglob("*")
        if p.is_file()
        and p.suffix.lower() in EXTS
        and output_root not in p.parents
    ]

    print("=" * 70)
    print("                 KIRO IMAGE TOOL v3")
    print("=" * 70)
    print(f"Source : {source_root}")
    print(f"Output : {output_root}")
    print(f"Limit  : {MAX_DIM}px maximum dimension")
    print(f"Found  : {len(files)} image(s)")
    print("=" * 70)

    before_total = after_total = resized = errors = 0

    for i, src in enumerate(files, 1):
        before, after, old_dims, new_dims, error = process_file(
            src, source_root, output_root
        )
        if error:
            errors += 1
            print(f"[{i}/{len(files)}] ERROR: {src.name}")
            print(f"    {error}")
            continue

        before_total += before
        after_total += after
        if old_dims != new_dims:
            resized += 1

        print(
            f"[{i}/{len(files)}] {src.name}\n"
            f"    {old_dims[0]}x{old_dims[1]} -> "
            f"{new_dims[0]}x{new_dims[1]} | "
            f"{before/1024:.0f} KB -> {after/1024:.0f} KB"
        )

    saved = before_total - after_total
    pct = saved / before_total * 100 if before_total else 0

    print("\n" + "=" * 70)
    print("                         DONE")
    print("=" * 70)
    print(f"Processed : {len(files) - errors}")
    print(f"Resized   : {resized}")
    print(f"Errors    : {errors}")
    print(f"Before    : {before_total/1024/1024:.2f} MB")
    print(f"After     : {after_total/1024/1024:.2f} MB")
    print(f"Saved     : {saved/1024/1024:.2f} MB ({pct:.1f}%)")
    print(f"\nOutput folder:\n{output_root}")
    print("=" * 70)
    input("\nPress Enter to close...")
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as e:
        print("\nUNEXPECTED ERROR:")
        print(repr(e))
        input("\nPress Enter to close...")
        raise
