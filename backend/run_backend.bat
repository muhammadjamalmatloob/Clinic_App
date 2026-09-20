@echo off
setlocal

cd /d "%~dp0"
set "VENV_PYTHON=%~dp0.venv\Scripts\python.exe"

if not exist "%VENV_PYTHON%" (
    echo [1/3] Creating Python virtual environment...
    where py >nul 2>&1
    if not errorlevel 1 (
        py -3.13 -m venv .venv
    ) else (
        python -m venv .venv
    )

    if errorlevel 1 (
        echo Failed to create the virtual environment.
        pause
        exit /b 1
    )
) else (
    echo [1/3] Virtual environment already exists.
)

echo [2/3] Installing backend dependencies...
"%VENV_PYTHON%" -m pip install -r requirements.txt
if errorlevel 1 (
    echo Failed to install backend dependencies.
    pause
    exit /b 1
)

echo [3/3] Starting Clinic API at http://127.0.0.1:8000 ...
"%VENV_PYTHON%" -m uvicorn app.main:app --reload

endlocal
