#!/usr/bin/env bash
set -euo pipefail

cmake -S . -B build
cmake --build build --config Release
ctest --test-dir build --output-on-failure -C Release

mkdir -p dist

executable="build/hello"
if [[ ! -x "$executable" ]]; then
    echo "Error: executable not found: $executable" >&2
    exit 1
fi

cp "$executable" dist/hello
