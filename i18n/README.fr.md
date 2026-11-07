<div align="center">

# 🎮 WoW Mac FPS Fix

**World of Warcraft à 40–60 FPS sur un Mac Apple Silicon avec un écran 4K / 120 Hz ? Récupérez vos 120 FPS.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · [Українська](README.uk.md) · [中文](README.zh.md) · [Español](README.es.md) · [Deutsch](README.de.md) · **Français** · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## En bref

Sur un Mac relié à un écran externe à haute fréquence, macOS peut envoyer un jeu en plein écran **« Direct »** à l'écran. Dans cette configuration, WoW en mode « Direct » tournait à **40–60 FPS**. Quand macOS affichait le même jeu en mode **« Composited »**, il montait à **100–120 FPS** avec des réglages identiques.

Ce dépôt installe un petit utilitaire en arrière-plan qui maintient une fenêtre invisible de 2×2 px au-dessus du jeu **uniquement pendant que WoW tourne**, ce qui force le chemin rapide *Composited*. Il contient aussi un `Config.wtf` optimisé.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Symptômes

- Les FPS sautent par paliers entre **120 → 60 → ~40**, même en graphismes bas.
- Le GPU n'est chargé qu'à **environ la moitié** et le jeu utilise **moins d'un cœur CPU**, mais les FPS restent bas.
- **Appuyer sur Cmd+Shift+5 (capture d'écran) fait grimper les FPS au-delà de 100** tant que la barre de capture est ouverte.
- Baisser les réglages graphiques ne change presque rien.

## Diagnostiquez vous-même (2 minutes)

1. Activez le Metal HUD d'Apple : `./scripts/metal-hud.sh on`, puis relancez WoW.
2. Regardez la ligne en haut à droite du HUD :
   - **`Direct`** + FPS bas → vous avez ce problème.
   - Appuyez sur **Cmd+Shift+5** : il passe en **`Composited`** et les FPS s'envolent. Confirmé.
3. Désactivez le HUD une fois terminé : `./scripts/metal-hud.sh off`.

## Pourquoi ça arrive

| Mode | Ce que fait macOS | Résultat ici |
|---|---|---|
| **Direct** | Les images du jeu partent directement vers l'écran, sans passer par le compositeur WindowServer | 40–60 FPS, paliers 120/60/40 |
| **Composited** | WindowServer combine d'abord le jeu avec les autres fenêtres | 100–120 FPS, fluide |

Le schéma en paliers (120 → 60 → 40 = 120/1, /2, /3) suggère qu'en mode Direct chaque image attend un rafraîchissement à 120 Hz, même avec le vsync du jeu **désactivé**. Le mode Composited découple le jeu du rafraîchissement. C'est une hypothèse fondée sur des mesures, pas sur le code source d'Apple ou de Blizzard.

Ce qui **n'a pas** aidé pendant les tests : la fréquence variable (48–120 Hz), l'activation du vsync, le plein écran exclusif (`gxWindow 0` n'a aucun effet sur Mac) et tous les réglages au minimum.

## La solution

### 1. Forcer Composited (solution principale)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- Le code source fait ~50 lignes de Swift : [`src/wow-composite.swift`](../src/wow-composite.swift). Aucun accès réseau, aucune collecte de données.
- Il reste inactif jusqu'à ce qu'un processus `World of Warcraft*.app` apparaisse. Il affiche alors la fenêtre de 2×2 px, invisible et qui laisse passer les clics. Il la masque de nouveau quand WoW se ferme.
- Il fonctionne avec WoW Forever (testé), Retail, Classic et les autres clients WoW.

### 2. Réglages optimisés pour ~120 FPS (facultatif)

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) fait le rendu en 1080p en interne puis upscale en 4K avec FSR et accentuation de la netteté, ce qui garde une image nette. Il désactive le vsync et le curseur matériel, plafonne les FPS à 120, coupe les effets et laisse les textures en élevé.

> [!IMPORTANT]
> Quittez WoW avec **Cmd+Q** avant de modifier `Config.wtf`. Le jeu réécrit le fichier en quittant.

### 3. Conseils pour l'écran

- Certains écrans se connectent en **YCbCr Limited** (couleurs délavées, texte flou) et y reviennent après un redémarrage. Vérifiez-le dans [BetterDisplay](https://github.com/waydabber/BetterDisplay) et passez en **RGB Full**.
- Un bureau mis à l'échelle (« ressemble à 2560×1440 » sur une dalle 4K) ne pose aucun problème avec ce correctif.

## Testé sur

| Mac | macOS | Écran | Avant | Après |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (GPU 38 cœurs, 32 Go) | 27.0 | Dell S3225QS 4K 120 Hz (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Probablement concernés :** les autres Mac Apple Silicon (M1–M5) avec un écran externe à haute fréquence. Ce n'est **pas encore confirmé**. Ouvrez une issue avec votre Mac, votre écran et vos FPS avant/après pour enrichir le tableau.

## FAQ

**Est-ce sûr ? Est-ce que je risque un ban ?** Il ne touche ni aux fichiers, ni à la mémoire, ni au réseau du jeu. Il affiche simplement une fenêtre macOS normale, comme n'importe quelle app d'overlay.

**Impact sur la batterie / les performances ?** Quasiment nul : une vérification des processus toutes les 2 s et une fenêtre de 2×2 px pendant que vous jouez.

**D'autres jeux ?** La même astuce peut aider n'importe quel jeu Metal qui affiche `Direct` + FPS bas. Modifiez la correspondance de processus dans le code source.

<sub>Mots-clés : World of Warcraft FPS bas sur Mac, chute de FPS WoW M1 M2 M3 M4 Max Pro, saccades écran externe 120Hz Apple Silicon, Metal HUD Direct Composited, correctif FPS WoW 4K MacBook Pro, performances WoW Classic sur Mac, régularité des images dans les jeux macOS. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
