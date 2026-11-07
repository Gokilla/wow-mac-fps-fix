<div align="center">

# 🎮 WoW Mac FPS Fix

**World of Warcraft видає 40–60 FPS на Mac з Apple Silicon і 4K / 120 Гц монітором? Поверніть свої 120 FPS.**

[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple)](#tested-on)
[![WoW](https://img.shields.io/badge/World%20of%20Warcraft-Metal-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

[English](../README.md) · [Русский](README.ru.md) · **Українська** · [中文](README.zh.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

</div>

---

## Коротко

На Mac із зовнішнім монітором з високою частотою оновлення macOS може виводити повноекранну гру на дисплей у режимі **«Direct»**. У такій конфігурації WoW у режимі «Direct» видавав **40–60 FPS**. Коли та сама гра йшла через **«Composited»** (композитинг macOS), виходило **100–120 FPS** з тими самими налаштуваннями.

Цей репозиторій встановлює крихітний фоновий помічник, який тримає невидиме вікно 2×2 px поверх гри **лише поки запущено WoW** — і це примусово вмикає швидкий шлях *Composited*. Також у комплекті — налаштований `Config.wtf`.

```bash
git clone https://github.com/Gokilla/wow-mac-fps-fix.git
cd wow-mac-fps-fix && ./scripts/install.sh
```

## Симптоми

- FPS стрибає сходинками **120 → 60 → ~40**, навіть на низьких налаштуваннях.
- GPU завантажений приблизно **наполовину**, гра використовує **менше одного ядра CPU**, а FPS однаково низький.
- **Натискання Cmd+Shift+5 (скриншот) піднімає FPS до 100+**, поки відкрита ця панель.
- Зниження графіки майже не допомагає.

## Перевірте самі (2 хвилини)

1. Увімкніть Metal HUD від Apple: `./scripts/metal-hud.sh on`, потім перезапустіть WoW.
2. Подивіться на верхній правий рядок HUD:
   - **`Direct`** + низький FPS → у вас саме ця проблема.
   - Натисніть **Cmd+Shift+5**: режим переключиться на **`Composited`**, і FPS підскочить. Підтверджено.
3. Після перевірки вимкніть HUD: `./scripts/metal-hud.sh off`.

## Чому так відбувається

| Режим | Що робить macOS | Результат тут |
|---|---|---|
| **Direct** | Кадри гри йдуть прямо на дисплей в обхід композитора WindowServer | 40–60 FPS, сходинки 120/60/40 |
| **Composited** | WindowServer спочатку змішує гру з іншими вікнами | 100–120 FPS, плавно |

Сходинковий характер (120 → 60 → 40 = 120/1, /2, /3) вказує на те, що в режимі Direct кожен кадр чекає оновлення екрана на 120 Гц, навіть коли vsync у грі **вимкнено**. Режим Composited відв'язує гру від частоти оновлення. Це гіпотеза на основі вимірювань, а не вихідного коду Apple чи Blizzard.

Що **не** допомогло в тестах: Variable refresh (48–120 Гц), увімкнення vsync, ексклюзивний повноекранний режим (`gxWindow 0` на Mac ні на що не впливає) і зниження всіх налаштувань до мінімуму.

## Рішення

### 1. Примусовий Composited (основний фікс)

```bash
./scripts/install.sh     # builds from source (needs Xcode Command Line Tools), adds a LaunchAgent
./scripts/uninstall.sh   # removes everything
```

- Вихідний код — близько 50 рядків на Swift: [`src/wow-composite.swift`](../src/wow-composite.swift). Без доступу до мережі, без збору даних.
- Помічник простоює, доки не з'явиться процес `World of Warcraft*.app`. Тоді він показує вікно 2×2 px — невидиме і прозоре для кліків. Коли WoW закривається, вікно знову ховається.
- Працює з WoW Forever (перевірено), Retail, Classic та іншими клієнтами WoW.

### 2. Налаштування під ~120 FPS (за бажанням)

[`config/recommended-cvars.wtf`](../config/recommended-cvars.wtf) рендерить гру всередині в 1080p і апскейлить до 4K через FSR з підвищенням різкості, тож картинка лишається чіткою. Вимикає vsync і апаратний курсор, обмежує FPS на 120, вимикає ефекти й лишає текстури на високих.

> [!IMPORTANT]
> Перед редагуванням `Config.wtf` закрийте WoW через **Cmd+Q**. Під час виходу гра перезаписує цей файл.

### 3. Поради щодо монітора

- Деякі монітори підключаються в режимі **YCbCr Limited** (вицвілі кольори, розмитий текст) і повертаються до нього після перезавантаження. Перевірте це в [BetterDisplay](https://github.com/waydabber/BetterDisplay) і переключіть на **RGB Full**.
- Масштабований робочий стіл («як 2560×1440» на 4K-панелі) з цим фіксом працює нормально.

## Де перевірено

| Mac | macOS | Дисплей | До | Після |
|---|---|---|---|---|
| MacBook Pro 16" M2 Max (38-ядерний GPU, 32 ГБ) | 27.0 | Dell S3225QS 4K 120 Гц (HDMI) | 40–60 FPS, Direct | 117–120 FPS, Composited |

**Ймовірно, зачеплені:** інші Mac на Apple Silicon (M1–M5) із зовнішніми дисплеями з високою частотою оновлення. Це **поки не підтверджено**. Будь ласка, створіть issue із зазначенням вашого Mac, дисплея та FPS до/після, щоб таблиця поповнювалася.

## FAQ

**Це безпечно? Не забанять?** Помічник не чіпає файли гри, її пам'ять і мережу. Він просто показує звичайне вікно macOS — як будь-який застосунок-оверлей.

**Витрата батареї / продуктивності?** Практично нульова: перевірка процесів раз на 2 с і вікно 2×2 px, поки ви граєте.

**Інші ігри?** Той самий трюк може допомогти будь-якій грі на Metal, у якої видно `Direct` + низький FPS. Змініть зіставлення процесу у вихідному коді.

<sub>Ключові слова: низький FPS World of Warcraft на Mac, просідання FPS у WoW на M1 M2 M3 M4 Max Pro, статери на Apple Silicon із зовнішнім монітором 120 Гц, Metal HUD Direct Composited, фікс FPS WoW у 4K на MacBook Pro, продуктивність WoW Classic на Mac, фреймпейсинг ігор у macOS. Keywords: World of Warcraft low FPS Mac, WoW FPS drop M1 M2 M3 M4 Max Pro, Apple Silicon external monitor 120Hz stutter, Metal HUD Direct Composited, MacBook Pro WoW 4K FPS fix, WoW Classic Mac performance, macOS game frame pacing.</sub>
