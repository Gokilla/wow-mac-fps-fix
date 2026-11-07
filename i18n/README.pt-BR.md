<div align="center">

# 🎮 WoW Mac FPS Fix

**World of Warcraft rodando a 40–60 FPS num Mac com Apple Silicon e monitor 4K / 120 Hz? Recupere seus 120 FPS.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [中文](README.zh.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · **Português (BR)** · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## TL;DR

Num Mac com monitor externo de alta taxa de atualização, o macOS pode exibir um jogo em tela cheia no modo **"Direct"**, mandando os quadros direto para o monitor. Nesse cenário, o WoW em "Direct" ficava em **40–60 FPS**. Quando o mesmo jogo passava pelo modo **"Composited"** do macOS, chegava a **100–120 FPS** com as mesmas configurações.

Este repositório instala um pequeno helper em segundo plano que mantém uma janela invisível de 2×2 px por cima do jogo **somente enquanto o WoW está aberto**, o que força o caminho rápido *Composited*. Ele também inclui um `Config.wtf` otimizado.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Sintomas

- O FPS pula em degraus **120 → 60 → ~40**, mesmo no gráfico baixo.
- A GPU fica só **pela metade**, e o jogo usa **menos de um núcleo de CPU**, mas o FPS continua baixo.
- **Apertar Cmd+Shift+5 (captura de tela) faz o FPS subir para 100+** enquanto a sobreposição está aberta.
- Baixar as configurações gráficas quase não ajuda.

## Diagnostique você mesmo (2 minutos)

1. Ative o Metal HUD da Apple: `./scripts/metal-hud.sh on` e reinicie o WoW.
2. Olhe a linha no canto superior direito do HUD:
   - **`Direct`** + FPS baixo → você tem esse problema.
   - Aperte **Cmd+Shift+5**: o modo muda para **`Composited`** e o FPS dispara. Confirmado.
3. Desative o HUD quando terminar: `./scripts/metal-hud.sh off`.

## Por que isso acontece

| Modo | O que o macOS faz | Resultado aqui |
|---|---|---|
| **Direct** | Os quadros do jogo vão direto para o monitor, sem passar pelo compositor do WindowServer | 40–60 FPS, degraus 120/60/40 |
| **Composited** | O WindowServer primeiro combina o jogo com as outras janelas | 100–120 FPS, liso |

O padrão em degraus (120 → 60 → 40 = 120/1, /2, /3) indica que, no modo Direct, cada quadro espera um ciclo de atualização de 120 Hz, mesmo com o vsync do jogo **desligado**. O modo Composited desacopla o jogo da taxa de atualização. Isso é uma hipótese baseada em medições, não no código-fonte da Apple ou da Blizzard.

O que **não** ajudou nos testes: taxa de atualização variável (48–120 Hz), ligar o vsync, tela cheia exclusiva (`gxWindow 0` não tem efeito no Mac) e baixar todas as configurações para o mínimo.

## A correção

### 1. Forçar Composited (correção principal)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- O código-fonte tem ~50 linhas de Swift: [`src/wow-composite.swift`](../src/wow-composite.swift). Sem acesso à rede, sem coleta de dados.
- Ele fica ocioso até aparecer um processo `World of Warcraft*.app`. Aí ele exibe a janela de 2×2 px, que é invisível e deixa os cliques passarem. Quando o WoW fecha, a janela é escondida de novo.
- Funciona no WoW Forever (testado), no Retail, no Classic e em outros clientes do WoW.

### 2. Configurações otimizadas para ~120 FPS (opcional)

O [`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) renderiza internamente em 1080p e faz upscale para 4K com FSR e nitidez, o que mantém a imagem definida. Ele desativa o vsync e o cursor por hardware, limita o FPS a 120, desliga os efeitos e mantém as texturas no alto.

> [!IMPORTANT]
> Feche o WoW com **Cmd+Q** antes de editar o `Config.wtf`. O jogo reescreve o arquivo ao sair.

### 3. Dicas de monitor

- Alguns monitores se conectam como **YCbCr Limited** (cores lavadas, texto borrado) e voltam a isso depois de reiniciar. Confira no [BetterDisplay](https://github.com/waydabber/BetterDisplay) e mude para **RGB Full**.
- Uma área de trabalho escalonada (“parece 2560×1440” num painel 4K) funciona normalmente com esta correção.

## Testado em

| Mac | macOS | Monitor | Antes | Depois |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (GPU de 38 núcleos, 32 GB) | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Provavelmente afetados:** outros Macs com Apple Silicon (M1–M5) usando monitores externos de alta taxa de atualização. Isso **ainda não foi confirmado**. Abra uma issue com seu Mac, monitor e FPS antes/depois para a tabela crescer.

## FAQ

**É seguro? Dá ban?** Não mexe nos arquivos, na memória nem na rede do jogo. Só exibe uma janela normal do macOS, como qualquer app de sobreposição.

**Gasta bateria / desempenho?** Quase nada: uma checagem de processos a cada 2 s e uma janela de 2×2 px enquanto você joga.

**Outros jogos?** O mesmo truque pode ajudar qualquer jogo Metal que mostre `Direct` + FPS baixo. Basta mudar o nome do processo no código-fonte.

<sub>Palavras-chave: World of Warcraft FPS baixo no Mac, queda de FPS no WoW M1 M2 M3 M4 Max Pro, travadas com monitor externo 120Hz no Apple Silicon, Metal HUD Direct Composited, correção de FPS do WoW em 4K no MacBook Pro, desempenho do WoW Classic no Mac, frame pacing de jogos no macOS. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
