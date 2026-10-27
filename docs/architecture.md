# Архітектура AI-агента

## 1. Які проблеми вирішує агент

Агент автоматизує створення та перевірку кросплатформного C++ проєкту
Hello World. Він вирішує такі проблеми:

- створення однакової початкової структури проєкту;
- налаштування CMake для C++17;
- підключення GoogleTest і CTest;
- запуск юніт-тесту `BasicAddition`;
- підготовка скриптів збірки для Linux/macOS і Windows;
- створення GitHub Actions CI для трьох операційних систем;
- контроль ідемпотентності, щоб повторний запуск не дублював вміст;
- перевірка структури, збірки, тестів, CI та правил `.gitignore`.

Агент також зупиняється при помилках і не оголошує роботу успішною без
успішного проходження фінальної перевірки.

## 2. Skills та їх відповідальність

Проєкт використовує три skills:

- **`project-scaffold`** — створює початкову структуру C++ проєкту:
  `src/main.cpp`, `src/add.h`, `src/add.cpp`, а також порожні каталоги
  `tests/` і `docs/`;
- **`build-and-test`** — створює `CMakeLists.txt`, тест
  `tests/test_basic.cpp`, скрипти `ci.sh` і `ci.bat`, а також перевіряє
  configure, build і CTest;
- **`github-actions`** — створює `.github/workflows/ci.yml` з matrix для
  Ubuntu, Windows і macOS, запускає відповідний CI-скрипт і завантажує
  артефакт із `dist/`.

Skills завантажуються агентом за потреби та містять покрокові правила
виконання, перевірки й обробки типових помилок.

## 3. Доступні commands

Користувач може виконувати такі commands:

- **`git-init`** — перевіряє Git-репозиторій і створює або доповнює
  `.gitignore` без дублів;
- **`create-project`** — запускає `project-scaffold` з
  `language=C++` і `project_name=hello`;
- **`create-build`** — запускає `build-and-test` для створення CMake,
  GoogleTest/CTest і CI-скриптів;
- **`create-actions`** — запускає `github-actions` для створення workflow;
- **`check`** — виконує читальну комплексну перевірку структури, збірки,
  тестів, CI та Git-ignore правил;
- **`init`** — оркеструє всі попередні commands у визначеному порядку та
  завершується успішно лише після `check: PASSED`.

## 4. Дані між етапами

Потік даних проходить послідовно:

```text
project_name=hello
        |
        v
src/main.cpp, src/add.h, src/add.cpp
        |
        v
CMakeLists.txt + tests/test_basic.cpp
        |
        v
ci.sh / ci.bat
        |
        v
.github/workflows/ci.yml
```

Деталі потоку:

1. `project_name=hello` визначає назву проєкту та виконуваного файлу.
2. `project-scaffold` створює вихідний код у `src/`; `main.cpp` використовує
   функцію `add`.
3. `build-and-test` підключає вихідні файли до `add_lib`, executable
   `hello` та GoogleTest у `CMakeLists.txt`.
4. `ci.sh` і `ci.bat` виконують configure, build, CTest і копіюють executable
   до `dist/`.
5. `github-actions` створює workflow, який на кожній ОС запускає лише
   відповідний скрипт і завантажує вміст `dist/`.

## 5. Обробка помилок оркестратором `init`

`init` виконує етапи строго послідовно:

1. `git-init`;
2. `create-project`;
3. `create-build`;
4. `create-actions`;
5. `check`.

Після кожного етапу оркестратор перевіряє очікуваний результат і записує
статус `PASS` або `FAIL`. Якщо будь-який етап завершується помилкою,
оркестратор:

- негайно зупиняється;
- не запускає наступні етапи;
- показує номер і назву кроку;
- повідомляє причину, команду, код завершення та релевантний вивід;
- вказує, що потрібно виправити;
- не оголошує роботу успішною.

Фінальний статус може бути `PASSED` лише тоді, коли всі кроки пройшли, а
`check` повернув `PASSED`. Інакше результат — `FAILED`.

## 6. Відповідність файлів ролям

| Роль | Каталог або файл | Відповідальність |
|---|---|---|
| Agent | `.github/agents/build-engineer.agent.md` | Роль build engineer, правила роботи, skills і commands |
| Skills | `.github/skills/project-scaffold/SKILL.md` | Scaffold вихідного C++ коду |
| Skills | `.github/skills/build-and-test/SKILL.md` | CMake, GoogleTest/CTest і CI-скрипти |
| Skills | `.github/skills/github-actions/SKILL.md` | GitHub Actions workflow |
| Commands | `.github/prompts/git-init.prompt.md` | Ініціалізація Git і `.gitignore` |
| Commands | `.github/prompts/create-project.prompt.md` | Запуск scaffold проєкту |
| Commands | `.github/prompts/create-build.prompt.md` | Створення build/test файлів |
| Commands | `.github/prompts/create-actions.prompt.md` | Створення CI workflow |
| Commands | `.github/prompts/check.prompt.md` | Read-only перевірка результату |
| Commands | `.github/prompts/init.prompt.md` | Послідовна оркестрація всіх етапів |

## 7. Формат VS Code Copilot

У проєкті використано формат VS Code Copilot:

- **custom agents** — `.agent.md` для спеціалізованої ролі агента;
- **prompt files** — `.prompt.md` для доступних користувацьких commands;
- **agent skills** — `SKILL.md` для повторюваних спеціалізованих workflow.

Ці файли розташовані в `.github/` і є частиною конфігурації агента,
спільної для репозиторію.
