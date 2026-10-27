---
description: "Створити та перевірити кросплатформний GitHub Actions workflow для C++/CMake проєкту."
agent: build-engineer
---

# Create Actions

## Передумови

Перед початком перевір, що в поточному проєкті існують:

- `ci.sh`;
- `ci.bat`.

Також перевір, що поточний каталог є Git-репозиторієм, і прочитай наявний
workflow перед будь-якою зміною.

## Дії

1. Виконай перевірку Git-репозиторію:

   ```text
   git rev-parse --show-toplevel
   ```

2. Перевір наявність `ci.sh` і `ci.bat`.
3. Виконай усі інструкції зі skill
   [github-actions](../skills/github-actions/SKILL.md).
4. Створи або підтвердь `.github/workflows/ci.yml` з тригерами `push` і
   `pull_request` для `develop` та `master`, однією job, matrix трьох ОС і
   `fail-fast: false`.
5. Переконайся, що Unix-крок запускає лише `./ci.sh` через `bash`, а
   Windows-крок — лише `ci.bat` через `cmd`.
6. Не додавай у workflow прямі команди `cmake` або `ctest`, секрети чи іншу
   логіку збірки.
7. Перед завершенням покажи список змінених файлів і `git diff`.

Цей prompt вимагає фактичного створення `.github/workflows/ci.yml` через
файлові інструменти. Не замінюй створення workflow описом його структури.

## Очікувані файли

Після успішного виконання повинен існувати:

- `.github/workflows/ci.yml`.

Workflow має завантажувати `dist/` через `actions/upload-artifact@v4` з
унікальним ім’ям `hello-${{ matrix.os }}` і
`if-no-files-found: error`.

## Команди перевірки

Перевір:

```text
git rev-parse --show-toplevel
Test-Path ci.sh
Test-Path ci.bat
Test-Path .github/workflows/ci.yml
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
git status --short
git diff -- .github/workflows/ci.yml
```

Якщо `PyYAML` недоступний, використай `actionlint`, якщо він встановлений,
і явно повідом, якщо YAML неможливо перевірити доступними інструментами.

Переконайся, що workflow містить усі три ОС:

```text
ubuntu-latest
windows-latest
macos-latest
```

Переконайся, що `run`-кроки викликають лише `./ci.sh` або `ci.bat`, без
прямих команд `cmake` чи `ctest`.

## Повідомлення про помилку

Якщо `ci.sh` або `ci.bat` відсутній, Git-репозиторій не підтверджено, YAML
невалідний, відсутня ОС або workflow містить заборонену команду:

1. негайно зупинись;
2. покажи команду, код завершення та релевантний вивід;
3. поясни причину;
4. не перезаписуй і не видаляй файли;
5. не повідомляй про успішне завершення.

Якщо `ci.sh` не має прав на виконання, повідом про це окремо та зупинись
до виправлення режиму файлу згідно з skill.

## Ідемпотентність

Повторний запуск не повинен дублювати jobs, matrix, кроки або властивості
workflow. Перед зміною прочитай `.github/workflows/ci.yml`. Якщо файл уже
містить очікувану конфігурацію, підтвердь її без повторного запису. Якщо
файл існує з іншим вмістом, повідом про відмінність і зупинись згідно з
правилами skill.
