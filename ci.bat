@echo off
setlocal

cmake -S . -B build
if errorlevel 1 (
    echo Error: CMake configure failed.
    exit /b 1
)

cmake --build build --config Release
if errorlevel 1 (
    echo Error: build failed.
    exit /b 1
)

ctest --test-dir build --output-on-failure -C Release
if errorlevel 1 (
    echo Error: tests failed.
    exit /b 1
)

if not exist dist mkdir dist
if errorlevel 1 (
    echo Error: could not create dist.
    exit /b 1
)

if not exist build\Release\hello.exe (
    echo Error: executable not found: build\Release\hello.exe
    exit /b 1
)

copy /Y build\Release\hello.exe dist\hello.exe >NUL
if errorlevel 1 (
    echo Error: could not copy executable.
    exit /b 1
)

exit /b 0
