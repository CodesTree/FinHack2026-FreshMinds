# SurvivAI — Technical Spec Sheet (Final Build)

**Version**: 4.0 | **Date**: 26 April 2026 | **Hackathon**: TNGD FinHack 2026
**Track**: Financial Inclusion | **Build Window**: 4 hours remaining

---

## ⚠️ Scope Lock — What We Are Building

| In Scope (Must Ship) | Cut (Will NOT Build) |
|---|---|
| Survival Score Engine | ~~Spending Classifier (ML model trained from scratch)~~ |
| Emergency Mode Dashboard | ~~CTOS Financial Lifeline Loan~~ |
| Spending Habit Prediction (SageMaker model) | ~~Credit Scoring Mechanism~~ |
| Nudge System (template engine + bilingual) | ~~MCC-Locked Disbursal System~~ |
| Government Benefits Checker (static) | ~~CTOS Integration~~ |
| Multi-cloud architecture (AWS SageMaker + Alibaba ECS) | ~~Bedrock NLP, DynamoDB, additional AWS services~~ |

**Rationale**: With 4 hours remaining, we focus on delivering a polished, end-to-end demo of the Survival Score → Emergency Mode → Nudge loop. AWS SageMaker hosts the spending prediction model; Alibaba Cloud handles the application layer. Both clouds are essential to every user request — neither is decorative.

---

## 1. Problem Statement

Malaysia's B40 households (bottom 40% income group, approximately 5.8 million households) live in permanent financial fragility:

- 86% cannot raise RM1,000 for an emergency expense
- Most cannot survive beyond 3 months after job loss
- They spend to near-zero each month, leaving no buffer for unexpected costs
- They are credit invisible — no credit card, no formal loan history

The paradox: B40 users are **data rich**. Daily TNG eWallet transactions, utility bill payments, and consistent spending patterns constitute a behavioural credit fingerprint that existing systems ignore entirely.

**The gap**: No Malaysian fintech today uses TNG behavioural transaction data to (a) show users their real financial survival window and (b) coach them to extend it with actionable, personalised daily nudges at the moment it matters most.

---

## 2. Solution Overview

SurvivAI is a financial survival coach embedded within TNG eWallet that does three things:

### 2.1 Survival Score Engine
Computes a live, personalised **"Survival Score"** — the number of days a user can survive if they lose their income today — derived from TNG spending history and current wallet balance.

### 2.2 Emergency Mode
When a user faces an unexpected emergency, they activate **Emergency Mode**. The app switches to a survival dashboard showing daily burn rate, countdown by day, and actionable nudges to extend their runway.

### 2.3 Spending Habit Prediction
Determines if a user is overspending by predicting daily spending by subcategory (food, grocery, etc.) and calculates a daily safe spending target. This recalculates the survival score in real-time.

---

## 3. User Persona & Journey

### Primary Persona — Siti

> **Siti, 34, factory line worker, Shah Alam.**
> Monthly income: RM1,800. Rent: RM600. Remittance to parents: RM300.
> After groceries and transport: ~RM200 remaining. Savings: never exceeded RM150.
> She has a TNG eWallet she tops up weekly. No credit card. No PTPTN.
> She is one medical emergency away from unrecoverable debt.

### User Journey

```
1. Siti opens TNG eWallet → sees her Survival Score: "11 days"
2. Score is colour-coded RED (< 30 days) with weekly trend arrow (↓ declining)
3. She taps to see breakdown → 63% Needs / 31% Wants / 6% Savings
4. Top discretionary: food_delivery at RM42/week
5. Morning nudge: "You spent RM42 on Grab this week. Cutting 2 orders = +3 survival days."
6. Siti loses her job → activates Emergency Mode manually
7. Dashboard switches: daily countdown, essential-only burn rate, elevated nudges
8. Evening nudge: "You spent RM18 today. Runway: 9 days. Tomorrow's target: under RM12."
9. Benefits card appears: "You may be eligible for Bantuan Rahmah RM200 — tap to apply"
10. As Siti cuts discretionary spend, score recovers → exits red zone → Emergency Mode auto-deactivates
```

---

## 4. Architecture

### 4.1 Cloud Strategy — Split by Responsibility

| Responsibility | Cloud Provider | Rationale |
|---|---|---|
| **ML Model Hosting** | **AWS SageMaker** | Real-time endpoint for spending habit prediction model |
| **Application Stack** | **Alibaba Cloud** | Backend ECS, frontend deployment, database, API gateway, audit logs, storage |
| **Frontend** | Existing repo (pre-built) | Already developed; hosted on Alibaba Cloud via ECS + OSS/CDN |

> **Design principle**: AWS handles the AI inference (spending habit prediction via SageMaker). Alibaba Cloud handles the application layer (backend API, user data, frontend serving, audit trail). Both are core to every user request — neither is decorative. No Bedrock, no DynamoDB, no additional AWS services.

### 4.2 System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FRONTEND (Existing Repo)                     │
│                     React / Next.js — Pre-built                     │
│         Survival Score Ring │ Emergency Dashboard │ Nudge Cards      │
└──────────────────────────────┬──────────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│              ALIBABA CLOUD — Application & Data Layer               │
│                                                                     │
│  ┌─────────────────┐    ┌──────────────────────────────────────┐   │
│  │  API Gateway     │───▶│  ECS Backend                         │   │
│  │  (APIG)         │    │  - Node.js / Python application      │   │
│  └─────────────────┘    │  - REST API endpoints                │   │
│                          │  - Score computation orchestration   │   │
│                          │  - Transaction bucketing (60/30/10)  │   │
│                          │  - Nudge template engine             │   │
│                          │  - Calls AWS SageMaker endpoint      │   │
│                          └──────────┬───────────────────────────┘   │
│                                     │                               │
│  ┌──────────────────┐    ┌──────────┴───────────────────────────┐   │
│  │  ApsaraDB RDS    │    │  OSS (Object Storage Service)        │   │
│  │  (MySQL)         │    │  - Frontend static files (CDN)       │   │
│  │  - users table   │    │  - Benefits eligibility JSON         │   │
│  │  - transactions  │    │  - MCC mapping file                  │   │
│  │  - scores        │    └──────────────────────────────────────┘   │
│  │  - nudge_log     │                                               │
│  └──────────────────┘    ┌──────────────────────────────────────┐   │
│                          │  SLS (Simple Log Service)             │   │
│                          │  - API request audit trail           │   │
│                          │  - Score computation logs             │   │
│                          │  - Anonymised decision records        │   │
│                          └──────────────────────────────────────┘   │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ HTTPS (cross-cloud)
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    AWS — ML Model Endpoint Layer                     │
│                    Region: ap-southeast-1 (Singapore)                │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  AWS API Gateway                                             │   │
│  │  - Exposes SageMaker endpoint to Alibaba ECS                 │   │
│  └──────────────────────────┬───────────────────────────────────┘   │
│                              │                                       │
│  ┌──────────────────────────┴───────────────────────────────────┐   │
│  │  AWS Lambda (Optional Orchestration)                         │   │
│  │  - Request validation & shaping                              │   │
│  │  - Fallback scoring logic (if SageMaker times out)           │   │
│  │  - Invokes SageMaker endpoint                                │   │
│  └──────────────────────────┬───────────────────────────────────┘   │
│                              │                                       │
│  ┌──────────────────────────┴───────────────────────────────────┐   │
│  │  Amazon SageMaker — Real-Time Endpoint                       │   │
│  │  - Spending habit prediction model                           │   │
│  │  - Weighted rolling average forecasting                      │   │
│  │  - Returns predicted spend by subcategory                    │   │
│  │  - Computes daily_burn_rate for survival score               │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  CloudWatch                                                  │   │
│  │  - Lambda invocation metrics & latency                       │   │
│  │  - SageMaker endpoint performance & errors                   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.3 Request Flow (Survival Score Calculation)

```
User opens app
    → Frontend calls Alibaba API Gateway
    → Alibaba ECS backend receives request
    → Backend fetches user transactions from ApsaraDB RDS
    → Backend calls AWS API Gateway (cross-cloud HTTPS)
    → AWS Lambda receives request (or direct SageMaker if no Lambda)
    → Lambda invokes SageMaker real-time endpoint
    → SageMaker predicts spending by subcategory
    → SageMaker returns daily_burn_rate
    → Response returns to Alibaba ECS
    → ECS computes survival_days = balance / daily_burn_rate
    → ECS formats response, logs to SLS
    → Returns JSON payload to frontend
    → Frontend animates Survival Score ring
```

---

## 5. Feature Specification

### 5.1 Survival Score

| Attribute | Detail |
|---|---|
| **Definition** | `(current_wallet_balance + accessible_savings) ÷ daily_burn_rate` |
| **daily_burn_rate** | Predicted next-30-day essential spend ÷ 30, derived from 90-day behavioural model |
| **Update frequency** | Recalculated on every TNG transaction + daily at 00:00. Frontend receives a `score_delta_pct` payload on each update. |
| **Display** | "You can survive **X days** if you lose your income today" |
| **Colour coding** | Green: ≥ 90 days │ Yellow: < 90 days │ Red: < 30 days |
| **Trend indicator** | Week-on-week delta shown (↑ improving / ↓ declining) |

#### 5.1.1 Survival Score Calculation — Spending Habits Model

**Step 1 — Bucket all transactions (90-day window)**

Every transaction is tagged into a predefined category/subcategory via MCC code lookup. Spending is bucketed using the **60/30/10 rule** as baseline:

| Bucket | Label | Sub-categories |
|---|---|---|
| 60% | Essential | Groceries, fuel, utilities, rent, telephone, pharmacies |
| 30% | Discretionary | Food delivery, ride-hailing, cafes, entertainment, online shopping, clothing |
| 10% | Savings | Wallet top-up excess, explicit savings transfers |

The MCC-to-subcategory mapping is stored in the `mcc_allowlist` DynamoDB table on AWS.

**Step 2 — Predict future spend per subcategory**

AWS Lambda computes a weighted rolling average per subcategory across the 90-day window to forecast next-30-day spend. Recurring bills detected by regularity are anchored as fixed costs; variable spend uses trailing 4-week weighted average.

**Step 3 — Compute survival days**

```
predicted_monthly_essential = sum(Needs bucket 30-day forecast)
daily_burn_rate             = predicted_monthly_essential / 30
survival_days               = current_wallet_balance / daily_burn_rate
```

**Step 4 — Response payload**

```json
{
  "survival_days": 11,
  "score_delta_pct": -4.2,
  "color_band": "red",
  "needs_pct": 63,
  "wants_pct": 31,
  "savings_pct": 6,
  "top_subcategory": "food_delivery",
  "top_subcategory_amount_7d": 42.00
}
```

### 5.2 Emergency Mode

| Attribute | Detail |
|---|---|
| **Trigger** | (1) Manual user activation (self-declared emergency) or (2) User drops to red survival zone and is prompted |
| **Dashboard shows** | Survival countdown by day, daily burn rate, essential vs discretionary breakdown |
| **Nudges** | Elevated to 2x daily — morning and evening — with specific RM/day savings suggestions |
| **Exit condition** | (1) User manually deactivates, or (2) Survival Score recovers to Yellow band (≥ 30 days) |

### 5.3 Nudge System (Twice Daily)

| Attribute | Detail |
|---|---|
| **Frequency** | Twice daily — morning (8am) and evening (8pm) |
| **Morning nudge** | Top discretionary category + weekly RM amount + survival days saved. E.g.: "You spent RM42 on Grab this week. Cutting 2 orders = +3 survival days." |
| **Evening nudge** | Day's spending recap + projected survival delta. E.g.: "You spent RM18 today. At this rate, runway is 9 days. Tomorrow's target: under RM12." |
| **Emergency Mode** | Same slots, elevated urgency tone |
| **Generation** | Bilingual template engine (EN + BM) inside AWS Lambda. Category + amount + survival-days delta injected into templates. Optional: Bedrock call for natural language personalisation. |
| **Languages** | English and Bahasa Malaysia |
| **Demo integration** | Siti's seed data ships with a pre-delivered morning nudge. `?demo_nudge=evening` URL param fires the evening template inline. |

### 5.4 Government Benefits Checker (Nice-to-Have / Static)

| Attribute | Detail |
|---|---|
| **Data source** | Bantuan Rahmah, STR, e-Kasih (static eligibility rules) |
| **Matching** | User income tier + age + household size → eligible benefits surfaced |
| **Display** | Card in Emergency Mode: "You may be eligible for Bantuan Rahmah RM200 — tap to apply" |
| **Implementation** | Static JSON lookup on Alibaba OSS — no external API required for MVP |

---

## 6. AI & ML Specification

### 6.1 Spending Habit Prediction — SageMaker Model

The Survival Score depends on a forward-looking spending forecast. AWS SageMaker hosts a regression model that predicts daily spend by subcategory for the next 30 days.

**Flow**:
```
Alibaba ECS receives transaction history (90-day window)
    ↓
Calculates weighted rolling average per subcategory
    ↓
Calls AWS SageMaker endpoint with feature vector
    ↓
SageMaker model returns predicted spend forecasts
    ↓
ECS computes: daily_burn_rate = sum(essential forecasts) / 30
    ↓
Computes: survival_days = wallet_balance / daily_burn_rate
```

**Model approach** (choose one for deployment):
- **XGBoost / scikit-learn** — Fastest to get working. Input: 30-day feature vector (spending totals per subcategory, frequency counts, variance). Output: predicted spend per subcategory for day 31-60.
- **LSTM / Time-series** — More sophisticated. Captures spending patterns and autocorrelation. Slower to train but better handling of irregular income (gig workers).
- **Rule-based fallback** — If SageMaker endpoint times out (>3s), Alibaba ECS falls back to weighted rolling average directly: `predicted = 4_week_avg * 0.6 + 8_week_avg * 0.4`.

**Training data** (for hackathon):
- Synthetic dataset of 10,000 labelled TNG-style transactions
- Merchant names mapped to MCC codes
- Category labels: need / want / save
- Stored in Alibaba OSS, loaded into SageMaker training job

**SageMaker deployment checklist**:
- [ ] Model serialised (pickle, joblib, SavedModel, or Docker image)
- [ ] Uploaded to S3 (optional — if not using custom container) or pushed to ECR (if custom container)
- [ ] SageMaker endpoint created with ml.t2.medium instance
- [ ] API Gateway route configured in AWS
- [ ] Alibaba ECS can call endpoint via HTTPS with <3s latency
- [ ] CloudWatch dashboard shows endpoint invocation count and latency

### 6.2 Nudge Template Engine (Alibaba ECS)

Purpose: Generate personalised, actionable daily nudge messages. No external AI required; runs on Alibaba ECS.

**Template structure** (bilingual):
```
MORNING: "You spent {amount} on {subcategory} this week. Cutting {reduction} = +{days_delta} survival days."
MORNING_BM: "Anda membelanjakan {amount} untuk {subcategory} minggu ini. Kurangkan {reduction} = +{days_delta} hari bertahan."

EVENING: "You spent {today_amount} today. At this rate, runway is {survival_days} days. Tomorrow's target: under {target_amount}."
EVENING_BM: "Anda membelanjakan {today_amount} hari ini. Dengan kecepatan ini, sisa hari adalah {survival_days} hari. Target esok: kurang dari {target_amount}."

EMERGENCY_MORNING: "⚠️ Emergency: {subcategory} is your biggest drain at {amount}/week. Saving {reduction} extends runway by {days_delta} days."
EMERGENCY_MORNING_BM: "⚠️ Kecemasan: {subcategory} menghabiskan {amount}/minggu. Berhemat {reduction} tambah {days_delta} hari lagi."
```

**Injection logic**:
1. Compute top discretionary category for the week
2. Compute savings if user cuts that category by 20-30%
3. Inject into template string
4. Return rendered text to frontend

**Fallback**: If user language preference is unset, default to English.

---

## 7. Tech Stack

| Layer | Technology | Cloud |
|---|---|---|
| **Frontend** | React / Next.js (existing repo) | Alibaba OSS + CDN |
| **Backend API** | Node.js or Python (FastAPI) | Alibaba Cloud ECS |
| **API Routing** | Alibaba API Gateway | Alibaba Cloud |
| **ML Model Hosting** | AWS SageMaker (real-time endpoint) | AWS |
| **Primary Database** | ApsaraDB RDS (MySQL) | Alibaba Cloud |
| **Object Storage** | Alibaba OSS (static assets, benefits JSON, MCC mapping) | Alibaba Cloud |
| **Logging / Audit** | Alibaba SLS (Simple Log Service) | Alibaba Cloud |
| **Monitoring** | CloudWatch (SageMaker + Lambda) + Alibaba Cloud Monitor (ECS) | Both |

---

## 8. Cloud Architecture — AWS

**Role**: ML Model Inference Layer
**Region**: ap-southeast-1 (Singapore)
**Scope**: SageMaker endpoint for spending habit prediction — nothing else

### Services Used

| Service | Purpose | Why It's Core |
|---|---|---|
| **Amazon SageMaker** | Real-time endpoint for spending habit prediction model | Every survival score computation depends on SageMaker's spending forecast — it's the core ML capability |
| **AWS API Gateway** | Exposes SageMaker endpoint to Alibaba ECS | Entry point for Alibaba backend to invoke the model |
| **AWS Lambda** (optional) | Request validation, fallback scoring, endpoint invocation | Provides orchestration layer, error handling, and fallback logic if SageMaker times out. Can be replaced with direct SageMaker endpoint calls if latency/simplicity is critical. |
| **CloudWatch** | SageMaker endpoint metrics, Lambda execution metrics | Operational observability for model performance and availability |

### AWS Limitations Acknowledged

| Unavailable | Impact | Workaround |
|---|---|---|
| RAM (Resource Access Manager) | Not needed — single-account setup for hackathon | N/A |
| Security Hub / GuardDuty / Audit | Not critical for MVP | CloudWatch + SageMaker metrics suffice |
| Billing | Cost tracking not required for hackathon | N/A |
| Bedrock, DynamoDB, S3, Lambda compute | Explicitly cut from scope | SageMaker endpoint is sufficient; MCC mapping stays in Alibaba OSS |

### SageMaker Deployment Approach

**Model format options** (choose one):
- **scikit-learn / XGBoost**: Package as `.tar.gz`, upload to S3, deploy via SageMaker built-in container
- **PyTorch / TensorFlow**: Same packaging, use framework-specific container
- **Custom code**: Wrap model + inference code in a Docker image, push to ECR, deploy as custom SageMaker endpoint

**Endpoint configuration**:
```
Instance type: ml.t2.medium or ml.t3.medium (hackathon: lowest-cost option)
Initial instance count: 1
Invocation timeout: 30 seconds (fallback to rule-based score if exceeded)
Response payload: JSON with { subcategory_forecasts, daily_burn_rate, survival_days }
```

**Quick integration check**: Does your model pickle/serialize? If yes, SageMaker handles it. If no (e.g., custom streaming model), wrap in a Flask app and use custom container.

---

## 9. Cloud Architecture — Alibaba Cloud

**Role**: Application Serving, Data, and Audit Layer
**Services**: API Gateway, ECS, ApsaraDB RDS, OSS, SLS, CloudMonitor

### Services Used

| Service | Purpose | Why It's Core |
|---|---|---|
| **ECS (Elastic Compute Service)** | Hosts backend application (Node.js/Python) | All API logic runs here — the application server that orchestrates scoring, invokes SageMaker, and serves frontend requests |
| **API Gateway** | Entry point for frontend, routes requests to ECS, handles rate limiting and validation | First touch for every user request |
| **ApsaraDB RDS (MySQL)** | Primary database: users, transactions, scores, nudge_log | Relational data store for all user state |
| **OSS (Object Storage Service)** | Frontend static files (via CDN), benefits eligibility JSON, MCC mapping | Serves static assets + data files used for MCC classification |
| **CDN** | Frontend delivery acceleration | Fast load times for demo |
| **SLS (Simple Log Service)** | API request logs, score computation audit trail, anonymised decision logs | Compliance audit trail (Enshu will scrutinize this) |
| **Cloud Monitor** | ECS health, RDS performance, API Gateway metrics | Operational dashboard |

### Alibaba Cloud Limitations Acknowledged

| Unavailable | Impact |
|---|---|
| PAI / EAS (ML Platform) | ML stays on AWS (SageMaker) — this is by design, not a constraint |
| MaxCompute / DataWorks | Not needed — data processing handled by ECS + RDS |
| WAF / DDoS / SAS / Yundun | Security is demo-grade; sufficient for hackathon scope |
| DirectMail | Nudges delivered in-app, not via email |
| Billing / CloudSSO / Cloud Governance / Resource Directory / Audit / Config | Not needed for hackathon scope |

---

## 10. Cross-Cloud Integration Pattern

```
Frontend (Alibaba CDN/OSS)
    │
    ▼
Alibaba API Gateway ──▶ Alibaba ECS Backend
    │                         │
    │                         ├── Read/Write: ApsaraDB RDS (user data, transactions)
    │                         ├── Read: OSS (benefits JSON, MCC map)
    │                         ├── Write: SLS (audit logs)
    │                         │
    │                         └── HTTPS call ──▶ AWS API Gateway
    │                                                │
    │                                                ▼
    │                                          AWS Lambda (optional)
    │                                            ├── Request validation
    │                                            ├── Invoke SageMaker endpoint
    │                                            └── Fallback scoring logic
    │                                                │
    │                                                ▼
    │                                          AWS SageMaker
    │                                            ├── Spending prediction model
    │                                            ├── Weighted rolling average
    │                                            └── Returns burn_rate forecast
    │
    ◀─── Response flows back through ECS to Frontend
```

**Why this split satisfies Multi-Cloud judging criteria**:
- Every single user action flows through **both** clouds
- Alibaba Cloud is not just hosting — it's the data layer (RDS), the serving layer (ECS + API Gateway), the frontend delivery (OSS + CDN), and the audit layer (SLS)
- AWS is not just a service — it's the ML inference layer (SageMaker) with Lambda as optional orchestration
- Neither cloud can be removed without breaking the product
- SageMaker is the core differentiator on AWS — no Bedrock, no DynamoDB

---

## 11. API Contracts

### 11.1 Frontend → Alibaba Backend

**GET /api/survival-score**
```json
// Request
Headers: { "Authorization": "Bearer <token>" }
Query: { "user_id": "siti_001" }

// Response 200
{
  "survival_days": 11,
  "score_delta_pct": -4.2,
  "color_band": "red",
  "needs_pct": 63,
  "wants_pct": 31,
  "savings_pct": 6,
  "top_subcategory": "food_delivery",
  "top_subcategory_amount_7d": 42.00,
  "trend_7d": "declining",
  "emergency_mode": false
}
```

**POST /api/emergency-mode**
```json
// Request
{ "user_id": "siti_001", "action": "activate" }

// Response 200
{
  "emergency_mode": true,
  "daily_burn_rate": 38.50,
  "countdown_days": 11,
  "essential_breakdown": [
    { "category": "groceries", "daily_avg": 15.20 },
    { "category": "transport", "daily_avg": 8.30 },
    { "category": "utilities", "daily_avg": 5.00 }
  ],
  "benefits_eligible": [
    { "name": "Bantuan Rahmah", "amount": "RM200", "url": "https://bfrm.hasil.gov.my" }
  ]
}
```

**GET /api/nudge**
```json
// Request
Query: { "user_id": "siti_001", "slot": "morning" }

// Response 200
{
  "nudge_text": "You spent RM42 on Grab this week. Cutting 2 orders = +3 survival days.",
  "nudge_text_bm": "Anda membelanjakan RM42 untuk Grab minggu ini. Kurangkan 2 pesanan = +3 hari bertahan.",
  "subcategory": "food_delivery",
  "amount_rm": 42.00,
  "survival_days_delta": 3,
  "slot": "morning",
  "emergency": false
}
```

### 11.2 Alibaba Backend → AWS SageMaker Endpoint

**POST /predict** (via AWS API Gateway)
```json
// Request
{
  "user_id": "siti_001",
  "wallet_balance": 423.50,
  "transactions_90d": [ 
    { "date": "2026-04-20", "amount": 15.50, "mcc": "5411", "merchant": "Giant Supermarket" },
    { "date": "2026-04-20", "amount": 8.00, "mcc": "5812", "merchant": "Mamak Stall" },
    ...
  ],
  "request_nudge": true,
  "nudge_slot": "morning",
  "language": "en"
}

// Response 200 (SageMaker endpoint returns)
{
  "survival_days": 11,
  "daily_burn_rate": 38.50,
  "spending_breakdown": {
    "needs_pct": 63,
    "wants_pct": 31,
    "savings_pct": 6
  },
  "predicted_spend": {
    "groceries": 420.00,
    "food_delivery": 140.00,
    "transport": 200.00,
    "utilities": 150.00,
    "other_discretionary": 130.00
  },
  "top_discretionary": {
    "subcategory": "food_delivery",
    "amount_7d": 42.00,
    "reduction_suggestion": "2 orders",
    "days_saved": 3
  },
  "nudge": {
    "text_en": "You spent RM42 on Grab this week. Cutting 2 orders = +3 survival days.",
    "text_bm": "Anda membelanjakan RM42 untuk Grab minggu ini. Kurangkan 2 pesanan = +3 hari bertahan."
  }
}
```

**Response 503 (Fallback if SageMaker times out)**:
Alibaba ECS computes rule-based score using weighted rolling average:
```json
{
  "survival_days": 10,
  "daily_burn_rate": 42.35,
  "color_band": "red",
  "fallback": true,
  "message": "SageMaker endpoint timeout — using rule-based fallback"
}
```

---

## 12. Database Schema

### 12.1 ApsaraDB RDS (Alibaba Cloud) — MySQL

**users**
```sql
CREATE TABLE users (
  user_id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100),
  wallet_balance DECIMAL(10,2),
  monthly_income DECIMAL(10,2),
  language ENUM('en', 'bm') DEFAULT 'en',
  emergency_mode BOOLEAN DEFAULT FALSE,
  emergency_activated_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**transactions**
```sql
CREATE TABLE transactions (
  txn_id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36),
  amount DECIMAL(10,2),
  mcc VARCHAR(4),
  merchant_name VARCHAR(200),
  category ENUM('need', 'want', 'save'),
  subcategory VARCHAR(50),
  txn_date TIMESTAMP,
  INDEX idx_user_date (user_id, txn_date),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

**scores**
```sql
CREATE TABLE scores (
  score_id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36),
  survival_days INT,
  daily_burn_rate DECIMAL(10,2),
  needs_pct DECIMAL(5,2),
  wants_pct DECIMAL(5,2),
  savings_pct DECIMAL(5,2),
  color_band ENUM('green', 'yellow', 'red'),
  computed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_time (user_id, computed_at),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

**nudge_log**
```sql
CREATE TABLE nudge_log (
  nudge_id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36),
  slot ENUM('morning', 'evening'),
  nudge_text TEXT,
  subcategory VARCHAR(50),
  amount_rm DECIMAL(10,2),
  survival_days_delta INT,
  acknowledged BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### 12.2 DynamoDB (AWS)

**mcc_allowlist**
```
Partition Key: mcc (String)
Attributes: category (need/want/save), subcategory (String), bucket_label (String), description (String)
```

**spending_predictions**
```
Partition Key: user_id (String)
Sort Key: prediction_date (String)
Attributes: subcategory_forecasts (Map), daily_burn_rate (Number), survival_days (Number), ttl (Number)
```

---

## 13. Compliance & Privacy

### PDPA Compliance

| Requirement | Implementation |
|---|---|
| **Consent before data use** | Explicit consent screen on onboarding covers transaction analysis |
| **Data minimisation** | Raw transaction data stays in Alibaba RDS. Only aggregated features sent to AWS Lambda. No PII crosses cloud boundary. |
| **Right to withdraw** | User can deactivate SurvivAI and request data deletion from settings |
| **Data residency** | User PII stays in Alibaba Cloud. AWS receives only anonymised, aggregated spending vectors. |
| **Audit trail** | All score computations logged to Alibaba SLS with anonymised user ID — no NRIC, no name |

### BNM Alignment

| Policy | How We Comply |
|---|---|
| **RMIT Policy 2021** | AI scoring logic is explainable — survival score formula is transparent to user |
| **AML/CFT** | Not applicable — no fund transfers, credit issuance, or account creation |
| **PDPA (amended 2024)** | Behavioural profiling uses only user's own transaction data with consent |

---

## 14. Deployment on Cloud

### 14.1 Alibaba Cloud Deployment

```
1. Provision ECS instance (2 vCPU, 4GB RAM — ecs.c6.large or equivalent)
2. Install Node.js/Python runtime
3. Deploy backend application via Git pull or Docker container
4. Provision ApsaraDB RDS MySQL (basic instance, db.t3.small or equivalent)
5. Run schema migration scripts (create users, transactions, scores, nudge_log tables)
6. Seed synthetic transaction data (10K records for Siti persona)
7. Upload static assets to OSS (frontend build, benefits.json, mcc_mapping.json)
8. Configure API Gateway routes → ECS backend endpoints
9. Configure CDN to serve OSS frontend assets
10. Enable SLS log collection from ECS (API logs, audit trail)
11. Configure Cloud Monitor dashboard for ECS + RDS health
12. Test: Frontend loads, API Gateway accepts requests, ECS responds
```

### 14.2 AWS Deployment — SageMaker Endpoint

```
1. Prepare SageMaker model:
   - If XGBoost/scikit-learn: pickle model, create inference.py entry point
   - If PyTorch/TensorFlow: export SavedModel, wrap in inference.py
   - If custom code: write Flask app with /invocations endpoint, create Dockerfile
   
2. Package model:
   - If using built-in container: create .tar.gz with model.pkl + inference.py
   - If custom: build Docker image, push to ECR (ecr-account.dkr.ecr.ap-southeast-1.amazonaws.com/...)
   
3. Create SageMaker endpoint:
   - Upload .tar.gz to S3 (or reference ECR image)
   - Create SageMaker model via console
   - Create endpoint configuration (ml.t2.medium, 1 instance)
   - Deploy endpoint (takes ~5-10 minutes)
   
4. Create AWS API Gateway:
   - Create REST API
   - Create POST method /predict
   - Integrate with Lambda (if using) or direct SageMaker endpoint
   
5. Configure Lambda (optional but recommended):
   - Create function to validate request format
   - Invoke SageMaker endpoint
   - Return fallback score if endpoint times out
   - Grant SageMaker invocation permission
   
6. Set up CloudWatch:
   - Monitor SageMaker endpoint invocation count and latency
   - Monitor Lambda execution metrics (if used)
   - Set alarms for endpoint errors or timeouts
   
7. Test:
   - Invoke endpoint from Alibaba ECS
   - Verify response matches expected JSON format
   - Check latency (aim for <1.5s including network)
   - Verify fallback logic triggers if endpoint times out
```

### 14.3 Cross-Cloud Integration Test

```
1. Note AWS API Gateway endpoint URL (e.g., https://abc123.execute-api.ap-southeast-1.amazonaws.com/prod/predict)
2. Configure Alibaba ECS backend with AWS endpoint as environment variable
3. From ECS container, test HTTPS call to AWS:
   curl -X POST {AWS_API_ENDPOINT} \
     -H "Content-Type: application/json" \
     -d '{"transactions_90d": [...], "wallet_balance": 500}'
4. Verify SageMaker endpoint responds within 3 seconds
5. Verify response includes daily_burn_rate and spending forecast
6. Verify Alibaba SLS captures the cross-cloud call in audit logs
7. Verify CloudWatch captures SageMaker endpoint invocation
8. Test full flow: Frontend → Alibaba → AWS → response
```

---

## 15. MVP Feature List (4-Hour Build Scope)

### Must Have (Demo Breaks Without These)
- [ ] Survival Score computation returns correct JSON payload
- [ ] Frontend displays Survival Score ring with colour band
- [ ] Spending breakdown (needs/wants/savings percentages) displays
- [ ] Emergency Mode toggle activates/deactivates
- [ ] Emergency Mode dashboard shows countdown + burn rate
- [ ] At least one nudge template renders correctly (morning)
- [ ] Cross-cloud flow works: Frontend → Alibaba ECS → AWS SageMaker → response
- [ ] Seed data for Siti persona loaded and working
- [ ] SageMaker endpoint responds with valid spending forecast

### Should Have (Makes Demo Stronger)
- [ ] Evening nudge template also works
- [ ] Week-on-week trend indicator (↑/↓)
- [ ] Bilingual nudge output (EN + BM)
- [ ] Benefits checker card in Emergency Mode
- [ ] SLS audit logs visible in Alibaba console (for Enshu)
- [ ] CloudWatch dashboard shows SageMaker endpoint metrics

### Nice to Have (Only If Time Permits)
- [ ] `?demo_nudge=evening` URL param for live demo trigger
- [ ] Score delta animation on frontend
- [ ] CloudWatch dashboard screenshot for pitch deck
- [ ] Multiple user profiles for demo variety
- [ ] SageMaker fallback logic (rule-based scoring if endpoint times out)

---

## 16. Scalability Path

| Current (Hackathon) | Scale to 10x (Pilot) | Scale to 100x (Production) |
|---|---|---|
| 1 ECS instance | ECS Auto Scaling Group | Alibaba ACK (Kubernetes) + HPA |
| ApsaraDB RDS basic | RDS read replicas | PolarDB (distributed) |
| SageMaker single instance | Multi-instance endpoint | SageMaker auto-scaling + batch transform |
| Single region | Multi-AZ | Multi-region (MY + SG) |
| No caching | Redis (Alibaba Tair) | Tair + CDN edge caching |
| Security: demo-grade | Add WAF + SAS when available | Full Alibaba security stack |
| API latency: ~2-3s | <1s with caching | <500ms with edge computation |

---

## 17. Demo Script (2–3 min)

```
[0:00] "Meet Siti. She's 34, works in a factory in Shah Alam, earns RM1,800 a month."
[0:15] "She uses TNG eWallet every day — groceries, transport, phone bills."
[0:25] "But she has no savings. One emergency away from debt."
[0:30] → SHOW: Siti opens SurvivAI → Survival Score ring shows "11 days" in RED
[0:45] "SurvivAI analyses her spending and tells her: you can survive 11 days."
[0:55] → SHOW: Spending breakdown — 63% needs, 31% wants, 6% savings
[1:05] "Her biggest drain? RM42 on food delivery this week."
[1:10] → SHOW: Morning nudge appears — "Cut 2 Grab orders = +3 survival days"
[1:25] "Then the worst happens. Siti loses her job."
[1:30] → SHOW: Siti activates Emergency Mode → dashboard switches
[1:40] → SHOW: Daily countdown, essential burn rate, elevated nudges
[1:50] → SHOW: Benefits card — "You may qualify for Bantuan Rahmah RM200"
[2:00] "As Siti follows the nudges and cuts discretionary spending..."
[2:05] → SHOW: Score climbs from 11 → 14 → 18 days. Trend arrow goes ↑
[2:15] "This is SurvivAI. It doesn't give Siti a loan. It gives her visibility
        and agency over her own financial survival."
[2:30] → SHOW: Architecture slide — Alibaba Cloud (backend, data, serving) + AWS SageMaker (spending prediction)
[2:40] "Built for 5.8 million B40 households. Powered by data TNG already has."
```

---

## 18. Judging Criteria Alignment

| Criterion | How We Win It | Judge |
|---|---|---|
| **AI & Intelligent Systems** | AWS SageMaker powers the spending habit prediction — the core ML capability. Every survival score computation depends on this model. The model learns spending patterns and forecasts future spend by subcategory. | Leslie |
| **Technical Implementation** | Full-stack working prototype in 4 hours. Cross-cloud architecture (Alibaba + AWS). Real database with seeded data. SageMaker endpoint integrated via API call. Rule-based fallback if endpoint times out. Live computation, not mocked. | Leslie |
| **Multi-Cloud Service Usage** | Every request flows through both clouds. Alibaba = data (RDS), compute (ECS), frontend serving (OSS+CDN), audit (SLS). AWS = ML inference (SageMaker). Neither is removable. Architecture diagram proves deep integration. | Enshu |
| **Impact & Feasibility** | Named persona (Siti, B40, Shah Alam). 5.8M B40 households. Uses existing TNG transaction data — no new data collection. PDPA compliant. BNM aligned. Extends GOfinance, doesn't rebuild it. | Wing + Leslie |
| **Presentation & Teamwork** | Demo tells Siti's story from stability → crisis → recovery. Emotional arc. Live working product. Clear value prop: "How long can you survive?" Architecture discussion highlights Alibaba ECS + AWS SageMaker split. | Wing |

---

## 19. MCC Code Reference (Retained for Scoring Logic)

### Allowed MCC Codes (Essential — Needs Bucket)

| MCC | Category | Examples |
|---|---|---|
| 4900 | Utilities | Tenaga, Air Selangor, Unifi |
| 5047 | Medical/Dental | Guardian, Watson's |
| 5411 | Grocery Stores | Giant, Aeon, Mydin, Econsave |
| 5441 | Sundry/Provision | 99 Speedmart, 7-Eleven |
| 5812 | Eating Places | Mamak, hawker stalls, kopitiam |
| 5912 | Pharmacies | Watson's, Guardian, Caring |
| 6513 | Rental | Verified landlords |
| 4111 | Public Transport | Rapid KL, MRT, LRT |
| 4814 | Telecom | Celcom, Maxis, Digi, TM |

### Discretionary MCC Codes (Wants Bucket)

| MCC | Category | Block in Emergency? |
|---|---|---|
| 4121 | Taxicabs/Limos | Display warning |
| 5691 | Clothing | Display warning |
| 5732 | Electronics | Display warning |
| 5813 | Bars/Alcohol | Display warning |
| 5815 | Digital Goods | Display warning |
| 5816 | Digital Games | Display warning |
| 7011 | Hotels | Display warning |
| 7832 | Cinema | Display warning |
| 7995 | Gambling | Display warning |

> **Note**: In MVP, MCC codes are used for **classification only** (bucketing into needs/wants/savings). There is no MCC-locked disbursal or transaction blocking — that feature was cut from scope.
