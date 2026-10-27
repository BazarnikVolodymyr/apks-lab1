# apks-lab1

## Дані лабораторної роботи

- **ПІП:** `[Базарник Володимир-Григорій Романович]`
- **Група:** `[КІ-404]`
- **Варіант:** 1 — C++, CMake, GoogleTest/CTest

## Короткий опис проєкту

Цей проєкт містить конфігурацію AI-агента для VS Code Copilot, який
генерує кросплатформний C++ проєкт Hello World. Агент створює scaffold,
налаштовує збірку CMake, юніт-тест `BasicAddition` через GoogleTest/CTest і
GitHub Actions CI для Windows, Linux та macOS.

## Запуск агента

1. Відкрити папку проєкту у VS Code.
2. Відкрити Copilot Chat.
3. Вибрати агента `build-engineer`.
4. Виконати команду `/init`.

## Доступні commands

- `git-init` — ініціалізувати Git-правила та доповнити `.gitignore`.
- `create-project` — створити scaffold C++/CMake Hello World з функцією `add`.
- `create-build` — створити CMake-збірку, GoogleTest/CTest і CI-скрипти.
- `create-actions` — створити кросплатформний GitHub Actions workflow.
- `check` — перевірити структуру, збірку, тести, CI та Git-ignore правила.
- `init` — послідовно виконати всі кроки ініціалізації та фінальну перевірку.