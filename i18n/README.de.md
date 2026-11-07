<div align="center">

# 🎮 WoW Mac FPS Fix

**World of Warcraft mit 40–60 FPS auf einem Apple-Silicon-Mac mit 4K- / 120-Hz-Monitor? Hol dir deine 120 FPS zurück.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [中文](README.zh.md) · [Español](README.es.md) · **Deutsch** · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## Kurzfassung

Auf einem Mac mit externem Monitor mit hoher Bildwiederholrate kann macOS ein Vollbildspiel **„Direct“** an das Display ausgeben. In diesem Setup lief WoW im „Direct“-Modus mit **40–60 FPS**. Wenn macOS dasselbe Spiel **„Composited“** ausgab, waren es bei identischen Einstellungen **100–120 FPS**.

Dieses Repo installiert einen winzigen Hintergrund-Helfer, der ein unsichtbares 2×2-px-Fenster über dem Spiel hält, **aber nur, solange WoW läuft**. Das erzwingt den schnellen *Composited*-Pfad. Außerdem enthält es eine optimierte `Config.wtf`.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Symptome

- Die FPS springen in Stufen zwischen **120 → 60 → ~40**, selbst auf niedrigen Einstellungen.
- Die GPU ist nur etwa **zur Hälfte ausgelastet** und das Spiel nutzt **weniger als einen CPU-Kern**, trotzdem bleiben die FPS niedrig.
- **Drückt man Cmd+Shift+5 (Screenshot), springen die FPS auf über 100**, solange das Overlay offen ist.
- Grafikeinstellungen runterzuschrauben bringt kaum etwas.

## Selbst prüfen (2 Minuten)

1. Apples Metal HUD einschalten: `./scripts/metal-hud.sh on`, dann WoW neu starten.
2. Die Zeile oben rechts im HUD ansehen:
   - **`Direct`** + niedrige FPS → du hast genau dieses Problem.
   - **Cmd+Shift+5** drücken: Es wechselt zu **`Composited`** und die FPS schnellen hoch. Bestätigt.
3. Das HUD danach wieder ausschalten: `./scripts/metal-hud.sh off`.

## Warum das passiert

| Modus | Was macOS macht | Ergebnis hier |
|---|---|---|
| **Direct** | Die Frames des Spiels gehen direkt ans Display, am WindowServer-Compositor vorbei | 40–60 FPS, Stufen 120/60/40 |
| **Composited** | WindowServer kombiniert das Spiel zuerst mit den anderen Fenstern | 100–120 FPS, flüssig |

Das Stufenmuster (120 → 60 → 40 = 120/1, /2, /3) deutet darauf hin, dass im Direct-Modus jeder Frame auf einen 120-Hz-Refresh wartet, selbst wenn vsync im Spiel **aus** ist. Der Composited-Modus entkoppelt das Spiel vom Refresh. Das ist eine Hypothese auf Basis von Messungen, nicht auf Basis von Quellcode von Apple oder Blizzard.

Was im Test **nicht** geholfen hat: variable Bildwiederholrate (48–120 Hz), vsync einschalten, exklusiver Vollbildmodus (`gxWindow 0` hat auf dem Mac keine Wirkung) und alle Einstellungen auf Minimum.

## Die Lösung

### 1. Composited erzwingen (Hauptlösung)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- Der Quellcode umfasst ~50 Zeilen Swift: [`src/wow-composite.swift`](../src/wow-composite.swift). Kein Netzwerkzugriff, keine Datensammlung.
- Er bleibt untätig, bis ein Prozess `World of Warcraft*.app` auftaucht. Dann zeigt er das 2×2-px-Fenster an, das unsichtbar und für Klicks durchlässig ist. Sobald WoW beendet wird, blendet er das Fenster wieder aus.
- Funktioniert mit WoW Forever (getestet), Retail, Classic und anderen WoW-Clients.

### 2. Optimierte Einstellungen für ~120 FPS (optional)

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) rendert intern in 1080p und skaliert per FSR mit Nachschärfen auf 4K hoch, sodass das Bild scharf bleibt. Die Datei deaktiviert vsync und den Hardware-Cursor, begrenzt die FPS auf 120, schaltet Effekte ab und lässt die Texturen auf hoch.

> [!IMPORTANT]
> Beende WoW mit **Cmd+Q**, bevor du `Config.wtf` bearbeitest. Das Spiel überschreibt die Datei beim Beenden.

### 3. Monitor-Tipps

- Manche Monitore verbinden sich als **YCbCr Limited** (blasse Farben, unscharfe Schrift) und fallen nach einem Neustart wieder darauf zurück. Prüfe das in [BetterDisplay](https://github.com/waydabber/BetterDisplay) und stelle auf **RGB Full** um.
- Ein skalierter Desktop („wie 2560×1440“ auf einem 4K-Panel) ist mit diesem Fix kein Problem.

## Getestet auf

| Mac | macOS | Display | Vorher | Nachher |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (38-Kern-GPU, 32 GB) | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Wahrscheinlich betroffen:** andere Apple-Silicon-Macs (M1–M5) mit externen Displays mit hoher Bildwiederholrate. Das ist **noch nicht bestätigt**. Bitte eröffne ein Issue mit deinem Mac, deinem Display und den FPS vorher/nachher, damit die Tabelle wachsen kann.

## FAQ

**Ist das sicher? Kann ich dafür gebannt werden?** Es fasst weder Dateien noch Speicher oder Netzwerk des Spiels an. Es zeigt nur ein ganz normales macOS-Fenster an, wie jede Overlay-App.

**Akku- / Leistungskosten?** Praktisch keine: eine Prozessprüfung alle 2 s und ein 2×2-px-Fenster, während du spielst.

**Andere Spiele?** Derselbe Trick kann bei jedem Metal-Spiel helfen, das `Direct` + niedrige FPS zeigt. Ändere dafür den Prozessabgleich im Quellcode.

<sub>Stichwörter: World of Warcraft niedrige FPS Mac, WoW FPS-Einbruch M1 M2 M3 M4 Max Pro, Apple Silicon externer Monitor 120Hz Ruckeln, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS Fix, WoW Classic Mac Leistung, macOS Spiele Frame Pacing. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
