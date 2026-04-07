# Utils

**Utils** — коллекция полезных bash и python скриптов для повседневных задач.

## Содержание

- [Возможности](#возможности)
- [Установка](#установка)
- [Bash скрипты](#bash-скрипты)
- [Python скрипты](#python-скрипты)

## Возможности

### Bash скрипты

- **change_author** — изменение автора и email в истории git-репозитория
- **clear-docker** — очистка Docker ресурсов (контейнеры, образы, тома, сети)
- **mime-type** — установка приложений по умолчанию для MIME-типов
- **pdf-to-text** — конвертация PDF файлов в текст
- **python-ctrl** — установка и удаление Python из исходников
- **sunset** — управление фильтром синего света (для Hyprland)
- **wallpaper** — случайная смена обоев (для Hyprland с hyprpaper)

### Python скрипты

- **generate_password** — генерация надежных паролей

## Установка

### Автоматическая установка

Скрипт установит все утилиты в `~/.local/bin/`:

```bash
# Клонирование репозитория
git clone https://github.com/username/linux-utils.git
cd linux-utils

# Запуск скрипта установки
./install.sh
```

**Важно:** Убедитесь, что `~/.local/bin` добавлен в `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Ручная установка

Вы можете скопировать нужные скрипты вручную:

```bash
# Bash скрипты
cp bash_scripts/script-name.sh ~/.local/bin/script-name
chmod +x ~/.local/bin/script-name

# Python скрипты
cp python_scripts/script-name.py ~/.local/bin/script-name
chmod +x ~/.local/bin/script-name
```

## Bash скрипты

### change_author

Изменение автора и email в истории git-репозитория.

**Использование:**

```bash
change_author {-w|--work} | {-p|--personal}
```

**Опции:**

- `-w`, `--work` — заменить личную почту на рабочую
- `-p`, `--personal` — заменить рабочую почту на личную

**Требования:**

- `git-filter-repo` (рекомендуется) или встроенный `git filter-branch`

**Примечание:** Перед использованием отредактируйте скрипт и укажите свои email и имена:

```bash
WORK_EMAIL="work@example.com"
WORK_NAME="Your Name"
PERSONAL_EMAIL="personal@example.com"
PERSONAL_NAME="Your Name"
```

### clear-docker

Очистка Docker ресурсов с гибкими опциями.

**Использование:**

```bash
clear-docker [options]
```

**Опции:**

- `-c`, `--container` — очистить контейнеры
- `-i`, `--image` — очистить образы
- `-v`, `--volume` — очистить тома
- `-n`, `--network` — очистить сети
- `-b`, `--build` — очистить кэш сборки
- `-s`, `--system` — системная очистка (включая тома)
- `-a`, `--all` — очистить всё без запроса
- `-h`, `--help` — показать справку

**Примеры:**

```bash
# Очистка всего с подтверждением
clear-docker

# Очистка только контейнеров и образов
clear-docker -c -i

# Полная очистка без подтверждения
clear-docker -a
```

### mime-type

Установка приложения по умолчанию для всех MIME-типов из .desktop файла.

**Использование:**

```bash
mime-type -f <desktop-file>
```

**Опции:**

- `-f`, `--file` — путь к .desktop файлу
- `-h`, `--help` — показать справку

**Пример:**

```bash
mime-type -f /usr/share/applications/firefox.desktop
```

### pdf-to-text

Конвертация всех PDF файлов из директории в текстовые файлы.

**Использование:**

```bash
pdf-to-text SOURCE_DIR DEST_DIR
```

**Аргументы:**

- `SOURCE_DIR` — директория с PDF файлами
- `DEST_DIR` — директория для текстовых файлов (создается автоматически)

**Требования:**

- `pdftotext` (пакет `poppler-utils`)

**Пример:**

```bash
pdf-to-text ~/Documents/PDFs ~/Documents/Texts
```

### python-ctrl

Установка и удаление Python из исходников в `/opt/python`.

**Использование:**

```bash
python-ctrl <command> -v <version>
```

**Команды:**

- `install` — установить Python
- `delete` — удалить Python

**Опции:**

- `-v`, `--version` — версия Python (например: `3.11` или `311`)
- `-h`, `--help` — показать справку

**Примеры:**

```bash
# Установка последней версии Python 3.11.x
sudo python-ctrl install -v 3.11

# Удаление Python 3.11
sudo python-ctrl delete -v 3.11
```

**Примечание:** Требуются права root для установки.

### sunset

Управление фильтром синего света в Hyprland.

**Использование:**

```bash
sunset <command>
```

**Команды:**

- `enable` — включить фильтр (температура 5500K, гамма 80%)
- `disable` — отключить фильтр (сброс к стандартным значениям)

**Требования:**

- Hyprland с поддержкой `hyprsunset`

**Примеры:**

```bash
sunset enable
sunset disable
```

### wallpaper

Случайная смена обоев в Hyprland с использованием hyprpaper.

**Использование:**

```bash
wallpaper [OPTIONS] [WALLPAPER_DIR]
```

**Аргументы:**

- `WALLPAPER_DIR` — директория с обоями (по умолчанию: `~/Pictures/wallpaper/`)

**Опции:**

- `-h`, `--help` — показать справку

**Требования:**

- Hyprland с `hyprpaper`

**Примеры:**

```bash
# Использовать директорию по умолчанию
wallpaper

# Указать свою директорию
wallpaper ~/Pictures/my-wallpapers/
```

**Примечание:** В строке 54 скрипта укажите имя вашего монитора вместо `eDP-1`.

## Python скрипты

### generate_password

Генерация надежных паролей с настраиваемыми параметрами.

**Использование:**

```bash
generate_password [OPTIONS]
```

**Опции:**

- `-l`, `--length` — длина пароля (по умолчанию: 12)
- `-u`, `--upper` — включить заглавные буквы
- `-d`, `--digits` — включить цифры
- `-s`, `--symbols` — включить специальные символы

**Примеры:**

```bash
# Простой пароль из 12 строчных букв
generate_password

# Пароль из 16 символов с цифрами и заглавными буквами
generate_password -l 16 -u -d

# Сложный пароль со всеми типами символов
generate_password -l 20 -u -d -s
```

## Разработка

### Установка для разработки

```bash
# С использованием uv
uv pip install -e .
```

### Запуск Python скриптов через uv

```bash
uv run generate_password
```

## Лицензия

См. файл [LICENSE](LICENSE)

## Вклад

Приветствуются pull request'ы и сообщения об ошибках!

