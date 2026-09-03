# Kiro Image Tool v4

## What was actually broken

The error was:

```
Unable to create process using '"C:\Program Files\Python314\python3.14t.exe" ...':
The system cannot find the file specified.
```

`python3.14t.exe` is Python 3.14's **free-threaded (experimental) build**.
Windows' `py` launcher had that registered as its default interpreter, but
the file doesn't actually exist on disk — so every `py ...` call failed
immediately, before it ever reached pip or Pillow. This had nothing to do
with your internet connection or Pillow itself.

## What v4 changes

Both `.bat` files now **test each candidate interpreter before trusting it**:

```
python
py -3
py -3.13
py -3.12
py -3.11
py
```

Each one is run with `-c "import sys"` first. Only a candidate that actually
executes successfully gets used. This skips the broken `py` default
entirely instead of relying on it.

## If it still can't find a working Python

Run this in Command Prompt to see what's actually installed:

```
py -0p
```

This lists every Python the launcher knows about and its real file path.
If the only entry is a `3.14t` (free-threaded) build, that's the problem —
either:

1. Reinstall standard Python from https://www.python.org/downloads/,
   making sure **"Add python.exe to PATH"** is checked and the
   **free-threaded / experimental** option is left unchecked, or
2. If you specifically need 3.14, install the regular (non-`t`) 3.14
   build alongside it, so `py -3.14` (not `py -3.14t`) resolves correctly.

## Easiest use

Put these files in your screenshots folder:

- `Kiro_Image_Tool.bat`
- `kiro_image_tool.py`
- `install_pillow.bat`

Then double-click `Kiro_Image_Tool.bat`.

It processes the folder containing the BAT and creates `Kiro_Ready`.

## Drag and drop

You can also drag a folder onto `Kiro_Image_Tool.bat`.

## First run

The tool checks whether Pillow is installed. If it isn't, it automatically
attempts `pip install --user --upgrade Pillow` using whichever interpreter
it found working.

## Settings

- Maximum dimension: 1800 px
- JPEG quality: 90
- WebP quality: 92
- PNG optimization enabled
- Originals are never overwritten

## Kiro

The 1800 px limit is intentional — Kiro reported a 2000 px maximum
dimension for many-image requests. The extra 200 px is a safety margin.
