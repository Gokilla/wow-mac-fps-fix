<div align="center">

# 🎮 WoW Mac FPS Fix

**¿World of Warcraft a 40–60 FPS en un Mac con Apple Silicon y un monitor 4K / 120 Hz? Recupera tus 120 FPS.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [中文](README.zh.md) · **Español** · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## Resumen rápido

En un Mac con un monitor externo de alta frecuencia, macOS puede presentar un juego a pantalla completa en modo **"Direct"** directamente a la pantalla. En esta configuración, WoW en modo "Direct" iba a **40–60 FPS**. Cuando macOS componía el mismo juego en modo **"Composited"**, llegaba a **100–120 FPS** con exactamente los mismos ajustes.

Este repo instala un pequeño asistente en segundo plano que mantiene una ventana invisible de 2×2 px por encima del juego **solo mientras WoW está abierto**, lo que fuerza la vía rápida *Composited*. También incluye un `Config.wtf` optimizado.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Síntomas

- Los FPS saltan a escalones entre **120 → 60 → ~40**, incluso con gráficos bajos.
- La GPU va solo a **media carga** y el juego usa **menos de un núcleo de CPU**, pero los FPS siguen bajos.
- **Al pulsar Cmd+Shift+5 (captura de pantalla), los FPS suben a más de 100** mientras el panel está abierto.
- Bajar la calidad gráfica apenas ayuda.

## Compruébalo tú mismo (2 minutos)

1. Activa el Metal HUD de Apple: `./scripts/metal-hud.sh on` y reinicia WoW.
2. Mira la línea superior derecha del HUD:
   - **`Direct`** + FPS bajos → tienes este problema.
   - Pulsa **Cmd+Shift+5**: cambia a **`Composited`** y los FPS se disparan. Confirmado.
3. Desactiva el HUD al terminar: `./scripts/metal-hud.sh off`.

## Por qué ocurre

| Modo | Qué hace macOS | Resultado aquí |
|---|---|---|
| **Direct** | Los fotogramas del juego van directamente a la pantalla, saltándose el compositor de WindowServer | 40–60 FPS, escalones 120/60/40 |
| **Composited** | WindowServer primero combina el juego con las demás ventanas | 100–120 FPS, fluido |

El patrón en escalones (120 → 60 → 40 = 120/1, /2, /3) sugiere que en modo Direct cada fotograma espera a un refresco de 120 Hz, incluso con el vsync del juego **desactivado**. El modo Composited desacopla el juego del refresco. Es una hipótesis basada en mediciones, no en el código fuente de Apple o Blizzard.

Cosas que **no** ayudaron en las pruebas: frecuencia variable (48–120 Hz), activar el vsync, pantalla completa exclusiva (`gxWindow 0` no tiene efecto en Mac) y bajar todos los ajustes al mínimo.

## La solución

### 1. Forzar Composited (solución principal)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- El código fuente son ~50 líneas de Swift: [`src/wow-composite.swift`](../src/wow-composite.swift). Sin acceso a la red ni recopilación de datos.
- Permanece inactivo hasta que aparece un proceso `World of Warcraft*.app`. Entonces muestra la ventana de 2×2 px, que es invisible y deja pasar los clics. Vuelve a ocultarla cuando cierras WoW.
- Funciona con WoW Forever (probado), Retail, Classic y otros clientes de WoW.

### 2. Ajustes optimizados para ~120 FPS (opcional)

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) renderiza internamente a 1080p y escala a 4K con FSR y nitidez, lo que mantiene la imagen definida. Desactiva el vsync y el cursor por hardware, limita los FPS a 120, quita los efectos y mantiene las texturas en alto.

> [!IMPORTANT]
> Cierra WoW con **Cmd+Q** antes de editar `Config.wtf`. El juego sobrescribe el archivo al salir.

### 3. Consejos sobre el monitor

- Algunos monitores se conectan como **YCbCr Limited** (colores lavados, texto borroso) y vuelven a ese modo tras reiniciar. Compruébalo en [BetterDisplay](https://github.com/waydabber/BetterDisplay) y cambia a **RGB Full**.
- Un escritorio escalado («parece 2560×1440» en un panel 4K) funciona bien con esta solución.

## Probado en

| Mac | macOS | Pantalla | Antes | Después |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (GPU de 38 núcleos, 32 GB) | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Probablemente afectados:** otros Mac con Apple Silicon (M1–M5) con pantallas externas de alta frecuencia. **Aún no está confirmado**. Abre un issue con tu Mac, tu pantalla y los FPS de antes y después para ampliar la tabla.

## Preguntas frecuentes

**¿Es seguro? ¿Me pueden banear?** No toca los archivos, la memoria ni la red del juego. Solo muestra una ventana normal de macOS, como cualquier app de superposición.

**¿Consumo de batería / rendimiento?** Prácticamente nulo: una comprobación de procesos cada 2 s y una ventana de 2×2 px mientras juegas.

**¿Otros juegos?** El mismo truco puede ayudar a cualquier juego Metal que muestre `Direct` + FPS bajos. Cambia la coincidencia de proceso en el código fuente.

<sub>Palabras clave: World of Warcraft FPS bajos en Mac, caída de FPS en WoW M1 M2 M3 M4 Max Pro, tirones en monitor externo 120Hz con Apple Silicon, Metal HUD Direct Composited, solución FPS WoW 4K en MacBook Pro, rendimiento de WoW Classic en Mac, ritmo de fotogramas en juegos macOS. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
