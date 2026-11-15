@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CreateShortcut.ps1" %*
set "shortcut_result=%errorlevel%"
pause
exit /b %shortcut_result%
