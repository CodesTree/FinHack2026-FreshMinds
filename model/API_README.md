# SurvivAI Model API

Backend API for financial survival predictions. Exposes the ML model as REST endpoints for direct integration.

## Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements-api.txt
```

### 2. Start the Server

**Windows:**
```bash
start_api.bat
```

**Linux/Mac:**
```bash
chmod +x start_api.sh
./start_api.sh
```

**Or directly:**
```bash
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at: `http://localhost:8000`

### 3. View API Documentation

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### `GET /health`
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-04-26T10:30:00",
  "data_loaded": true,
  "total_transactions": 1234,
  "unique_users": 2
}
```

### `POST /predict`
Generate complete prediction for a user.

**Request:**
```json
{
  "user_id": "USR_SITI_001",
  "prediction_date": "2026-04-20",
  "wallet_balance": 560.00,
  "monthly_income": 2200.00
}
```

**Response:**
```json
{
  "user_id": "USR_SITI_001",
  "prediction_date": "2026-04-20",
  "history_days_used": 90,
  "spending_prediction": {
    "prediction_date": "2026-04-20",
    "model_used": "hybrid_personalised_90d_forecast",
    "predicted_daily_need_spend": 45.50,
    "predicted_daily_want_spend": 25.30,
    "predicted_daily_total_spend": 70.80,
    "predicted_subcategories": [...]
  },
  "survival_score": {
    "wallet_balance": 560.00,
    "survival_days": 7.9,
    "emergency_survival_days": 12.3,
    "potential_days_saved": 4.4,
    "daily_total_burn_rate": 70.80,
    "daily_need_burn_rate": 45.50,
    "color_band": "red"
  },
  "budget_plan": {
    "monthly_income": 2200.00,
    "need_budget": 1320.00,
    "want_budget": 660.00,
    "save_goal": 220.00,
    "safe_spend_today": 45.00,
    "save_portion_status": "protected",
    ...
  }
}
```

### `GET /users`
List all available users.

**Response:**
```json
{
  "users": ["USR_SITI_001", "USR_BRANDON_001"],
  "count": 2
}
```

### `POST /reload-data`
Reload transaction data from disk (useful after data updates).

**Response:**
```json
{
  "status": "success",
  "message": "Transaction data reloaded",
  "total_transactions": 1234,
  "unique_users": 2
}
```

## Integration Examples

### Python Client

```python
import requests

API_URL = "http://localhost:8000"

# Make prediction
response = requests.post(
    f"{API_URL}/predict",
    json={
        "user_id": "USR_SITI_001",
        "wallet_balance": 560.00,
        "monthly_income": 2200.00
    }
)

result = response.json()
print(f"Survival days: {result['survival_score']['survival_days']}")
print(f"Color band: {result['survival_score']['color_band']}")
```

### JavaScript/Node.js Client

```javascript
const API_URL = "http://localhost:8000";

async function getPrediction(userId, walletBalance, monthlyIncome) {
  const response = await fetch(`${API_URL}/predict`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      user_id: userId,
      wallet_balance: walletBalance,
      monthly_income: monthlyIncome
    })
  });
  
  return await response.json();
}

// Usage
const result = await getPrediction("USR_SITI_001", 560.00, 2200.00);
console.log(`Survival days: ${result.survival_score.survival_days}`);
```

### cURL

```bash
curl -X POST "http://localhost:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "USR_SITI_001",
    "wallet_balance": 560.00,
    "monthly_income": 2200.00
  }'
```

### Flutter/Dart Client

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getPrediction(
  String userId,
  double walletBalance,
  double monthlyIncome,
) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'wallet_balance': walletBalance,
      'monthly_income': monthlyIncome,
    }),
  );
  
  return jsonDecode(response.body);
}
```

## Response Fields Explained

### Spending Prediction
- `predicted_daily_need_spend`: Essential spending per day (RM)
- `predicted_daily_want_spend`: Discretionary spending per day (RM)
- `predicted_daily_total_spend`: Total predicted spending per day (RM)
- `predicted_subcategories`: Breakdown by category (groceries, transport, etc.)

### Survival Score
- `survival_days`: Days until wallet depletes at current spending rate
- `emergency_survival_days`: Days if only spending on needs
- `color_band`: Visual indicator (green ≥90 days, yellow ≥30 days, red <30 days)
- `daily_total_burn_rate`: Current daily spending rate
- `daily_need_burn_rate`: Daily spending on essentials only

### Budget Plan
- `need_budget`: 60% of income allocated to needs
- `want_budget`: 30% of income allocated to wants
- `save_goal`: 10% of income to save
- `safe_spend_today`: Maximum safe spending today to protect savings
- `save_portion_status`: "protected", "at_risk", or "touched"
- `projected_month_end_total_spend`: Predicted total spending by month end

## Production Deployment

### Using Gunicorn (Linux/Mac)

```bash
pip install gunicorn
gunicorn api:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Using Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements-api.txt .
RUN pip install --no-cache-dir -r requirements-api.txt

COPY . .

CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t survivai-api .
docker run -p 8000:8000 survivai-api
```

## Error Handling

All endpoints return standard HTTP status codes:
- `200`: Success
- `404`: User not found
- `422`: Invalid request data
- `500`: Server error

Error response format:
```json
{
  "detail": "Error message here"
}
```

## Performance Notes

- Transaction data is cached in memory after first load
- Use `/reload-data` endpoint to refresh cache after data updates
- Average response time: ~50-200ms per prediction
- Supports concurrent requests

## Support

For issues or questions, check the main project documentation or API docs at `/docs`.
