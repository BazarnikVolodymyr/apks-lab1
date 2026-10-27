1. привіт

2. Я роблю лабораторну роботу: AI-агент для VS Code Copilot, який у репозиторії
генерує кросплатформний C++ проєкт Hello World (CMake + GoogleTest/CTest) і CI
на GitHub Actions (Windows, Linux, macOS).
Зараз я в гілці develop і створюю ТІЛЬКИ інструкції агента (manifest, skills,
prompts-команди, документацію). Не створюй src/, tests/, CMakeLists.txt, ci.yml, ci.sh, ci.bat:
їх згенерує агент пізніше в гілці feature.
Файли створюй по одному, коли я попрошу. Мова інструкцій: українська,
імена файлів і команд: англійською.

3. Створи файл .github/agents/build-engineer.agent.md з YAML frontmatter
(description, tools) і розділами:
1. Роль: build engineer для C++/CMake проєктів.
2. Область відповідальності: scaffold, збірка, юніт-тести, CI.
3. Доступні skills: project-scaffold, build-and-test, github-actions (з шляхами).
4. Доступні commands: git-init, create-project, create-build, create-actions,
   check, init (з коротким описом).
5. Правила роботи з файлами: ніколи не перезаписувати наявні файли без
   перевірки; ідемпотентність (повторний запуск не дублює вміст); показувати
   diff/список змін перед завершенням.
6. Заборонені дії: видалення файлів, git push --force, переписування історії,
   зміна захисту гілок, робота з секретами/токенами, публікація даних.
7. Порядок роботи.
8. Критерії успішного завершення: існує виконуваний файл hello; тест BasicAddition проходить; ci.yml містить ubuntu/windows/macos і лише викликає ci.sh/ci.bat; build/ і dist/ не під Git; check завершується без помилок.
9. Поведінка при помилці: зупинитись, показати причину, не вважати роботу успішною.

4. Створи .github/skills/project-scaffold/SKILL.md.
Frontmatter: name: project-scaffold, description (коли застосовувати).
Вхід: language=C++, project_name=hello.
Вихід: src/main.cpp (друкує "Hello, World!" і використовує add), src/add.h,
src/add.cpp (int add(int,int)), порожні каталоги tests/ та docs/, README (якщо немає).
Правила: не перезаписувати наявні файли; якщо файл існує і відрізняється, повідомити.
Перевірки: src/main.cpp існує; вказана команда запуску (./build/hello або
build\Release\hello.exe). Типова помилка: файл вже існує з іншим вмістом.
Додай приклад входу та очікуваного результату.

5. Створи .github/skills/build-and-test/SKILL.md.
Frontmatter: name: build-and-test, description (коли застосовувати).
Вхід: наявні src/add.h, src/add.cpp, src/main.cpp.
Вихід: CMakeLists.txt (cmake_minimum_required 3.14, C++17, бібліотека add_lib,
виконуваний файл hello, GoogleTest через FetchContent, enable_testing,
gtest_discover_tests), tests/test_basic.cpp з тестом BasicAddition, скрипти
ci.sh (bash, set -euo pipefail) і ci.bat, які виконують configure, build, ctest
і копіюють hello у dist/. ci.sh має бути виконуваним (git update-index --chmod=+x).
ci.bat після кожної команди перевіряє %errorlevel% і завершується з ненульовим
кодом при помилці.
Перевірки: cmake configure/build проходять, ctest показує BasicAddition passed,
існує виконуваний hello. Типові помилки: не знайдено компілятор; на Windows hello
лежить у build/Release; на Linux/macOS у build/. Ідемпотентність: не дублювати
блоки в CMakeLists.txt.
Додай приклад входу та очікуваного результату.

6. Створи .github/skills/github-actions/SKILL.md.
Frontmatter: name: github-actions, description (коли застосовувати).
Вихід: .github/workflows/ci.yml: тригери push і pull_request на develop та master;
одна job з matrix os: [ubuntu-latest, windows-latest, macos-latest], fail-fast: false;
кроки: checkout, запуск ./ci.sh (не Windows, shell: bash) або ci.bat (Windows, shell: cmd),
upload-artifact з dist/ (actions/upload-artifact@v4, унікальне ім'я hello-${{ matrix.os }},
if-no-files-found: error). ВАЖЛИВО: у кроках run файлу ci.yml НЕ має бути команд cmake/ctest напряму,
лише запуск ci.sh/ci.bat. Без секретів.
Перевірки: YAML валідний (python -c "import yaml..." або actionlint, якщо є);
у файлі є три ОС; немає слів token/password/secret.
Типова помилка: ci.sh без прав на виконання.
Додай приклад входу та очікуваного результату.

7. Створи .github/prompts/git-init.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови, Дії, Очікувані файли, Команди перевірки, Повідомлення про помилку, Ідемпотентність.
Дії: перевірити, що поточний каталог є git-репозиторієм (git rev-parse); створити .gitignore або ДОПОВНИТИ його без дублів рядками build/, dist/, out/, .vs/, *.exe, *.obj, *.o, CMakeCache.txt, CMakeFiles/, .env, *.pem, *.key; показати git status.
Нічого не видаляти.

8. Створи .github/prompts/create-project.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (git-репозиторій), Дії (виконати інструкції зі skill .github/skills/project-scaffold/SKILL.md з language=C++, project_name=hello), Очікувані файли (src/main.cpp, src/add.h, src/add.cpp), Команди перевірки (src/main.cpp існує), Повідомлення про помилку, Ідемпотентність.

9. Створи .github/prompts/create-build.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (є src/main.cpp, src/add.h, src/add.cpp), Дії (виконати skill .github/skills/build-and-test/SKILL.md), Очікувані файли (CMakeLists.txt, tests/test_basic.cpp, ci.sh, ci.bat), Команди перевірки, Повідомлення про помилку, Ідемпотентність.

10. Створи .github/prompts/create-actions.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (є ci.sh і ci.bat), Дії (виконати skill .github/skills/github-actions/SKILL.md), Очікувані файли (.github/workflows/ci.yml), Команди перевірки (валідність YAML, три ОС, виклик лише ci.sh/ci.bat), Повідомлення про помилку, Ідемпотентність.

11. Створи .github/prompts/check.prompt.md.
Frontmatter: description, agent: build-engineer.
Режим: ТІЛЬКИ ЧИТАННЯ. Не створювати і не змінювати файли проєкту (тимчасові каталоги build/ дозволені, вони в .gitignore).
Виконати перевірки і вивести таблицю PASS/FAIL:
1. Існують .github/agents/build-engineer.agent.md і три SKILL.md.
2. Кожен skill має розділи Вхід, Вихід, Перевірки.
3. Існують src/main.cpp, src/add.h, src/add.cpp, tests/test_basic.cpp, CMakeLists.txt, ci.sh, ci.bat.
4. cmake -S . -B build && cmake --build build --config Release проходять.
5. ctest --test-dir build -C Release --output-on-failure: BasicAddition passed.
6. Існує виконуваний файл hello.
7. ci.yml: валідний YAML, містить ubuntu-latest, windows-latest, macos-latest, у кроках run викликає лише ci.sh/ci.bat (без прямих команд cmake/ctest).
8. git ls-files не містить build/, dist/, .env, *.key, *.pem.
9. .gitignore містить build/ і dist/.
Якщо є хоча б один FAIL: вказати який саме і завершити зі статусом FAILED. Якщо все PASS: статус PASSED.
Додай розділи: Передумови, Повідомлення про помилку.

12. Створи .github/prompts/init.prompt.md.
Frontmatter: description, agent: build-engineer.
Ти оркестратор. Виконуй кроки СТРОГО по порядку, читаючи і виконуючи інструкції з файлів:
1. .github/prompts/git-init.prompt.md
2. .github/prompts/create-project.prompt.md
3. .github/prompts/create-build.prompt.md
4. .github/prompts/create-actions.prompt.md
5. .github/prompts/check.prompt.md
Після кожного кроку перевіряй результат. Якщо крок завершився помилкою: ЗУПИНИСЬ, не виконуй наступні, виведи звіт (який крок, причина, що виправити). Не оголошуй успіх без PASSED від check.
Повторний запуск не повинен руйнувати чи дублювати наявні файли.
У кінці виведи таблицю: крок, статус, створені/змінені файли.
Додай розділи: Передумови, Очікувані файли, Повідомлення про помилку.

13. Онови README.md (зараз там лише назва репозиторія, збережи її): ПІП ,Базарник Володимир-Григорій Романович, група КІ-404, варіант 1 (C++, CMake, GoogleTest/CTest), короткий опис проєкту, розділ "Запуск агента": відкрити папку у VS Code, відкрити Copilot Chat, вибрати агента build-engineer, виконати /init. Додай список commands. Залиш плейсхолдери для ПІП і групи.

14. Створи docs/architecture.md з розділами:
1. Які проблеми вирішує агент.
2. Які skills використовує і за що вони відповідають.
3. Які commands доступні користувачу.
4. Які дані передаються між етапами (project_name -> src/ -> CMakeLists.txt -> ci.sh/ci.bat -> ci.yml).
5. Як оркестратор init обробляє помилки.
6. Таблиця відповідності файлів ролям: agent -> .github/agents/, skills -> .github/skills/, commands -> .github/prompts/.
7. Примітка, що використано формат VS Code Copilot (custom agents, prompt files, agent skills).
