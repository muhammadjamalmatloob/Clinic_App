@echo off
cd /d "%~dp0backend"
echo Starting backend server...

call .venv\Scripts\activate.bat
uvicorn app.main:app --reload
