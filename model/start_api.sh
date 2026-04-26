#!/bin/bash
# Start the SurvivAI Model API server

echo "Starting SurvivAI Model API..."
cd "$(dirname "$0")"
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
