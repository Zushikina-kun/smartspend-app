@echo off
setlocal EnableExtensions
title Install Pillow - Kiro Image Tool v4

echo ================================================================
echo              KIRO IMAGE TOOL - INSTALL PILLOW (v4)
echo ================================================================
echo.
echo Looking for a working Python interpreter...
echo (This checks each candidate actually runs, instead of
echo  trusting the "py" launcher's default, which can be broken.)
echo.

set "PYTHON="

call :try_python python
if defined PYTHON goto FOUND

call :try_python "py -3"
if defined PYTHON goto FOUND

call :try_python "py -3.13"
if defined PYTHON goto FOUND

call :try_python "py -3.12"
if defined PYTHON goto FOUND

call :try_python "py -3.11"
if defined PYTHON goto FOUND

call :try_python py
if defined PYTHON goto FOUND

echo ERROR: No working Python interpreter could be found.
echo.
echo This usually means:
echo   - Python is not installed, OR
echo   - The "py" launcher points at a broken/missing interpreter
echo     (e.g. a Python 3.14 "free-threaded" build: python3.14t.exe)
echo.
echo Fix options:
echo   1. Run:  py -0p
echo      This lists every Python the launcher knows about and its
echo      real file path. Check the path actually exists.
echo   2. Reinstall Python from https://www.python.org/downloads/
echo      During setup, make sure "Add python.exe to PATH" is checked,
echo      and do NOT select the "free-threaded" experimental option
echo      unless you specifically need it.
echo.
pause
exit /b 1

:FOUND
echo Using interpreter: %PYTHON%
for /f "delims=" %%V in ('%PYTHON% -c "import sys; print(sys.executable)"') do echo Path: %%V
echo.
echo Installing/upgrading Pillow...
%PYTHON% -m pip install --user --upgrade Pillow

if errorlevel 1 (
    echo.
    echo ERROR: Pillow installation failed with the interpreter above.
    echo Try running that same command manually to see the full error.
    echo.
    pause
    exit /b 1
)

echo.
echo Pillow installed successfully with: %PYTHON%
echo You can now run Kiro_Image_Tool.bat.
echo.
pause
exit /b 0

:try_python
%~1 -c "import sys" >nul 2>&1
if not errorlevel 1 set "PYTHON=%~1"
goto :eof
