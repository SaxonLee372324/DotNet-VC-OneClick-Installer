@echo off
title DotNet + VC++ OneClick Installer

cd /d %~dp0

:: Force admin privilege
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 (
    echo Requesting administrator privilege...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo =========================================
echo  DotNet + VC++ OneClick Installer
echo =========================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

echo.
echo =========================================
echo Script finished. Press any key to exit.
echo =========================================
pause
