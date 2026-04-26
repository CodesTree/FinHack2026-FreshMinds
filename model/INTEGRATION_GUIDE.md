# Backend Integration Guide

This guide shows how to integrate the SurvivAI model into your backend application.

## Architecture Overview

```
┌─────────────────┐      HTTP/REST      ┌──────────────────┐
│  Your Backend   │ ◄─────────────────► │  Model API       │
│  (Flutter/Node/ │                      │  (FastAPI)       │
│   Python/etc)   │                      │  Port 8000       │
└─────────────────┘                      └──────────────────┘
                                                  │
                                                  ▼
                                         ┌──────────────────┐
                                         │  ML Model        │
                                         │  + Data Files    │
                                         └──────────────────┘
```

## Setup Steps

### 1. Install Dependencies

```bash
cd model
pip install -r requirements.txt
```

### 2. Start the API Server

**Development Mode (with auto-reload):**
```bash
uvicorn api:app --reload --host 0.0.0.0 --port 8000
```

**Production Mode:**
```bash
uvicorn api:app --host 0.0.0.0 --port 8000 --workers 4
```

**Using the startup scripts:**
- Windows: `start_api.bat`
- Linux/Mac: `./start_api.sh`

### 3. Verify API is Running

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2026-04-26T10:30:00",
  "data_loaded": true,
  "total_transactions": 1234,
  "unique_users": 2
}
```

### 4. Test with Sample Request

```bash
python test_api.py
```

## Integration Examples

### Flutter/Dart Integration

#### 1. Add HTTP package to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

#### 2. Create API service class:

```dart
// lib/services/survivai_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SurvivAIAPI {
  final String baseUrl;
  
  SurvivAIAPI({this.baseUrl = 'http://localhost:8000'});
  
  Future<Map<String, dynamic>> getPrediction({
    required String userId,
    required double walletBalance,
    required double monthlyIncome,
    String? predictionDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'wallet_balance': walletBalance,
        'monthly_income': monthlyIncome,
        if (predictionDate != null) 'prediction_date': predictionDate,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get prediction: ${response.body}');
    }
  }
  
  Future<List<String>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['users']);
    } else {
      throw Exception('Failed to get users');
    }
  }
  
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

#### 3. Use in your Flutter app:

```dart
// Example usage in a widget
class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final api = SurvivAIAPI(baseUrl: 'http://localhost:8000');
  Map<String, dynamic>? prediction;
  bool isLoading = false;
  
  Future<void> loadPrediction() async {
    setState(() => isLoading = true);
    
    try {
      final result = await api.getPrediction(
        userId: 'USR_SITI_001',
        walletBalance: 560.00,
        monthlyIncome: 2200.00,
      );
      
      setState(() {
        prediction = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error
      print('Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (prediction == null) {
      return Center(
        child: ElevatedButton(
          onPressed: loadPrediction,
          child: Text('Load Prediction'),
        ),
      );
    }
    
    final survival = prediction!['survival_score'];
    final spending = prediction!['spending_prediction'];
    
    return Column(
      children: [
        Text('Survival Days: ${survival['survival_days']}'),
        Text('Color Band: ${survival['color_band']}'),
        Text('Daily Spending: RM ${spending['predicted_daily_total_spend']}'),
        // Add more UI elements
      ],
    );
  }
}
```

### Node.js/Express Integration

#### 1. Install axios:
```bash
npm install axios
```

#### 2. Create API client:

```javascript
// services/survivaiAPI.js
const axios = require('axios');

class SurvivAIAPI {
  constructor(baseUrl = 'http://localhost:8000') {
    this.client = axios.create({
      baseURL: baseUrl,
      headers: { 'Content-Type': 'application/json' }
    });
  }
  
  async getPrediction(userId, walletBalance, monthlyIncome, predictionDate = null) {
    try {
      const response = await this.client.post('/predict', {
        user_id: userId,
        wallet_balance: walletBalance,
        monthly_income: monthlyIncome,
        ...(predictionDate && { prediction_date: predictionDate })
      });
      return response.data;
    } catch (error) {
      throw new Error(`Prediction failed: ${error.response?.data?.detail || error.message}`);
    }
  }
  
  async getUsers() {
    const response = await this.client.get('/users');
    return response.data.users;
  }
  
  async checkHealth() {
    try {
      const response = await this.client.get('/health');
      return response.status === 200;
    } catch {
      return false;
    }
  }
}

module.exports = SurvivAIAPI;
```

#### 3. Use in Express routes:

```javascript
// routes/prediction.js
const express = require('express');
const SurvivAIAPI = require('../services/survivaiAPI');

const router = express.Router();
const api = new SurvivAIAPI();

router.post('/user/:userId/prediction', async (req, res) => {
  try {
    const { userId } = req.params;
    const { walletBalance, monthlyIncome } = req.body;
    
    const prediction = await api.getPrediction(
      userId,
      walletBalance,
      monthlyIncome
    );
    
    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

### Python Backend Integration

```python
# services/survivai_client.py
import requests
from typing import Optional, Dict, Any

class SurvivAIClient:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = requests.Session()
    
    def get_prediction(
        self,
        user_id: str,
        wallet_balance: float,
        monthly_income: float,
        prediction_date: Optional[str] = None
    ) -> Dict[str, Any]:
        """Get prediction for a user."""
        payload = {
            "user_id": user_id,
            "wallet_balance": wallet_balance,
            "monthly_income": monthly_income
        }
        if prediction_date:
            payload["prediction_date"] = prediction_date
        
        response = self.session.post(
            f"{self.base_url}/predict",
            json=payload
        )
        response.raise_for_status()
        return response.json()
    
    def get_users(self) -> list[str]:
        """Get list of available users."""
        response = self.session.get(f"{self.base_url}/users")
        response.raise_for_status()
        return response.json()["users"]
    
    def check_health(self) -> bool:
        """Check if API is healthy."""
        try:
            response = self.session.get(f"{self.base_url}/health")
            return response.status_code == 200
        except:
            return False

# Usage example
client = SurvivAIClient()
prediction = client.get_prediction(
    user_id="USR_SITI_001",
    wallet_balance=560.00,
    monthly_income=2200.00
)
print(f"Survival days: {prediction['survival_score']['survival_days']}")
```

## Deployment Considerations

### 1. Environment Variables

Create a `.env` file:
```env
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=4
DATA_PATH=/path/to/data
```

Update `api.py` to use environment variables:
```python
import os
from dotenv import load_dotenv

load_dotenv()

API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", 8000))
```

### 2. Docker Deployment

Create `Dockerfile`:
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build and run:
```bash
docker build -t survivai-api .
docker run -p 8000:8000 -v $(pwd)/data:/app/data survivai-api
```

### 3. Production with Gunicorn

```bash
pip install gunicorn
gunicorn api:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### 4. Nginx Reverse Proxy

```nginx
server {
    listen 80;
    server_name api.survivai.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Error Handling

Always handle errors gracefully:

```dart
// Flutter example
try {
  final prediction = await api.getPrediction(...);
  // Use prediction
} on http.ClientException {
  // Network error
  showError('Cannot connect to server');
} catch (e) {
  // Other errors
  showError('Prediction failed: $e');
}
```

## Performance Tips

1. **Cache predictions**: Don't call the API for every screen refresh
2. **Batch requests**: If you need multiple predictions, consider adding a batch endpoint
3. **Use connection pooling**: Reuse HTTP clients instead of creating new ones
4. **Set timeouts**: Add reasonable timeouts to prevent hanging requests
5. **Monitor health**: Periodically check `/health` endpoint

## Security Considerations

1. **Authentication**: Add API key or JWT authentication in production
2. **Rate limiting**: Implement rate limiting to prevent abuse
3. **HTTPS**: Always use HTTPS in production
4. **Input validation**: The API validates inputs, but add client-side validation too
5. **CORS**: Configure CORS properly for your frontend domain

## Troubleshooting

### API not responding
```bash
# Check if server is running
curl http://localhost:8000/health

# Check logs
uvicorn api:app --log-level debug
```

### User not found error
```bash
# List available users
curl http://localhost:8000/users
```

### Data not loading
```bash
# Reload data
curl -X POST http://localhost:8000/reload-data
```

## Next Steps

1. Start the API server
2. Run `test_api.py` to verify everything works
3. Integrate into your backend using the examples above
4. Add authentication and security measures
5. Deploy to production

For more details, see `API_README.md`.
