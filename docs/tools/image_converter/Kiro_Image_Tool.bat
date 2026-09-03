@echo off
setlocal EnableExtensions
title Kiro Image Tool v4

echo.
echo ================================================================
echo                    KIRO IMAGE TOOL v4
echo ================================================================
echo.

REM Determine source folder.
if "%~1"=="" (
    set "TARGET=%~dp0"
) else (
    set "TARGET=%~1"
)

REM Strip a trailing backslash. A trailing backslash right before the
REM closing quote escapes the quote for the program being launched,
REM corrupting the path (e.g. ...Screenshots" instead of ...Screenshots).
if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"

echo Target:
echo "%TARGET%"
echo.

echo Looking for a working Python interpreter...
set "PYTHON="

call :try_python python
if defined PYTHON goto PY_FOUND

call :try_python "py -3"
if defined PYTHON goto PY_FOUND

call :try_python "py -3.13"
if defined PYTHON goto PY_FOUND

call :try_python "py -3.12"
if defined PYTHON goto PY_FOUND

call :try_python "py -3.11"
if defined PYTHON goto PY_FOUND

call :try_python py
if defined PYTHON goto PY_FOUND

echo ERROR: No working Python interpreter could be found.
echo.
echo Run install_pillow.bat first - it explains how to diagnose this
echo (likely a broken "py" launcher default pointing at a missing
echo  python3.14t.exe free-threaded build).
echo.
pause
exit /b 1

:PY_FOUND
echo Using interpreter: %PYTHON%
echo.

echo Checking Pillow...
%PYTHON% -c "import PIL; print('Pillow OK - version', PIL.__version__)" >nul 2>&1
if not errorlevel 1 goto RUN

echo Pillow is missing.
echo.
echo Attempting automatic installation...
%PYTHON% -m pip install --user --upgrade Pillow

if errorlevel 1 (
    echo.
    echo ERROR: Pillow installation failed.
    echo Run install_pillow.bat manually or check your internet connection.
    echo.
    pause
    exit /b 1
)

echo.
echo Pillow installed successfully.
echo.

:RUN
echo Starting image processor...
echo.
%PYTHON% "%~dp0kiro_image_tool.py" "%TARGET%"
set "EXITCODE=%ERRORLEVEL%"

echo.
echo Processor exited with code %EXITCODE%.
pause
exit /b %EXITCODE%

:try_python
%~1 -c "import sys" >nul 2>&1
if not errorlevel 1 set "PYTHON=%~1"
goto :eof
