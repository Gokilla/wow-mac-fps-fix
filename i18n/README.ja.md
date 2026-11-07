<div align="center">

# 🎮 WoW Mac FPS Fix

**Apple Silicon Mac と 4K / 120 Hz モニターで World of Warcraft が 40〜60 FPS しか出ない？ 120 FPS を取り戻そう。**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [中文](README.zh.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · **日本語** · [한국어](README.ko.md)

</div>

---

## TL;DR

高リフレッシュレートの外部モニターをつないだ Mac では、macOS がフルスクリーンのゲームを **"Direct"** でディスプレイに直接表示することがあります。この環境では、"Direct" で動く WoW は **40〜60 FPS** でした。同じゲームが macOS によって **"Composited"** で表示されると、設定はまったく同じまま **100〜120 FPS** 出ました。

このリポジトリは小さなバックグラウンドヘルパーをインストールします。**WoW の起動中だけ**ゲームの上に見えない 2×2 px のウィンドウを置き、高速な *Composited* 経路を強制します。チューニング済みの `Config.wtf` も同梱しています。

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## 症状

- 設定を低くしても、FPS が **120 → 60 → 約40** と段階的に上下する。
- GPU 負荷は**半分程度**、ゲームの CPU 使用率は **1 コア未満**なのに、FPS が低いまま。
- **Cmd+Shift+5（スクリーンショット）を押すと**、オーバーレイが開いている間だけ **FPS が 100 以上に跳ね上がる**。
- グラフィック設定を下げてもほとんど効果がない。

## 自分で診断する（2 分）

1. Apple の Metal HUD をオンにする: `./scripts/metal-hud.sh on`、その後 WoW を再起動。
2. HUD の右上の行を確認する:
   - **`Direct`** + 低 FPS → この問題に該当します。
   - **Cmd+Shift+5** を押すと **`Composited`** に切り替わり、FPS が跳ね上がる。確定です。
3. 終わったら HUD をオフにする: `./scripts/metal-hud.sh off`。

## なぜ起きるのか

| モード | macOS の動作 | この環境での結果 |
|---|---|---|
| **Direct** | ゲームのフレームが WindowServer のコンポジターを経由せず、ディスプレイに直接送られる | 40〜60 FPS、120/60/40 の段階 |
| **Composited** | WindowServer がまずゲームと他のウィンドウを合成する | 100〜120 FPS、なめらか |

段階的なパターン（120 → 60 → 40 = 120/1、/2、/3）から、Direct モードではゲームの vsync が**オフ**でも各フレームが 120 Hz のリフレッシュを待っていると考えられます。Composited モードではゲームがリフレッシュから切り離されます。これは計測に基づく仮説で、Apple や Blizzard のソースコードに基づくものではありません。

テストで効果が**なかった**もの: 可変リフレッシュレート（48〜120 Hz）、vsync オン、排他フルスクリーン（Mac では `gxWindow 0` は無効）、全設定を最低にすること。

## 解決方法

### 1. Composited を強制する（メインの対策）

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- ソースは約 50 行の Swift です: [`src/wow-composite.swift`](../src/wow-composite.swift)。ネットワークアクセスなし、データ収集なし。
- `World of Warcraft*.app` のプロセスが現れるまでは何もしません。現れたら 2×2 px のウィンドウを表示します。このウィンドウは見えず、クリックも透過します。WoW が終了するとウィンドウを再び隠します。
- WoW Forever（検証済み）、Retail、Classic、その他の WoW クライアントで動作します。

### 2. 約 120 FPS 向けのチューニング設定（任意）

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) は内部解像度 1080p でレンダリングし、FSR とシャープニングで 4K にアップスケールするので、画質はくっきりしたままです。vsync とハードウェアカーソルを無効にし、FPS 上限を 120 に設定、エフェクトをオフにして、テクスチャは高のまま維持します。

> [!IMPORTANT]
> `Config.wtf` を編集する前に **Cmd+Q** で WoW を終了してください。ゲームは終了時にこのファイルを上書きします。

### 3. モニターのヒント

- 一部のモニターは **YCbCr Limited** で接続され（色が白っぽく、文字がぼやける）、再起動後にまたそれに戻ることがあります。[BetterDisplay](https://github.com/waydabber/BetterDisplay) で確認して **RGB Full** に切り替えてください。
- スケーリングされたデスクトップ（4K パネルで「2560×1440 相当」）でも、この対策は問題なく使えます。

## 動作確認環境

| Mac | macOS | ディスプレイ | 導入前 | 導入後 |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max（38 コア GPU、32 GB） | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40〜60 FPS、Direct | 117〜120 FPS、Composited |

**影響を受ける可能性が高いもの:** 高リフレッシュレートの外部ディスプレイを使っている他の Apple Silicon Mac（M1〜M5）。ただし**まだ確認されていません**。表を充実させるため、お使いの Mac、ディスプレイ、導入前後の FPS を書いて issue を立ててください。

## FAQ

**安全？ BAN されない？** ゲームのファイル、メモリ、通信には一切触れません。普通の macOS ウィンドウを表示するだけで、一般的なオーバーレイアプリと同じです。

**バッテリーやパフォーマンスへの影響は？** ほぼゼロです。2 秒ごとのプロセスチェックと、プレイ中の 2×2 px のウィンドウだけです。

**他のゲームでも使える？** `Direct` + 低 FPS になる Metal ゲームなら、同じ方法が効くかもしれません。ソース内のプロセス名の照合部分を変更してください。

<sub>キーワード: World of Warcraft Mac FPS 低い、WoW FPS 低下 M1 M2 M3 M4 Max Pro、Apple Silicon 外部モニター 120Hz カクつき、Metal HUD Direct Composited、MacBook Pro WoW 4K FPS 改善、WoW Classic Mac パフォーマンス、macOS ゲーム フレームペーシング。Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
