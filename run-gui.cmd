@echo off
setlocal
if not exist "%~dp0win-x64\GalaxyBatteryCheck.exe" (
  echo Executable missing. Extract the complete portable release or build the source with build.cmd.
  pause
  exit /b 1
)
start "" "%~dp0win-x64\GalaxyBatteryCheck.exe"
