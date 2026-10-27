---
name: github-actions
description: "Застосовуй для створення та перевірки кросплатформного GitHub Actions workflow для C++/CMake проєкту на Ubuntu, Windows і macOS."
---

# GitHub Actions

## Призначення

Цей skill створює `.github/workflows/ci.yml`, який запускає на трьох
операційних системах наявний CI-скрипт проєкту та завантажує зібраний
артефакт.

## Вихід

Створи:

```text
.github/workflows/ci.yml
```

Не перезаписуй наявний workflow без попередньої перевірки. Якщо файл існує
і відрізняється від очікуваного, повідом шлях і різницю та зупинись.
Повторний запуск має бути ідемпотентним і не дублювати YAML-блоки або кроки.

## Вимоги до workflow

Файл `.github/workflows/ci.yml` повинен містити:

1. тригери `push` і `pull_request`;
2. обмеження обох тригерів гілками `develop` і `master`;
3. одну job;
4. `strategy.fail-fast: false`;
5. matrix з точно такими операційними системами:
   `ubuntu-latest`, `windows-latest`, `macos-latest`;
6. крок checkout;
7. для не-Windows запуск `./ci.sh` із `shell: bash`;
8. для Windows запуск `ci.bat` із `shell: cmd`;
9. крок `actions/upload-artifact@v4`, який завантажує `dist/`;
10. унікальне ім'я артефакту `hello-${{ matrix.os }}`;
11. `if-no-files-found: error`.

Приклад очікуваної структури:

```yaml
name: CI

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]

jobs:
  build-and-test:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Run CI script on Unix
        if: runner.os != 'Windows'
        run: ./ci.sh
        shell: bash
      - name: Run CI script on Windows
        if: runner.os == 'Windows'
        run: ci.bat
        shell: cmd
      - uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

У `run` кроків цього workflow дозволені лише запуск `./ci.sh` або `ci.bat`.
Не додавай у `ci.yml` команди `cmake`, `ctest`, компіляторні команди або
іншу логіку збірки: вона належить відповідним скриптам.

Не використовуй секрети, токени, паролі або їхні значення в workflow. Не
додавай кроки публікації даних чи звернення до сторонніх сервісів, крім
необхідних GitHub Actions.

## Процедура

1. Перевір наявність `ci.sh`, `ci.bat` і `dist/` як очікуваного результату
   їхнього запуску.
2. Перевір, чи існує `.github/workflows/ci.yml`, і прочитай його перед
   будь-якою зміною.
3. Створи workflow з одним job і заданою matrix.
4. Переконайся, що Unix-крок має `shell: bash`, Windows-крок — `shell: cmd`,
   а `run` не містить прямих команд CMake або CTest.
5. Перевір наявність усіх трьох ОС, тригерів, upload-artifact і параметрів
   артефакту.
6. Перевір YAML за допомогою:

   ```text
   python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
   ```

   Якщо `PyYAML` недоступний, використай `actionlint`, якщо він встановлений,
   і явно повідом про неможливість валідації, якщо немає жодного валідатора.
7. Покажи diff і список змінених файлів перед завершенням.

## Перевірки успіху

Роботу можна вважати успішною лише якщо:

- YAML синтаксично валідний;
- workflow має три ОС: Ubuntu, Windows і macOS;
- `fail-fast` дорівнює `false`;
- обидва тригери обмежені `develop` і `master`;
- не-Windows крок запускає лише `./ci.sh` через `bash`;
- Windows крок запускає лише `ci.bat` через `cmd`;
- артефакт використовує `actions/upload-artifact@v4`, шлях `dist/`,
  унікальне ім'я `hello-${{ matrix.os }}` і `if-no-files-found: error`;
- у файлі немає слів `token`, `password` або `secret` без урахування
  регістру;
- у `run` немає прямих команд CMake або CTest.

## Типова помилка

**`ci.sh` не має прав на виконання.** Workflow на Ubuntu або macOS не
пройде, якщо скрипт не executable. Перед завершенням перевір режим файлу та
за потреби виконай:

```text
git update-index --chmod=+x ci.sh
```

## Приклад

### Вхід

```text
ci.sh
ci.bat
dist/
```

### Очікуваний результат

```text
.github/workflows/ci.yml створено
triggers: push, pull_request
branches: develop, master
matrix: ubuntu-latest, windows-latest, macos-latest
fail-fast: false
ci.sh/ci.bat запускаються без прямих команд cmake або ctest
artifact: hello-${{ matrix.os }} з dist/
YAML validation: success
```
