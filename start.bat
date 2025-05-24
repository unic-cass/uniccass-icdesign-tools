@echo off
REM ==============================================
REM UNIC CASS Tools Launcher for Windows
REM ==============================================

REM ---- Basic configuration
setlocal enabledelayedexpansion

set IMAGE_TAG=isaiassh/unic-cass-tools:1.0.0
set PDK=sky130A
set SHARED_DIR=%CD%\shared_xserver
set DISPLAY=host.docker.internal:0
set CONTAINER_NAME=unic-cass-tools

REM ---- Check if VcXsrv is running
tasklist | findstr /i "vcxsrv.exe" >nul
if %errorlevel% neq 0 (
    echo Starting VcXsrv...
    start "" "C:\Program Files\VcXsrv\vcxsrv.exe" :0 -multiwindow -clipboard -primary -wgl
    timeout /t 3 >nul
)

REM ---- Check if the container is already running

docker ps --filter "name=%CONTAINER_NAME%" --filter "status=running" --format "{{.Names}}" | findstr /i "%CONTAINER_NAME%" >nul
if %errorlevel%==0 (
    echo Container %CONTAINER_NAME% is already running.
    echo Attaching to the running container...
    docker exec -it %CONTAINER_NAME% /bin/bash
    goto :eof
)

REM ---- Check if the container exists but is stopped

docker ps -a --filter "name=%CONTAINER_NAME%" --filter "status=exited" --format "{{.Names}}" | findstr /i "%CONTAINER_NAME%" >nul
if %errorlevel%==0 (
    echo Container %CONTAINER_NAME% exists but is stopped.
    echo Starting the container...
    docker start %CONTAINER_NAME%
    docker exec -it %CONTAINER_NAME% /bin/bash
    goto :eof
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

make start
