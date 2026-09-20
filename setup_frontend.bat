@echo off
cd /d "%~dp0frontend"
echo Setting up frontend...

call flutter pub get

echo.
echo Frontend setup complete!
pause
