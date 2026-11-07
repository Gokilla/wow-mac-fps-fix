<div align="center">

# 🎮 WoW Mac FPS Fix

**Apple Silicon Mac과 4K / 120 Hz 모니터에서 World of Warcraft가 40–60 FPS밖에 안 나오나요? 120 FPS를 되찾으세요.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [中文](README.zh.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · **한국어**

</div>

---

## TL;DR

고주사율 외부 모니터를 연결한 Mac에서는 macOS가 전체 화면 게임을 **"Direct"** 방식으로 디스플레이에 바로 출력할 수 있습니다. 이 환경에서 "Direct"로 실행된 WoW는 **40–60 FPS**에 그쳤습니다. 같은 게임을 macOS가 **"Composited"** 방식으로 출력하자, 설정을 하나도 바꾸지 않았는데 **100–120 FPS**가 나왔습니다.

이 저장소는 작은 백그라운드 헬퍼를 설치합니다. 이 헬퍼는 **WoW가 실행 중일 때만** 게임 위에 보이지 않는 2×2 px 창을 띄워 빠른 *Composited* 경로를 강제합니다. 튜닝된 `Config.wtf`도 포함되어 있습니다.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## 증상

- 옵션을 낮춰도 FPS가 **120 → 60 → 약 40**으로 계단식으로 오르내립니다.
- GPU는 **절반 정도**만 쓰이고 게임은 **CPU 코어 하나도 다 못 쓰는데**, FPS는 여전히 낮습니다.
- **Cmd+Shift+5(스크린샷)를 누르면** 오버레이가 열려 있는 동안 **FPS가 100 이상으로 뛰어오릅니다**.
- 그래픽 옵션을 낮춰도 거의 효과가 없습니다.

## 직접 진단하기 (2분)

1. Apple의 Metal HUD를 켭니다: `./scripts/metal-hud.sh on` 실행 후 WoW를 재시작하세요.
2. HUD 오른쪽 위 줄을 확인합니다:
   - **`Direct`** + 낮은 FPS → 바로 이 문제입니다.
   - **Cmd+Shift+5**를 누르면 **`Composited`**로 바뀌고 FPS가 뛰어오릅니다. 확정입니다.
3. 다 확인했으면 HUD를 끕니다: `./scripts/metal-hud.sh off`.

## 왜 이런 일이 생기나

| 모드 | macOS의 동작 | 이 환경에서의 결과 |
|---|---|---|
| **Direct** | 게임 프레임이 WindowServer 컴포지터를 거치지 않고 디스플레이로 바로 전달됨 | 40–60 FPS, 120/60/40 계단식 |
| **Composited** | WindowServer가 먼저 게임과 다른 창을 합성함 | 100–120 FPS, 부드러움 |

계단식 패턴(120 → 60 → 40 = 120/1, /2, /3)을 보면, Direct 모드에서는 게임의 vsync가 **꺼져 있어도** 프레임마다 120 Hz 주사를 기다리는 것으로 보입니다. Composited 모드에서는 게임이 주사율과 분리됩니다. 이는 측정을 바탕으로 한 가설이며, Apple이나 Blizzard의 소스 코드를 근거로 한 것은 아닙니다.

테스트에서 효과가 **없었던** 것: 가변 주사율(48–120 Hz), vsync 켜기, 독점 전체 화면(Mac에서는 `gxWindow 0`이 효과 없음), 모든 옵션을 최저로 낮추기.

## 해결 방법

### 1. Composited 강제 (핵심 해결책)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- 소스는 약 50줄짜리 Swift입니다: [`src/wow-composite.swift`](../src/wow-composite.swift). 네트워크 접근 없음, 데이터 수집 없음.
- `World of Warcraft*.app` 프로세스가 나타날 때까지 대기합니다. 프로세스가 뜨면 2×2 px 창을 띄우는데, 이 창은 보이지 않고 클릭도 그대로 통과합니다. WoW가 종료되면 창을 다시 숨깁니다.
- WoW Forever(테스트 완료), Retail, Classic 및 기타 WoW 클라이언트에서 작동합니다.

### 2. 약 120 FPS용 튜닝 설정 (선택)

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf)는 내부적으로 1080p로 렌더링한 뒤 FSR과 샤프닝으로 4K 업스케일하므로 화면이 선명하게 유지됩니다. vsync와 하드웨어 커서를 끄고, FPS를 120으로 제한하며, 이펙트를 끄고, 텍스처는 높음으로 유지합니다.

> [!IMPORTANT]
> `Config.wtf`를 수정하기 전에 **Cmd+Q**로 WoW를 종료하세요. 게임이 종료될 때 이 파일을 다시 씁니다.

### 3. 모니터 팁

- 일부 모니터는 **YCbCr Limited**로 연결되며(색이 바래 보이고 글자가 흐릿함), 재부팅 후 다시 그 상태로 돌아가기도 합니다. [BetterDisplay](https://github.com/waydabber/BetterDisplay)에서 확인하고 **RGB Full**로 바꾸세요.
- 스케일된 데스크톱(4K 패널에서 “2560×1440처럼 보임”)에서도 이 해결책은 문제없이 작동합니다.

## 테스트 환경

| Mac | macOS | 디스플레이 | 적용 전 | 적용 후 |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (38코어 GPU, 32 GB) | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**영향을 받을 가능성이 높은 환경:** 고주사율 외부 디스플레이를 쓰는 다른 Apple Silicon Mac(M1–M5). 다만 **아직 확인되지 않았습니다**. 표를 채울 수 있도록 사용 중인 Mac, 디스플레이, 적용 전후 FPS를 적어 issue를 열어 주세요.

## FAQ

**안전한가요? 밴 당하지 않나요?** 게임 파일, 메모리, 네트워크를 전혀 건드리지 않습니다. 일반 오버레이 앱처럼 평범한 macOS 창 하나를 띄울 뿐입니다.

**배터리 / 성능 부담은?** 거의 없습니다. 2초마다 프로세스를 확인하고, 플레이 중에 2×2 px 창 하나를 띄우는 게 전부입니다.

**다른 게임에도 되나요?** `Direct` + 낮은 FPS가 나오는 Metal 게임이라면 같은 방법이 도움이 될 수 있습니다. 소스에서 프로세스 이름 매칭 부분을 바꾸세요.

<sub>키워드: World of Warcraft Mac FPS 낮음, WoW FPS 드랍 M1 M2 M3 M4 Max Pro, Apple Silicon 외부 모니터 120Hz 끊김, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS 해결, WoW Classic Mac 성능, macOS 게임 프레임 페이싱. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
