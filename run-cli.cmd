@echo off
setlocal
if not exist "%~dp0win-x64\GalaxyBatteryCheckCLI.exe" (
  echo Executable missing. Extract the complete portable release or build the source with build.cmd.
  pause
  exit /b 1
)
"%~dp0win-x64\GalaxyBatteryCheckCLI.exe" %*
set "cli_result=%errorlevel%"
if "%~1"=="" pause
exit /b %cli_result%
