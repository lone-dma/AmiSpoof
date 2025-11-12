@ECHO OFF
ECHO - Checking for admin rights...
NET SESSION >nul 2>&1
if %errorlevel% NEQ 0 (
    ECHO ERROR: This script requires administrative privileges. Please run as administrator.
    PAUSE
    EXIT 1
)
CD /D "%~dp0"
ECHO - Starting Script...
POWERSHELL -NoProfile -ExecutionPolicy Bypass -File "Scripts\Get-HardwareIds.ps1"
ECHO - Done
PAUSE