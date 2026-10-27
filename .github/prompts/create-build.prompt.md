---
description: "Створити CMake-збірку, GoogleTest/CTest і кросплатформні CI-скрипти для C++ проєкту."
agent: build-engineer
---

# Create Build

## Передумови

Перед початком перевір, що в поточному проєкті існують:

- `src/main.cpp`;
- `src/add.h`;
- `src/add.cpp`.

Також переконайся, що поточний каталог є Git-репозиторієм, і прочитай
наявні вихідні файли перед будь-якою зміною.

## Дії

1. Виконай перевірку Git-репозиторію:

   ```text
   git rev-parse --show-toplevel
   ```

2. Перевір наявність усіх вхідних файлів із розділу «Передумови».
3. Виконай усі інструкції зі skill
   [build-and-test](../skills/build-and-test/SKILL.md).
4. Дотримуйся вимог skill до CMake 3.14, C++17, `add_lib`, executable
   `hello`, GoogleTest через FetchContent, CTest, `BasicAddition`, `ci.sh`
   і `ci.bat`.
5. Не перезаписуй наявні вихідні файли. Якщо їхній вміст відрізняється,
   повідом про це та зупинись.
6. Виконай configure, build і CTest відповідно до skill.
7. Перед завершенням покажи список змінених файлів і `git diff`.

Цей prompt вимагає фактичного створення всіх чотирьох вихідних файлів
(`CMakeLists.txt`, `tests/test_basic.cpp`, `ci.sh`, `ci.bat`) через файлові
інструменти. Не замінюй створення файлів описом очікуваного результату.

## Очікувані файли

Після успішного виконання повинні існувати:

- `CMakeLists.txt`;
- `tests/test_basic.cpp`;
- `ci.sh`;
- `ci.bat`.

`ci.sh` має бути executable, а `ci.bat` повинен перевіряти `%errorlevel%`
після кожної команди та повертати ненульовий код при помилці.

## Команди перевірки

Перевір:

```text
git rev-parse --show-toplevel
Test-Path src/main.cpp
Test-Path src/add.h
Test-Path src/add.cpp
Test-Path CMakeLists.txt
Test-Path tests/test_basic.cpp
Test-Path ci.sh
Test-Path ci.bat
cmake -S . -B build
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release
git status --short
git diff -- CMakeLists.txt tests/test_basic.cpp ci.sh ci.bat
```

Переконайся, що CTest показує `BasicAddition` як passed, executable
`hello` існує в `build/hello` на Linux/macOS або
`build\Release\hello.exe` на Windows, а `dist/hello` або відповідний
Windows-файл створений CI-скриптом.

## Повідомлення про помилку

Якщо вхідний файл відсутній, Git-репозиторій не підтверджено, компілятор не
знайдено, configure/build/CTest завершується з помилкою або executable
відсутній:

1. негайно зупинись;
2. покажи команду, код завершення та релевантний вивід;
3. поясни причину;
4. не перезаписуй і не видаляй файли;
5. не повідомляй про успішне завершення.

## Ідемпотентність

Повторний запуск не повинен дублювати блоки в `CMakeLists.txt`, targets,
тести або команди CI. Перед зміною прочитай наявні файли. Якщо файл уже
містить очікуваний вміст, підтвердь його без повторного запису. Якщо файл
існує з іншим вмістом, повідом про відмінність і зупинись згідно з
правилами skill.
