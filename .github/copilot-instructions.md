# Project Guidelines

## Repository Scope

This repository contains a VS Code Copilot build-engineer agent and its
prompt/skill definitions. The agent scaffolds a separate, minimal C++17
Hello World project named `hello`; the generated C++ sources and build files
are not currently checked into this repository.

The primary user entry point is the `build-engineer` custom agent followed by
`/init`. The orchestration is intentionally sequential:

1. `git-init` establishes repository ignore rules.
2. `create-project` creates `src/main.cpp`, `src/add.h`, and `src/add.cpp`.
3. `create-build` adds CMake, GoogleTest/CTest, and platform CI scripts.
4. `create-actions` adds the GitHub Actions workflow.
5. `check` performs the final read-only verification.

See [README.md](../README.md) for user-facing setup and command names, and
[docs/architecture.md](../docs/architecture.md) for the artifact flow and
responsibilities of each agent component.

## Architecture

- `.github/agents/build-engineer.agent.md` defines the role, safety rules,
  supported workflow, and success criteria.
- `.github/skills/` contains the reusable procedures: `project-scaffold`
  owns the source scaffold, `build-and-test` owns CMake/GoogleTest/CTest and
  `ci.sh`/`ci.bat`, and `github-actions` owns `.github/workflows/ci.yml`.
- `.github/prompts/` exposes the commands and delegates their implementation
  to the corresponding skill. `init.prompt.md` is the only orchestrator and
  must not reorder or skip its five stages.
- In the generated project, `add_lib` is shared by the `hello` executable and
  `BasicAddition` test. The CI workflow only dispatches to `ci.sh` on Unix
  runners or `ci.bat` on Windows; configure, build, test, and packaging logic
  belongs in those scripts.

## Build and Test

The checkout now contains the generated C++ project. Run these commands from
the repository root.

Configure and build:

```text
cmake -S . -B build
cmake --build build --config Release
```

Run the complete CTest suite:

```text
ctest --test-dir build -C Release --output-on-failure
```

Run only the addition test:

```text
ctest --test-dir build -C Release -R BasicAddition --output-on-failure
```

The expected executable is `build/hello` on Linux/macOS and
`build\Release\hello.exe` on Windows. The generated `ci.sh` and `ci.bat`
perform configure, build, CTest, and copy the executable to `dist/`; use
those scripts when validating the platform-specific CI path.

Validate the workflow YAML with PyYAML, or use `actionlint` if PyYAML is not
available:

```text
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"
```

No source-code lint or formatting command is defined in this repository.

## Conventions

- Treat existing files as authoritative. Read them before editing; do not
  overwrite a differing file, duplicate blocks, or silently repair conflicts.
  Repeated commands should be idempotent.
- Preserve the generated project contract: C++17, CMake minimum 3.14,
  `add_lib`, executable `hello`, GoogleTest fetched at a pinned version,
  `enable_testing()`, `gtest_discover_tests`, and the test name
  `BasicAddition` with `add(2, 3) == 5`.
- Keep `.github/workflows/ci.yml` as orchestration only. Its Unix and Windows
  `run` steps may invoke only `./ci.sh` and `ci.bat`, respectively; do not put
  direct CMake/CTest commands or build logic in the workflow.
- Keep `ci.sh` fail-fast with `set -euo pipefail`; `ci.bat` must check
  `%errorlevel%` after every command and exit nonzero on failure.
- Preserve cross-platform paths and executable locations. `ci.sh` must have
  its executable bit, and generated artifacts must go to `dist/`.
- Keep generated outputs out of Git. `.gitignore` must include `build/` and
  `dist/` (the `git-init` prompt also defines the other build, environment,
  and key-file patterns).
- On errors, report the exact command, exit code, and relevant output, then
  stop the dependent workflow. Never claim success unless the final
  `check` result is `PASSED`.
- Do not add secrets, tokens, passwords, or unrelated files. The check prompt
  is read-only apart from its temporary ignored `build/` directory.
