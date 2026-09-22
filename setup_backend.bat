@echo off
cd /d "%~dp0backend"
echo Setting up backend...

if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

echo Installing dependencies...
call .venv\Scripts\activate.bat
pip install -r requirements.txt

echo.
echo Backend setup complete!
pause
