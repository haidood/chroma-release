@echo off
title Chroma Audio Suite - CI/CD Installer & Updater
echo ================================================================
echo   CHROMA AUDIO SUITE // CONNECTING TO CI/CD APP UPDATER...
echo ================================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $t = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds(); irm \"https://raw.githubusercontent.com/haidood/chroma-release/main/update.ps1?t=$t\" | iex"
if errorlevel 1 (
    echo.
    echo [!] Unable to reach CI/CD updater. Check internet connection or run in PowerShell:
    echo     irm https://raw.githubusercontent.com/haidood/chroma-release/main/update.ps1 ^| iex
    pause
)
