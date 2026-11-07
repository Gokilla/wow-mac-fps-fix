<div align="center">

# 🎮 WoW Mac FPS Fix

**在 Apple Silicon Mac 上外接 4K / 120 Hz 显示器玩《魔兽世界》只有 40–60 FPS？把你的 120 FPS 找回来。**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · **中文** · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## 太长不看

在外接高刷显示器的 Mac 上，macOS 可能会以 **“Direct”** 方式把全屏游戏直接送到显示器。在这种配置下，以 “Direct” 方式运行的 WoW 只有 **40–60 FPS**。而同一款游戏在由 macOS **“Composited”**（合成）时，相同设置下能跑到 **100–120 FPS**。

本仓库会安装一个很小的后台辅助程序，**仅在 WoW 运行期间**在游戏上方保持一个不可见的 2×2 px 窗口，从而强制走更快的 *Composited* 路径。仓库里还附带一份调优过的 `Config.wtf`。

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## 症状

- FPS 呈阶梯式在 **120 → 60 → ~40** 之间跳动，即使是低画质也一样。
- GPU 大约只有**一半负载**，游戏占用**不到一个 CPU 核心**，但 FPS 依然很低。
- **按下 Cmd+Shift+5（截图）后，只要截图工具栏开着，FPS 就会跳到 100+。**
- 降低画质几乎没用。

## 自己诊断（2 分钟）

1. 打开 Apple 的 Metal HUD：`./scripts/metal-hud.sh on`，然后重启 WoW。
2. 看 HUD 右上角那一行：
   - **`Direct`** + 低 FPS → 你遇到的就是这个问题。
   - 按 **Cmd+Shift+5**：它会切换成 **`Composited`**，FPS 随之上升。确认无误。
3. 诊断完后关闭 HUD：`./scripts/metal-hud.sh off`。

## 原因

| 模式 | macOS 的行为 | 实测结果 |
|---|---|---|
| **Direct** | 游戏画面绕过 WindowServer 合成器，直接送往显示器 | 40–60 FPS，阶梯 120/60/40 |
| **Composited** | WindowServer 先把游戏与其他窗口合成 | 100–120 FPS，流畅 |

这种阶梯规律（120 → 60 → 40 = 120/1、/2、/3）表明，在 Direct 模式下，即使游戏内 vsync 处于**关闭**状态，每一帧仍要等待 120 Hz 的刷新。Composited 模式则让游戏与刷新解耦。这是基于实测得出的推测，而非来自 Apple 或 Blizzard 的源代码。

测试中**无效**的做法：可变刷新率（48–120 Hz）、开启 vsync、独占全屏（`gxWindow 0` 在 Mac 上不起作用），以及把所有设置调到最低。

## 解决方法

### 1. 强制 Composited（主要修复）

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- 源码只有约 50 行 Swift：[`src/wow-composite.swift`](../src/wow-composite.swift)。不联网，不收集任何数据。
- 在出现 `World of Warcraft*.app` 进程之前，它处于空闲状态。之后它会显示一个 2×2 px 的窗口，该窗口不可见且点击可穿透。WoW 退出后，窗口会再次隐藏。
- 适用于 WoW Forever（已测试）、正式服（Retail）、怀旧服（Classic）以及其他 WoW 客户端。

### 2. 约 120 FPS 的调优设置（可选）

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) 以 1080p 进行内部渲染，并通过 FSR 加锐化放大到 4K，画面依旧清晰。它会关闭 vsync 和硬件光标，将 FPS 上限设为 120，关闭特效，并保持高纹理质量。

> [!IMPORTANT]
> 编辑 `Config.wtf` 之前，请先用 **Cmd+Q** 退出 WoW。游戏退出时会重写该文件。

### 3. 显示器小贴士

- 有些显示器连接后会处于 **YCbCr Limited** 模式（颜色发灰、文字发虚），并且重启后会回到该模式。可在 [BetterDisplay](https://github.com/waydabber/BetterDisplay) 中检查并切换到 **RGB Full**。
- 使用缩放桌面（在 4K 屏上“看起来像 2560×1440”）时，本修复同样有效。

## 测试环境

| Mac | macOS | 显示器 | 修复前 | 修复后 |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max（38 核 GPU，32 GB） | 27.0 | Dell S3225QS 4K 120 Hz（USB-C） | 40–60 FPS，Direct | 117–120 FPS，Composited |

**可能受影响：** 其他外接高刷显示器的 Apple Silicon Mac（M1–M5）。这一点**尚未确认**。欢迎提交 issue，写明你的 Mac、显示器以及修复前后的 FPS，帮助完善这张表。

## 常见问题

**安全吗？会被封号吗？** 它不会触碰游戏文件、内存或网络，只是显示一个普通的 macOS 窗口，和任何悬浮窗应用没什么两样。

**耗电 / 性能开销？** 几乎为零：每 2 秒检查一次进程，游戏时多一个 2×2 px 的窗口。

**其他游戏？** 同样的技巧可能对任何显示 `Direct` + 低 FPS 的 Metal 游戏有效。修改源码中的进程匹配即可。

<sub>关键词：魔兽世界 Mac 低帧率，WoW 掉帧 M1 M2 M3 M4 Max Pro，Apple Silicon 外接显示器 120Hz 卡顿，Metal HUD Direct Composited，MacBook Pro 魔兽世界 4K 帧率修复，魔兽世界怀旧服 Mac 性能，macOS 游戏帧生成节奏。Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
