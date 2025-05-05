@echo off
REM ==============================================
REM USM VLSI Tools Launcher for Windows
REM ==============================================

REM ---- Basic configuration
setlocal enabledelayedexpansion

set IMAGE_TAG=isaiassh/unic-cass-tools:0.1
set PDK=sky130A
set SHARED_DIR=%CD%\shared_xserver
set DISPLAY=host.docker.internal:0
set CONTAINER_NAME=usm-vlsi-tools

REM ---- Check if VcXsrv is running
tasklist | findstr /i "vcxsrv.exe" >nul
if %errorlevel% neq 0 (
    echo Starting VcXsrv...
    start "" "C:\Program Files\VcXsrv\vcxsrv.exe" :0 -multiwindow -clipboard -primary -wgl
    timeout /t 3 >nul
)

REM ---- Launch Docker container
echo Launching Docker container...
docker run -it --rm ^
  --mount type=bind,source="%SHARED_DIR%",target=/home/designer/shared ^
  --user 1000:1000 ^
  -e SHELL=/bin/bash ^
  -e PDK=%PDK% ^
  -e DISPLAY=%DISPLAY% ^
  -e LIBGL_ALWAYS_INDIRECT=1 ^
  -e XDG_RUNTIME_DIR ^
  -e PULSE_SERVER ^
  -p 8888:8888 ^
  --name %CONTAINER_NAME% ^
  %IMAGE_TAG%

endlocal
pause
