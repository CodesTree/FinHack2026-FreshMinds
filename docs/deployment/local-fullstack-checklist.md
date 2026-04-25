# Local Fullstack Checklist

## 1) Start Backend API

```bash
cd backend/services
python -m pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Verify:
- `GET http://localhost:8000/health` returns `{"status":"ok"}`
- `GET http://localhost:8000/api/survival-score?user_id=user_siti_001` returns JSON

## 2) Start Flutter Frontend

```bash
cd survivai
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

## 3) Verify Linked Flow

- Home screen survival score matches backend payload.
- Emergency banner behavior updates from API-loaded `survivalDays`.
- No crash when backend is offline (provider fallback to mock profile).
