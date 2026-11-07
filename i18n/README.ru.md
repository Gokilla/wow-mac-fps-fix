<div align="center">

# 🎮 WoW Mac FPS Fix

**World of Warcraft выдаёт 40–60 FPS на Mac с Apple Silicon и 4K / 120 Гц мониторе? Верните свои 120 FPS.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · **Русский** · [Українська](README.uk.md) · [中文](README.zh.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## Коротко

На Mac с внешним монитором с высокой частотой обновления macOS может выводить полноэкранную игру на дисплей в режиме **«Direct»**. В такой конфигурации WoW в режиме «Direct» выдавал **40–60 FPS**. Когда та же игра шла через **«Composited»** (композитинг macOS), получалось **100–120 FPS** при тех же настройках.

Этот репозиторий ставит крошечный фоновый помощник, который держит невидимое окно 2×2 px поверх игры **только пока запущен WoW** — и это принудительно включает быстрый путь *Composited*. Также в комплекте — настроенный `Config.wtf`.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Симптомы

- FPS скачет ступеньками **120 → 60 → ~40**, даже на низких настройках.
- GPU загружен примерно **наполовину**, игра использует **меньше одного ядра CPU**, а FPS всё равно низкий.
- **Нажатие Cmd+Shift+5 (скриншот) поднимает FPS до 100+**, пока открыта эта панель.
- Снижение графики почти не помогает.

## Проверьте сами (2 минуты)

1. Включите Metal HUD от Apple: `./scripts/metal-hud.sh on`, затем перезапустите WoW.
2. Посмотрите на верхнюю правую строку HUD:
   - **`Direct`** + низкий FPS → у вас именно эта проблема.
   - Нажмите **Cmd+Shift+5**: режим переключится на **`Composited`**, и FPS подскочит. Подтверждено.
3. После проверки выключите HUD: `./scripts/metal-hud.sh off`.

## Почему так происходит

| Режим | Что делает macOS | Результат здесь |
|---|---|---|
| **Direct** | Кадры игры идут прямо на дисплей в обход композитора WindowServer | 40–60 FPS, ступеньки 120/60/40 |
| **Composited** | WindowServer сначала смешивает игру с другими окнами | 100–120 FPS, плавно |

Ступенчатый характер (120 → 60 → 40 = 120/1, /2, /3) говорит о том, что в режиме Direct каждый кадр ждёт обновления экрана на 120 Гц, даже когда vsync в игре **выключен**. Режим Composited отвязывает игру от частоты обновления. Это гипотеза на основе замеров, а не исходного кода Apple или Blizzard.

Что **не** помогло в тестах: Variable refresh (48–120 Гц), включение vsync, эксклюзивный полноэкранный режим (`gxWindow 0` на Mac ни на что не влияет) и снижение всех настроек до минимума.

## Решение

### 1. Принудительный Composited (основной фикс)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- Исходник — около 50 строк на Swift: [`src/wow-composite.swift`](../src/wow-composite.swift). Без доступа к сети, без сбора данных.
- Помощник простаивает, пока не появится процесс `World of Warcraft*.app`. Тогда он показывает окно 2×2 px — невидимое и пропускающее клики. Когда WoW закрывается, окно снова скрывается.
- Работает с WoW Forever (проверено), Retail, Classic и другими клиентами WoW.

### 2. Настройки под ~120 FPS (по желанию)

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) рендерит игру внутри в 1080p и апскейлит до 4K через FSR с повышением резкости, так что картинка остаётся чёткой. Отключает vsync и аппаратный курсор, ограничивает FPS на 120, выключает эффекты и оставляет текстуры на высоких.

> [!IMPORTANT]
> Перед редактированием `Config.wtf` закройте WoW через **Cmd+Q**. При выходе игра перезаписывает этот файл.

### 3. Советы по монитору

- Некоторые мониторы подключаются в режиме **YCbCr Limited** (блёклые цвета, мыльный текст) и возвращаются в него после перезагрузки. Проверьте это в [BetterDisplay](https://github.com/waydabber/BetterDisplay) и переключите на **RGB Full**.
- Масштабированный рабочий стол («как 2560×1440» на 4K-панели) с этим фиксом работает нормально.

## Где проверено

| Mac | macOS | Дисплей | До | После |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (38-ядерный GPU, 32 ГБ) | 27.0 | Dell S3225QS 4K 120 Гц (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Вероятно, затронуты:** другие Mac на Apple Silicon (M1–M5) с внешними дисплеями с высокой частотой обновления. Это **пока не подтверждено**. Пожалуйста, создайте issue с указанием вашего Mac, дисплея и FPS до/после, чтобы таблица пополнялась.

## FAQ

**Это безопасно? Не забанят?** Помощник не трогает файлы игры, её память и сеть. Он просто показывает обычное окно macOS — как любое приложение-оверлей.

**Расход батареи / производительности?** Практически нулевой: проверка процессов раз в 2 с и окно 2×2 px, пока вы играете.

**Другие игры?** Тот же трюк может помочь любой игре на Metal, у которой видно `Direct` + низкий FPS. Поменяйте сопоставление процесса в исходнике.

<sub>Ключевые слова: низкий FPS World of Warcraft на Mac, просадки FPS в WoW на M1 M2 M3 M4 Max Pro, статтеры на Apple Silicon с внешним монитором 120 Гц, Metal HUD Direct Composited, фикс FPS WoW в 4K на MacBook Pro, производительность WoW Classic на Mac, фреймпейсинг игр в macOS. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
