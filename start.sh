#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "=========================================================="
echo "    Starting Keith Capital Loan Management System"
echo "=========================================================="

# Free up ports 8001 and 5173 if occupied by previous runs
fuser -k 8001/tcp 2>/dev/null || true
fuser -k 5173/tcp 2>/dev/null || true
sleep 1

# Detect Python binary
if [ -f "$DIR/backend/.venv/bin/python" ]; then
    PYTHON_BIN="$DIR/backend/.venv/bin/python"
elif [ -f "$DIR/venv/bin/python" ]; then
    PYTHON_BIN="$DIR/venv/bin/python"
else
    PYTHON_BIN="python3"
fi

# 1. Start Python FastAPI Backend on port 8001
echo "[1/2] Starting Python FastAPI Backend on http://localhost:8001..."
cd "$DIR/backend"
"$PYTHON_BIN" -m uvicorn main:app --host 0.0.0.0 --port 8001 &
BACKEND_PID=$!

sleep 2

# 2. Start React Frontend on port 5173
echo "[2/2] Starting React Frontend on http://localhost:5173..."
cd "$DIR/frontend"
npm run dev -- --host 0.0.0.0 &
FRONTEND_PID=$!

echo ""
echo "=========================================================="
echo " Loan Management System is LIVE and accessible at:"
echo "   Frontend Web UI: http://localhost:5173"
echo "   Backend API Docs: http://localhost:8001/docs"
echo ""
echo " Default Admin Login Credentials:"
echo "   Username: admin"
echo "   Password: admin123"
echo "   PIN Code: 1234"
echo "=========================================================="
echo "Press Ctrl+C to stop both servers."

trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true; exit" INT TERM
wait
