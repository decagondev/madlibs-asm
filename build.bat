@echo off
nasm -f win64 madlibs.asm -o madlibs.obj
if %errorlevel% neq 0 (
    echo Assembly failed
    exit /b %errorlevel%
)
link /subsystem:windows madlibs.obj kernel32.lib user32.lib gdi32.lib
if %errorlevel% neq 0 (
    echo Linking failed
    exit /b %errorlevel%
)
echo Build successful