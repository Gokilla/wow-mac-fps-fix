<div align="center">

# 🎮 WoW Mac FPS Fix

**World of Warcraft at 40–60 FPS on an Apple Silicon Mac with a 4K / 120 Hz monitor? Get your 120 FPS back.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**English** · [Русский](i18n/README.ru.md) · [Українська](i18n/README.uk.md) · [中文](i18n/README.zh.md) · [Español](i18n/README.es.md) · [Deutsch](i18n/README.de.md) · [Français](i18n/README.fr.md) · [Português (BR)](i18n/README.pt-BR.md) · [日本語](i18n/README.ja.md) · [한국어](i18n/README.ko.md)

</div>

---

## TL;DR

On a Mac with an external high-refresh monitor, macOS can present a full-screen game **"Direct"** to the display. In this setup, WoW running "Direct" got **40–60 FPS**. When the same game was **"Composited"** by macOS, it got **100–120 FPS** with identical settings.

This repo installs a tiny background helper that keeps an invisible 2×2 px window above the game **only while WoW is running**, which forces the fast *Composited* path. It also includes a tuned `Config.wtf`.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Symptoms

- FPS jumps between **120 → 60 → ~40** in steps, even on low settings.
- The GPU is only about **half loaded**, and the game uses **less than one CPU core**, yet FPS stays low.
- **Pressing Cmd+Shift+5 (screenshot) makes FPS jump to 100+** while the overlay is open.
- Lowering graphics settings barely helps.

## Diagnose it yourself (2 minutes)

1. Turn on Apple's Metal HUD: `./scripts/metal-hud.sh on`, then restart WoW.
2. Look at the top-right line of the HUD:
   - **`Direct`** + low FPS → you have this problem.
   - Press **Cmd+Shift+5**: it switches to **`Composited`**, and FPS jumps up. Confirmed.
3. Turn the HUD off when done: `./scripts/metal-hud.sh off`.

## Why it happens

| Mode | What macOS does | Result here |
|---|---|---|
| **Direct** | The game's frames go straight to the display, bypassing the WindowServer compositor | 40–60 FPS, steps 120/60/40 |
| **Composited** | WindowServer blends the game with other windows first | 100–120 FPS, smooth |

The step pattern (120 → 60 → 40 = 120/1, /2, /3) suggests that in Direct mode each frame waits for a 120 Hz refresh, even with the game's vsync **off**. Composited mode decouples the game from the refresh. This is a hypothesis based on measurements, not on Apple or Blizzard source code.

Things that **did not** help in testing: Variable refresh (48–120 Hz), turning vsync on, exclusive fullscreen (`gxWindow 0` has no effect on Mac), and lowering every setting to minimum.

## The fix

### 1. Force Composited (main fix)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- The source is ~50 lines of Swift: [`src/wow-composite.swift`](src/wow-composite.swift). No network access, no data collection.
- It is idle until a `World of Warcraft*.app` process appears. Then it shows the 2×2 px window, which is click-through and invisible. It hides the window again when WoW exits.
- It works for WoW Forever (tested), Retail, Classic and other WoW clients.

### 2. Tuned settings for ~120 FPS (optional)

[`config/recommended-cvars.wtf`](config/recommended-cvars.wtf) renders at 1080p internally and upscales to 4K with FSR plus sharpening, which keeps the image crisp. It disables vsync and the hardware cursor, caps FPS at 120, turns effects off, and keeps textures high.

> [!IMPORTANT]
> Quit WoW with **Cmd+Q** before editing `Config.wtf`. The game rewrites the file on exit.

### 3. Monitor tips

- Some monitors connect as **YCbCr Limited** (washed-out colors, soft text) and fall back to it after a reboot. Check this in [BetterDisplay](https://github.com/waydabber/BetterDisplay) and switch to **RGB Full**.
- A scaled desktop (“looks like 2560×1440” on a 4K panel) is fine with this fix.

## Tested on

| Mac | macOS | Display | Before | After |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (38-core GPU, 32 GB) | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Likely affected:** other Apple Silicon Macs (M1–M5) with external high-refresh displays. This is **not yet confirmed**. Please open an issue with your Mac, display and before/after FPS so the table can grow.

## FAQ

**Is this safe? Will it get me banned?** It does not touch the game's files, memory or network. It only shows a normal macOS window, much like any overlay app.

**Battery / performance cost?** It costs almost nothing: a process check every 2 s, and a 2×2 px window while you play.

**Other games?** The same trick may help any Metal game that shows `Direct` + low FPS. Change the process match in the source.

<sub>Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
