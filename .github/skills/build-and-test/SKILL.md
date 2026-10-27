---
name: build-and-test
description: "Застосовуй, коли потрібно створити або перевірити CMake-збірку C++17, GoogleTest/CTest і кросплатформні скрипти CI для Windows, Linux та macOS."
---

# Build and Test

## Призначення

Цей skill налаштовує відтворювану CMake-збірку та перевіряє C++ проєкт на
основі вже наявних `src/add.h`, `src/add.cpp` і `src/main.cpp`.

## Вхід

Перед початком перевір, що існують:

- `src/add.h`;
- `src/add.cpp`;
- `src/main.cpp`.

Якщо будь-якого файлу немає, зупинись і повідом, який саме вхід відсутній.
Не створюй відсутні вихідні файли в межах цього skill.

## Вихід

Створи або підтвердь такі файли:

- `CMakeLists.txt`;
- `tests/test_basic.cpp`;
- `ci.sh`;
- `ci.bat`.

Не перезаписуй наявні файли. Перед зміною прочитай кожен файл. Якщо
наявний файл відрізняється від очікуваного, повідом шлях і різницю та
зупинись. Повторний запуск має бути ідемпотентним: не додавай дублікати
блоків, targets, тестів або команд.

## Вимоги до `CMakeLists.txt`

Файл повинен:

1. містити `cmake_minimum_required(VERSION 3.14)`;
2. оголосити C++ проєкт і вимагати стандарт C++17;
3. додати бібліотеку `add_lib` з `src/add.cpp`;
4. створити виконуваний файл `hello` з `src/main.cpp`;
5. зв'язати `hello` з `add_lib`;
6. завантажити GoogleTest через `FetchContent`;
7. викликати `enable_testing()`;
8. створити тестовий executable з `tests/test_basic.cpp`;
9. зв'язати тест із `add_lib` і GoogleTest;
10. підключити `gtest_discover_tests` з модуля `GoogleTest`.

Для FetchContent використовуй зафіксовану версію GoogleTest, а не
невизначену гілку. Не додавай дубльовані `FetchContent_Declare`,
`add_library`, `add_executable`, `enable_testing` або test registration.

## Вимоги до `tests/test_basic.cpp`

Створи тест `BasicAddition`, який підключає `add.h` і перевіряє, що, як
мінімум, `add(2, 3)` дорівнює `5`. Назва тесту повинна бути доступна CTest
як `BasicAddition` після `gtest_discover_tests`.

## Вимоги до `ci.sh`

`ci.sh` — Bash-скрипт із таким першим рядком і режимом помилок:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Скрипт повинен послідовно виконувати:

1. configure: `cmake -S . -B build`;
2. build: `cmake --build build --config Release`;
3. test: `ctest --test-dir build --output-on-failure -C Release`;
4. створити `dist/`;
5. скопіювати виконуваний файл `hello` у `dist/`.

На Linux і macOS виконуваний файл очікується в `build/hello`. Якщо
платформа або generator використовує інший шлях, знайди фактичний файл
після успішної збірки та зупинись із чіткою помилкою, якщо його не знайдено.
Після створення зроби скрипт виконуваним:

```bash
git update-index --chmod=+x ci.sh
```

Не приховуй помилки команд і не копіюй неіснуючий файл.

## Вимоги до `ci.bat`

`ci.bat` повинен послідовно виконувати configure, build, CTest і копіювання
виконуваного файлу до `dist/`. На Windows стандартний шлях до executable —
`build\Release\hello.exe`.

Після **кожної** команди перевіряй `%errorlevel%`. При ненульовому коді
негайно виводь повідомлення про помилку та заверши скрипт із ненульовим
кодом. Не використовуй конструкції, які можуть продовжити виконання після
помилки. Перед копіюванням створюй `dist\`.

## Процедура

1. Перевір вхідні source-файли та стан наявних вихідних файлів.
2. Створи `CMakeLists.txt`, `tests/test_basic.cpp`, `ci.sh` і `ci.bat` лише
   за відсутності або після явного погодження відмінностей користувачем.
3. Виконай configure і build.
4. Виконай CTest та переконайся, що `BasicAddition` має статус passed.
5. Переконайся, що існує виконуваний `hello`, враховуючи різні шляхи:
   `build/hello` на Linux/macOS і `build/Release/hello.exe` на Windows.
6. Перевір копіювання до `dist/` і режим виконання `ci.sh`.
7. Покажи diff і список змінених файлів перед завершенням.

Цей skill є обов'язковим етапом `/init`, а не лише описом перевірки. Якщо
будь-який із чотирьох вихідних файлів відсутній, його потрібно створити до
завершення етапу. Якщо source-файли відсутні, спочатку зупинись і передай
помилку `create-project`, не оголошуючи `/init` успішним.

## Перевірки успіху

Роботу можна вважати успішною лише якщо:

- `cmake` configure завершується без помилок;
- build завершується без помилок;
- CTest показує `BasicAddition` як passed;
- існує виконуваний файл `hello`;
- `ci.sh` має executable-біт;
- `ci.bat` повертає ненульовий код після помилки будь-якої команди.

## Типові помилки

- **Не знайдено компілятор.** Зупинись, покажи помилку configure і не
  вважай роботу успішною.
- **Неправильний шлях до executable.** На Windows перевір
  `build/Release/hello.exe`, а на Linux/macOS — `build/hello`.
- **Дубльовані блоки CMake.** Не додавай повторно існуючі targets, тести або
  FetchContent-блоки; порівняй файл перед редагуванням.

## Приклад

### Вхід

```text
src/add.h
src/add.cpp
src/main.cpp
```

### Очікуваний результат

```text
CMakeLists.txt створено
tests/test_basic.cpp створено
ci.sh створено та позначено executable
ci.bat створено
cmake configure: success
build: success
BasicAddition: passed
hello: знайдено
```
