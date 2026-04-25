# SurvivAI Frontend-Backend Link + Alibaba Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the existing Flutter frontend (`survivai/`) to a real backend API, validate full request/response flow locally, and prepare deployable artifacts for Alibaba Cloud (ECS + OSS/CDN) with AWS SageMaker integration hooks.

**Architecture:** Keep frontend as Flutter app and replace `MockDataService` consumption with repository-driven API calls. Build backend in `backend/services` as a FastAPI service with deterministic local logic plus an optional SageMaker client path for production. Deploy backend container to Alibaba ECS and host Flutter web build on OSS/CDN with API Gateway or direct ECS endpoint.

**Tech Stack:** Flutter (Provider, `http`), Python 3.11 (FastAPI, Pydantic, pytest), Docker, Alibaba ECS/OSS/CDN/API Gateway, AWS SageMaker Runtime (invocation only).

---

## Validation Snapshot (Current State)

- Frontend exists and is feature-complete for UI flow under `survivai/lib/**`.
- Frontend is not API-linked yet:
  - `survivai/lib/core/providers/app_provider.dart` reads only `MockDataService`.
  - `survivai/lib/core/services/mock_data_service.dart` is the sole data source.
  - `survivai/pubspec.yaml` does not include `http`.
- Backend implementation is missing:
  - `backend/services/` contains only `__pycache__/`.
  - `backend/backend-scaffold/` has no runnable source files.
- Tooling limitation in this environment:
  - `flutter` command not installed, so runtime validation is blocked until local Flutter SDK is available.

## Scope Check

This plan covers one executable subsystem: **fullstack linkage and deployment readiness** (contract, backend service, frontend integration, local verification, and Alibaba packaging). It intentionally excludes non-critical future work (advanced ML retraining pipelines, production CTOS integration, full infra-as-code automation).

## File Structure

**Backend (`backend/services/`)**
- Create: `backend/services/requirements.txt` (runtime + test dependencies)
- Create: `backend/services/app/main.py` (FastAPI routes)
- Create: `backend/services/app/settings.py` (environment/config)
- Create: `backend/services/app/schemas.py` (request/response contracts)
- Create: `backend/services/app/logic/survival.py` (score computation)
- Create: `backend/services/app/logic/nudges.py` (nudge templates)
- Create: `backend/services/app/clients/sagemaker_client.py` (optional AWS inference client)
- Create: `backend/services/tests/test_api_contracts.py` (contract tests)
- Create: `backend/services/tests/test_logic_survival.py` (domain tests)
- Create: `backend/services/Dockerfile` (ECS deployment image)
- Create: `backend/services/.env.example` (local/prod env template)

**Frontend (`survivai/`)**
- Modify: `survivai/pubspec.yaml` (`http` dependency)
- Create: `survivai/lib/core/config/app_env.dart` (API base URL config)
- Create: `survivai/lib/core/services/api_client.dart` (HTTP wrapper)
- Create: `survivai/lib/core/services/survivai_repository.dart` (typed API methods)
- Modify: `survivai/lib/core/models/user_model.dart` (JSON serialization helpers)
- Modify: `survivai/lib/core/models/transaction_model.dart` (JSON serialization helpers)
- Modify: `survivai/lib/core/models/nudge_model.dart` (JSON serialization helpers)
- Modify: `survivai/lib/core/providers/app_provider.dart` (replace mock reads with async repository flow)
- Create: `survivai/test/core/providers/app_provider_api_test.dart` (provider + API fake tests)

**Deployment/Runbook**
- Create: `docs/deployment/alibaba-fullstack-runbook.md` (ECS + OSS + CDN + env steps)
- Modify: `survivai/README.md` (local run + API env instructions)

### Task 1: Lock API Contracts Before Coding

**Files:**
- Create: `backend/services/app/schemas.py`
- Create: `backend/services/tests/test_api_contracts.py`
- Modify: `survivai/lib/core/models/user_model.dart`
- Modify: `survivai/lib/core/models/transaction_model.dart`
- Modify: `survivai/lib/core/models/nudge_model.dart`

- [ ] **Step 1: Write failing contract test**

```python
# backend/services/tests/test_api_contracts.py
from app.schemas import SurvivalScoreResponse

def test_survival_contract_has_required_fields():
    payload = SurvivalScoreResponse(
        user_id="user_siti_001",
        survival_days=11,
        daily_burn_rate=7.9,
        wallet_balance=87.0,
        trend_7d="declining",
        color_band="red",
        top_discretionary_category="Grab Food",
        top_discretionary_amount_7d=42.0,
    )
    assert payload.color_band == "red"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend/services; pytest tests/test_api_contracts.py -q`  
Expected: FAIL with `ModuleNotFoundError` because `app/schemas.py` does not exist yet.

- [ ] **Step 3: Implement shared backend contracts and frontend JSON mapping**

```python
# backend/services/app/schemas.py
from pydantic import BaseModel
from typing import Literal

class SurvivalScoreResponse(BaseModel):
    user_id: str
    survival_days: int
    daily_burn_rate: float
    wallet_balance: float
    trend_7d: Literal["improving", "stable", "declining"]
    color_band: Literal["green", "amber", "red"]
    top_discretionary_category: str
    top_discretionary_amount_7d: float
```

```dart
// survivai/lib/core/models/user_model.dart (add)
factory UserModel.fromApi(Map<String, dynamic> json) => UserModel(
  id: json['user_id'] as String,
  name: json['name'] as String? ?? 'Siti',
  walletBalance: (json['wallet_balance'] as num).toDouble(),
  survivalDays: json['survival_days'] as int,
  dailyBurnRate: (json['daily_burn_rate'] as num).toDouble(),
  trend: SurvivalTrend.values.byName(json['trend_7d'] as String),
  colorBand: SurvivalBand.values.byName(json['color_band'] as String),
  emergencyModeActive: json['emergency_mode'] as bool? ?? false,
  topDiscretionaryCategory: json['top_discretionary_category'] as String,
  topDiscretionaryAmount: (json['top_discretionary_amount_7d'] as num).toDouble(),
  hasActiveLoan: json['has_active_loan'] as bool? ?? false,
  monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 1800,
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend/services; pytest tests/test_api_contracts.py -q`  
Expected: PASS (`1 passed`).

- [ ] **Step 5: Commit**

```bash
git add backend/services/app/schemas.py backend/services/tests/test_api_contracts.py survivai/lib/core/models/user_model.dart survivai/lib/core/models/transaction_model.dart survivai/lib/core/models/nudge_model.dart
git commit -m "feat: lock frontend-backend contracts with shared schema mapping"
```

### Task 2: Build Minimal Backend API With Deterministic Logic

**Files:**
- Create: `backend/services/requirements.txt`
- Create: `backend/services/app/main.py`
- Create: `backend/services/app/logic/survival.py`
- Create: `backend/services/app/logic/nudges.py`
- Create: `backend/services/tests/test_logic_survival.py`

- [ ] **Step 1: Write failing domain test**

```python
# backend/services/tests/test_logic_survival.py
from app.logic.survival import compute_survival

def test_compute_survival_returns_red_for_low_runway():
    result = compute_survival(wallet_balance=87.0, daily_burn_rate=7.9)
    assert result["survival_days"] == 11
    assert result["color_band"] == "red"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend/services; pytest tests/test_logic_survival.py -q`  
Expected: FAIL because `app/logic/survival.py` is missing.

- [ ] **Step 3: Implement minimal backend and route**

```python
# backend/services/app/logic/survival.py
def compute_survival(wallet_balance: float, daily_burn_rate: float) -> dict:
    survival_days = int(wallet_balance // daily_burn_rate) if daily_burn_rate > 0 else 999
    color_band = "green" if survival_days > 30 else "amber" if survival_days >= 15 else "red"
    return {"survival_days": survival_days, "color_band": color_band}
```

```python
# backend/services/app/main.py
from fastapi import FastAPI
from app.schemas import SurvivalScoreResponse
from app.logic.survival import compute_survival

app = FastAPI(title="SurvivAI API")

@app.get("/api/survival-score", response_model=SurvivalScoreResponse)
def get_survival_score(user_id: str):
    calc = compute_survival(wallet_balance=87.0, daily_burn_rate=7.9)
    return SurvivalScoreResponse(
        user_id=user_id,
        survival_days=calc["survival_days"],
        daily_burn_rate=7.9,
        wallet_balance=87.0,
        trend_7d="declining",
        color_band=calc["color_band"],
        top_discretionary_category="Grab Food",
        top_discretionary_amount_7d=42.0,
    )
```

- [ ] **Step 4: Run tests and local server smoke check**

Run: `cd backend/services; pip install -r requirements.txt; pytest -q`  
Expected: PASS.  
Run: `cd backend/services; uvicorn app.main:app --reload`  
Expected: server starts and `GET /api/survival-score?user_id=user_siti_001` returns JSON payload.

- [ ] **Step 5: Commit**

```bash
git add backend/services/requirements.txt backend/services/app/main.py backend/services/app/logic/survival.py backend/services/app/logic/nudges.py backend/services/tests/test_logic_survival.py
git commit -m "feat: add fastapi backend with survival score endpoint"
```

### Task 3: Add Production-Path Integrations (Config + SageMaker Client)

**Files:**
- Create: `backend/services/app/settings.py`
- Create: `backend/services/app/clients/sagemaker_client.py`
- Create: `backend/services/.env.example`
- Modify: `backend/services/app/main.py`

- [ ] **Step 1: Write failing config test**

```python
# backend/services/tests/test_settings.py
from app.settings import Settings

def test_settings_defaults():
    cfg = Settings()
    assert cfg.environment in {"local", "staging", "production"}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend/services; pytest tests/test_settings.py -q`  
Expected: FAIL because `app/settings.py` does not exist.

- [ ] **Step 3: Implement environment and SageMaker invocation boundary**

```python
# backend/services/app/settings.py
from pydantic_settings import BaseSettings
from typing import Literal

class Settings(BaseSettings):
    environment: Literal["local", "staging", "production"] = "local"
    aws_region: str = "ap-southeast-1"
    sagemaker_endpoint_name: str = ""
    use_sagemaker: bool = False

    class Config:
        env_file = ".env"
```

```python
# backend/services/app/clients/sagemaker_client.py
def predict_spending(payload: dict) -> dict:
    # Local deterministic fallback until real endpoint is wired.
    return {
        "daily_burn_rate": 7.9,
        "top_discretionary_category": "Grab Food",
        "top_discretionary_amount_7d": 42.0,
    }
```

- [ ] **Step 4: Run tests and verify both local/fallback path**

Run: `cd backend/services; pytest -q`  
Expected: PASS.  
Run: `cd backend/services; python -c "from app.settings import Settings; print(Settings().environment)"`  
Expected: prints `local` unless `.env` overrides.

- [ ] **Step 5: Commit**

```bash
git add backend/services/app/settings.py backend/services/app/clients/sagemaker_client.py backend/services/.env.example backend/services/app/main.py backend/services/tests/test_settings.py
git commit -m "feat: add backend environment config and sagemaker client boundary"
```

### Task 4: Replace Frontend MockData Reads With API Repository

**Files:**
- Modify: `survivai/pubspec.yaml`
- Create: `survivai/lib/core/config/app_env.dart`
- Create: `survivai/lib/core/services/api_client.dart`
- Create: `survivai/lib/core/services/survivai_repository.dart`
- Modify: `survivai/lib/core/providers/app_provider.dart`
- Test: `survivai/test/core/providers/app_provider_api_test.dart`

- [ ] **Step 1: Write failing provider test**

```dart
// survivai/test/core/providers/app_provider_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:survivai/core/providers/app_provider.dart';

void main() {
  test('loads user from API repository', () async {
    final provider = AppProvider.test();
    await provider.loadDashboard();
    expect(provider.user.id, 'user_siti_001');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd survivai; flutter test test/core/providers/app_provider_api_test.dart`  
Expected: FAIL because `AppProvider.test()` and repository wiring do not exist.

- [ ] **Step 3: Implement API client + provider async flow**

```dart
// survivai/lib/core/config/app_env.dart
class AppEnv {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );
}
```

```dart
// survivai/lib/core/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final res = await _client.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
```

- [ ] **Step 4: Run tests and static checks**

Run: `cd survivai; flutter pub get && flutter test`  
Expected: PASS with provider API test and existing smoke tests.  
Run: `Get-ChildItem survivai/lib -Recurse -File | Select-String -Pattern "MockDataService"`  
Expected: only fallback/test usage remains; provider no longer depends on it.

- [ ] **Step 5: Commit**

```bash
git add survivai/pubspec.yaml survivai/lib/core/config/app_env.dart survivai/lib/core/services/api_client.dart survivai/lib/core/services/survivai_repository.dart survivai/lib/core/providers/app_provider.dart survivai/test/core/providers/app_provider_api_test.dart
git commit -m "feat: connect flutter provider flow to backend api"
```

### Task 5: End-to-End Local Validation (Backend + Frontend)

**Files:**
- Modify: `survivai/README.md`
- Create: `docs/deployment/local-fullstack-checklist.md`
- Modify: `backend/services/tests/test_api_contracts.py`
- Modify: `survivai/test/widget_test.dart`

- [ ] **Step 1: Write failing integration assertion**

```python
# backend/services/tests/test_api_contracts.py (add)
from fastapi.testclient import TestClient
from app.main import app

def test_survival_endpoint_contract():
    client = TestClient(app)
    res = client.get("/api/survival-score", params={"user_id": "user_siti_001"})
    assert res.status_code == 200
    assert "survival_days" in res.json()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend/services; pytest tests/test_api_contracts.py -q`  
Expected: FAIL until route + contract are fully aligned.

- [ ] **Step 3: Implement full local runbook commands**

```md
<!-- docs/deployment/local-fullstack-checklist.md -->
1) Backend:
   - `cd backend/services`
   - `pip install -r requirements.txt`
   - `uvicorn app.main:app --host 0.0.0.0 --port 8000`
2) Frontend:
   - `cd survivai`
   - `flutter pub get`
   - `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api`
3) Verify:
   - Home screen shows survival score from API response.
   - Emergency screen shows backend-derived countdown.
```

- [ ] **Step 4: Run validation suite**

Run: `cd backend/services; pytest -q`  
Expected: PASS.  
Run: `cd survivai; flutter analyze && flutter test`  
Expected: PASS (requires Flutter SDK installed).

- [ ] **Step 5: Commit**

```bash
git add survivai/README.md docs/deployment/local-fullstack-checklist.md backend/services/tests/test_api_contracts.py survivai/test/widget_test.dart
git commit -m "test: add local end-to-end validation checklist and contract checks"
```

### Task 6: Alibaba Deployment Readiness (ECS + OSS/CDN)

**Files:**
- Create: `backend/services/Dockerfile`
- Create: `docs/deployment/alibaba-fullstack-runbook.md`
- Modify: `backend/services/.env.example`
- Modify: `survivai/README.md`

- [ ] **Step 1: Write failing container smoke test command**

```bash
# expected to fail before Dockerfile exists
cd backend/services
docker build -t survivai-api:local .
```

- [ ] **Step 2: Run command to verify it fails**

Run: `cd backend/services; docker build -t survivai-api:local .`  
Expected: FAIL with missing `Dockerfile`.

- [ ] **Step 3: Implement deployment artifacts**

```dockerfile
# backend/services/Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```md
<!-- docs/deployment/alibaba-fullstack-runbook.md -->
Backend (ECS):
1. Build and push backend image to Alibaba ACR.
2. Deploy container to ECS (port 8000), set env vars from `.env.example`.
3. Bind domain/API Gateway route to ECS service.

Frontend (OSS + CDN):
1. `cd survivai && flutter build web --dart-define=API_BASE_URL=https://<api-domain>/api`
2. Upload `survivai/build/web` to OSS bucket.
3. Attach CDN and enforce HTTPS.

Cross-cloud:
1. Set `USE_SAGEMAKER=true`, `AWS_REGION=ap-southeast-1`, `SAGEMAKER_ENDPOINT_NAME=<name>`.
2. Confirm ECS egress can reach AWS endpoint.
3. Verify request trace in Alibaba logs and AWS CloudWatch.
```

- [ ] **Step 4: Run deployment-readiness checks**

Run: `cd backend/services; docker build -t survivai-api:local .`  
Expected: PASS (image builds successfully).  
Run: `cd survivai; flutter build web --dart-define=API_BASE_URL=http://localhost:8000/api`  
Expected: PASS with `build/web` output.

- [ ] **Step 5: Commit**

```bash
git add backend/services/Dockerfile docs/deployment/alibaba-fullstack-runbook.md backend/services/.env.example survivai/README.md
git commit -m "chore: add alibaba deployment runbook and backend containerization"
```

## Self-Review

1. **Spec coverage:**  
Covered: frontend-backend linking, deterministic backend, API contract locking, local E2E validation, Alibaba ECS/OSS/CDN deployment path, SageMaker integration boundary.  
Excluded by design: full production IAM hardening, complete CI/CD pipeline, advanced ML retraining.

2. **Placeholder scan:**  
No TODO/TBD placeholders; each task includes concrete files, commands, and expected outcomes.

3. **Type consistency:**  
Contract keys are consistent across backend schema and Flutter JSON mapping (`survival_days`, `daily_burn_rate`, `color_band`, `top_discretionary_*`).

