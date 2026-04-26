@echo off
REM Start the SurvivAI Model API server (Windows)

echo Starting SurvivAI Model API...
cd /d "%~dp0"
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
