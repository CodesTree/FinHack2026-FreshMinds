# SurvivAI — Technical Spec Sheet
**Version**: 1.0 | **Date**: 25 April 2026 | **Hackathon**: TNGD FinHack 2026
**Track**: Financial Inclusion | **Team**: TBD

---

## Table of Contents
1. [Problem Statement](#1-problem-statement)
2. [Solution Overview](#2-solution-overview)
3. [User Persona & Journey](#3-user-persona--journey)
4. [System Architecture](#4-system-architecture)
5. [Feature Specification](#5-feature-specification)
6. [AI & ML Specification](#6-ai--ml-specification)
7. [Credit Scoring Mechanism](#7-credit-scoring-mechanism)
8. [MCC-Locked Disbursal System](#8-mcc-locked-disbursal-system)
9. [Tech Stack](#9-tech-stack)
10. [Cloud Architecture — AWS](#10-cloud-architecture--aws)
11. [Cloud Architecture — Alibaba Cloud](#11-cloud-architecture--alibaba-cloud)
12. [API Contracts](#12-api-contracts)
13. [Database Schema](#13-database-schema)
14. [Compliance & Privacy](#14-compliance--privacy)
15. [MVP Scope & Prioritisation](#15-mvp-scope--prioritisation)
16. [Implementation Plan](#16-implementation-plan)
17. [Demo Script](#17-demo-script)
18. [Judging Criteria Alignment](#18-judging-criteria-alignment)
19. [Year 2 Roadmap](#19-year-2-roadmap)

---

## 1. Problem Statement

Malaysia's B40 households (bottom 40% income group, approximately 5.8 million households) live in a permanent state of financial fragility:

- **86%** cannot raise RM1,000 for an emergency expense
- Most cannot survive beyond **3 months** after job loss
- They spend to near-zero each month, leaving no buffer for unexpected costs
- They are **credit invisible** — no credit card, no formal loan history — yet rejected by traditional lenders

The paradox: B40 users are **data rich**. Daily TNG eWallet transactions, utility bill payments, and consistent spending patterns constitute a behavioural credit fingerprint that existing systems ignore entirely.

**The gap**: No Malaysian fintech today combines TNG behavioural transaction data with CTOS thin-file signals to (a) show users their real financial survival window and (b) extend it with a responsible, MCC-locked micro-loan at the moment of crisis.

---

## 2. Solution Overview

SurvivAI is a financial survival coach embedded within TNG eWallet that does three things:

### 2.1 Survival Score Engine
Computes a live, personalised **"Survival Score"** — the number of days a user can survive if they lose their income today — derived from TNG spending history and current wallet balance.

### 2.2 Emergency Mode
When a user is laid off or faces an unexpected emergency, they activate **Emergency Mode**. The app switches to a survival dashboard showing daily burn rate, countdown by day, and actionable nudges to extend their runway.

### 2.3 Emergency Credit Lifeline (ECL)
When a user's Survival Score drops below a critical threshold, SurvivAI offers an **Emergency Credit Lifeline** of RM100–RM200 disbursed to their TNG Visa Card. The card sub-balance is **MCC-locked** — spendable only at essential merchants (groceries, fuel, pharmacies, utilities). Repayment is scheduled as micro-deductions from future TNG wallet top-ups.

---

## 3. User Persona & Journey

### Primary Persona — Siti
> **Siti, 34, factory line worker, Shah Alam.**
> Monthly income: RM1,800. Rent: RM600. Remittance to parents: RM300.
> After groceries and transport: ~RM200 remaining. Savings: never exceeded RM150.
> She has a TNG eWallet she tops up weekly. No credit card. No PTPTN. CTOS thin-file.
> She is one medical emergency away from unrecoverable debt.

### User Journey

| Stage | Event | SurvivAI Response |
|---|---|---|
| **Onboarding** | Siti installs SurvivAI module in TNG | Analyses 90-day transaction history. Computes first Survival Score: **11 days** |
| **Daily Use** | Morning routine | Nudge: *"Skip one Grab order today = +2 survival days"* |
| **Crisis Trigger** | Siti is laid off | She taps Emergency Mode. Survival countdown begins. Daily burn shown. |
| **Day 3 of Crisis** | Survival Score drops to 4 days | App prompts: *"You may qualify for an Emergency Credit Lifeline"* |
| **Application** | Siti applies with one tap | AI credit scorer runs in 30 seconds: CTOS thin-file + 90-day TNG signals |
| **Approval** | RM150 approved | Disbursed to TNG Visa Card as a **restricted sub-balance** |
| **Spending** | Siti buys groceries at Giant | Transaction goes through. She tries Shopee — **card declined at POS** |
| **Recovery** | Siti gets new job | Repayment: RM15/week auto-deducted from TNG wallet top-ups over 10 weeks |
| **Credit History** | Repayment complete | Positive repayment record stored. Next ECL eligibility increases. |

---

## 4. System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     TNG MiniApp (Frontend)                  │
│  Survival Score UI │ Emergency Mode │ Loan Application UI   │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTPS/REST
┌──────────────────────────▼──────────────────────────────────┐
│              AWS API Gateway (Edge Layer)                    │
│         Rate limiting │ Auth │ Request routing              │
└──────┬───────────────────────────────────────┬──────────────┘
       │                                       │
┌──────▼──────────┐                  ┌─────────▼──────────────┐
│  AWS Lambda     │                  │  AWS Lambda             │
│  Core Services  │                  │  Credit Engine          │
│  - Survival     │                  │  - CTOS API call        │
│    Score calc   │                  │  - Feature engineering  │
│  - Emergency    │                  │  - SageMaker invoke     │
│    Mode logic   │                  │  - Loan decision        │
│  - Nudge gen    │                  │  - MCC disbursal        │
└──────┬──────────┘                  └─────────┬──────────────┘
       │                                       │
┌──────▼──────────┐  ┌──────────────┐ ┌───────▼──────────────┐
│  AWS DynamoDB   │  │ AWS Bedrock  │ │  AWS SageMaker        │
│  - user_profile │  │ (Claude      │ │  XGBoost Credit       │
│  - transactions │  │  Haiku)      │ │  Scoring Model        │
│  - loans        │  │  Nudge gen   │ │                       │
│  - mcc_allowlist│  └──────────────┘ └───────────────────────┘
└──────┬──────────┘
       │
┌──────▼──────────────────────────────────────────────────────┐
│                  Alibaba Cloud Layer                         │
│  PAI-EAS (Spending Classifier) │ OpenSearch (Benefits)      │
│  SLS Log Service (Audit Trail) │ OSS (Model Artefacts)      │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow Summary

1. **Transaction Ingest**: TNG transaction history pulled on onboarding + incremental sync daily
2. **Classification**: Transactions sent to Alibaba Cloud PAI-EAS → tagged as Essential / Discretionary / Savings
3. **Score Computation**: AWS Lambda aggregates classified spend → computes daily burn rate → derives Survival Score
4. **Nudge Generation**: AWS Bedrock generates personalised nudge copy based on user's top discretionary spend category
5. **Loan Application**: Lambda calls CTOS API + aggregates TNG features → invokes SageMaker model → returns decision
6. **Disbursal**: Approved loan creates restricted sub-balance on TNG Visa Card with MCC allowlist enforced at card processor
7. **Audit**: All credit decisions logged to Alibaba Cloud SLS with anonymised feature vectors (PDPA-compliant)

---

## 5. Feature Specification

### 5.1 Survival Score

| Attribute | Detail |
|---|---|
| **Definition** | `(current_wallet_balance + accessible_savings) ÷ daily_burn_rate` |
| **daily_burn_rate** | Rolling 30-day average of essential spending ÷ 30 |
| **Update frequency** | Recalculated on every TNG transaction + daily at 00:00 |
| **Display** | "You can survive **X days** if you lose your income today" |
| **Colour coding** | Green: >30 days │ Amber: 15–30 days │ Red: <15 days |
| **Trend indicator** | Week-on-week delta shown (↑ improving / ↓ declining) |

### 5.2 Emergency Mode

| Attribute | Detail |
|---|---|
| **Trigger** | Manual user activation (self-declared emergency) |
| **Dashboard shows** | Survival countdown by day, daily burn rate, essential vs discretionary breakdown |
| **Nudges** | 2x daily — morning and evening — with specific RM/day savings suggestions |
| **ECL eligibility check** | Auto-triggered when Survival Score < 5 days |
| **Exit condition** | User manually deactivates, or new income transaction detected (> RM500 single inflow) |

### 5.3 Emergency Credit Lifeline (ECL)

| Attribute | Detail |
|---|---|
| **Loan amounts** | RM100, RM150, or RM200 (tiered by credit score) |
| **Decision time** | ≤ 30 seconds |
| **Disbursal** | To TNG Visa Card restricted sub-balance — immediate |
| **Repayment** | Weekly micro-deductions from TNG wallet top-ups (e.g., RM15/week over 10 weeks for RM150) |
| **Interest** | Zero interest for first loan. Small service fee (RM5) for subsequent loans. |
| **First loan eligibility** | Survival Score triggered Emergency Mode + 60 days of TNG transaction history |

### 5.4 Daily Nudge System

| Attribute | Detail |
|---|---|
| **Frequency** | Once daily (morning, 8am) |
| **Content** | Personalised to top discretionary category. Example: *"You spent RM42 on Grab this week. Cutting 2 orders = +3 survival days."* |
| **Generation** | AWS Bedrock (Claude Haiku) with user's spending profile as context |
| **Habit loop** | User taps to acknowledge — acknowledgement streak tracked and celebrated |

### 5.5 Government Benefits Checker (Nice-to-Have)

| Attribute | Detail |
|---|---|
| **Data source** | Alibaba Cloud OpenSearch index of B40 benefits (Bantuan Rahmah, STR, e-Kasih) |
| **Matching** | User income tier + age + household size → eligible benefits surfaced |
| **Display** | Card in Emergency Mode: *"You may be eligible for Bantuan Rahmah RM200 — tap to apply"* |

---

## 6. AI & ML Specification

### 6.1 Spending Classifier (Alibaba Cloud PAI-EAS)

**Purpose**: Tag every TNG transaction as Essential, Discretionary, or Savings

**Model type**: Fine-tuned text classification model (multilingual BERT or lightweight transformer)

**Why Alibaba PAI**: The model must understand Malaysian-specific merchant names — `kedai runcit`, `pasar malam`, `mamak`, `restoran nasi kandar`. A Western-trained model will misclassify these. The Alibaba PAI model is fine-tuned on SEA/MY transaction data.

**Input features**:
- Merchant name (raw string)
- Transaction amount
- Time of day / day of week
- MCC code (where available)

**Output**: `{ category: "Essential" | "Discretionary" | "Savings", confidence: 0.0–1.0 }`

**Training data** (for hackathon): Synthetic dataset of 10,000 labelled TNG-style transactions covering common Malaysian merchant names across categories.

**Fallback**: If PAI-EAS is unavailable, Lambda falls back to a rule-based classifier using a hardcoded merchant keyword list.

### 6.2 Nudge Generator (AWS Bedrock — Claude Haiku)

**Purpose**: Generate personalised, actionable daily nudge messages

**Prompt template**:
```
System: You are SurvivAI, a financial survival coach for Malaysian B40 users.
Generate a single, empathetic nudge in Bahasa Malaysia or English (match user preference).
Keep it under 25 words. Be specific and actionable. Never shame.

User context:
- Top discretionary category this week: {category} (RM{amount})
- Current survival score: {days} days
- Trend: {improving|declining}

Generate one nudge message.
```

**Output**: Plain string nudge message, max 25 words.

### 6.3 Credit Scoring Model (AWS SageMaker — XGBoost)

See Section 7 for full specification.

---

## 7. Credit Scoring Mechanism

### 7.1 Data Sources

| Source | Data Points | Weight |
|---|---|---|
| **CTOS Thin-File API** | Existing credit enquiries, CCRIS status, negative records flag | 30% |
| **TNG Top-Up Regularity** | Frequency and consistency of wallet top-ups over 90 days | 20% |
| **TNG Utility Payment History** | Tenaga, Air Selangor, Unifi paid via TNG (consistency signal) | 20% |
| **Spending Volatility** | Standard deviation of weekly spend (high variance = risk) | 15% |
| **Essential Spend Ratio** | % of spend on essentials vs discretionary over 90 days | 10% |
| **Survival Score Trajectory** | Improving vs declining over past 30 days | 5% |

### 7.2 CTOS Integration

```
CTOS B2B API Endpoint: POST https://api.ctos.com.my/v1/individual/check
Request: { nric: <hashed_nric>, consent_token: <user_consent_id> }
Response: {
  score_band: "A" | "B" | "C" | "D" | "NR",  // NR = No Record (thin file)
  negative_flag: boolean,
  enquiry_count_12m: integer
}
```

**Consent flow**: Before any CTOS call, user must explicitly consent via in-app screen. Consent token stored with timestamp. User can decline — scoring falls back to TNG-only signals with slightly reduced loan ceiling (RM100 max vs RM200).

### 7.3 Feature Engineering

```python
features = {
  "ctos_score_band_encoded":   encode(ctos.score_band),   # A=5, B=4, C=3, D=2, NR=1
  "ctos_negative_flag":        int(ctos.negative_flag),   # 0 or 1
  "topup_frequency_90d":       count(topups, last_90d),
  "topup_consistency_score":   regularity_score(topups),  # 0–1, based on weekly variance
  "utility_payments_90d":      count(utility_txns, last_90d),
  "utility_payment_rate":      utility_paid / utility_expected,
  "spend_volatility":          std_dev(weekly_totals, last_90d),
  "essential_spend_ratio":     essential_total / total_spend,
  "survival_score_delta_30d":  current_score - score_30d_ago,
}
```

### 7.4 Model Output

```python
output = {
  "decision":     "APPROVE" | "DECLINE",
  "loan_amount":  100 | 150 | 200,   # 0 if DECLINE
  "risk_tier":    "LOW" | "MEDIUM" | "HIGH",
  "top_factors":  [str, str, str]    # Top 3 explainable factors shown to user
}
```

### 7.5 Explainability (BNM Requirement)

Every decision shows the user the top 3 contributing factors:
- ✅ *"Regular weekly top-ups (+)"*
- ✅ *"Electricity bill paid consistently (+)"*
- ⚠️ *"High food delivery spending (-)"*

This is not a black box. XGBoost SHAP values drive the factor labels. This satisfies BNM's fair lending transparency expectations.

---

## 8. MCC-Locked Disbursal System

### 8.1 Concept

Upon loan approval, RM150 (example) is added to the user's TNG Visa Card as a **restricted sub-balance**, separate from their main wallet balance. The card processor enforces an MCC allowlist: any transaction attempted against the restricted sub-balance at a non-allowed MCC is declined at POS.

### 8.2 Allowed MCC Codes

| MCC | Category | Example Merchants |
|---|---|---|
| 5411 | Grocery Stores & Supermarkets | Giant, Aeon, Mydin, Econsave |
| 5541 | Service Stations (Fuel) | Petronas, Shell, BHPetrol, Caltex |
| 5912 | Drug Stores & Pharmacies | Watson's, Guardian, farmasi kerajaan |
| 4900 | Utilities (Electric, Gas, Water) | Tenaga, Air Selangor, Syabas |
| 5441 | Sundry/Provision Stores | Kedai runcit, 7-Eleven (food items) |
| 5812 | Eating Places — Essential Only | Mamak, hawker stalls (≤ RM15 txn cap) |

### 8.3 Blocked MCC Examples

| MCC | Category |
|---|---|
| 5965 | Online Marketplaces (Shopee, Lazada) |
| 7995 | Gambling Establishments |
| 5734 | Electronics / Computer Stores |
| 5691 | Clothing Stores |
| 7832 | Motion Picture Theatres |

### 8.4 Implementation Note

For the hackathon MVP, MCC enforcement is **simulated at the API layer** — the Lambda function checks the MCC of an incoming transaction request against the allowlist and returns approve/decline. In production, this would be implemented at the card processor (Visa/TNG card issuing infrastructure) level.

---

## 9. Tech Stack

| Layer | Technology | Justification |
|---|---|---|
| **Frontend** | React Native / TNG MiniApp SDK | Native TNG integration; no separate app download needed |
| **API Gateway** | AWS API Gateway | Serverless, scales to TNG's 24M user base |
| **Core Lambda** | AWS Lambda (Node.js 20) | Survival Score, Emergency Mode, nudge orchestration |
| **Credit Lambda** | AWS Lambda (Python 3.11) | Credit scoring, CTOS API, SageMaker invoke |
| **LLM Nudges** | AWS Bedrock — Claude Haiku | Fast, cheap, Malay-language capable |
| **Credit Model** | AWS SageMaker — XGBoost | Explainable, auditable, BNM-defensible |
| **Primary DB** | AWS DynamoDB | Low-latency key-value, serverless, scales instantly |
| **Spending Classifier** | Alibaba Cloud PAI-EAS | SEA/MY merchant name fine-tuning; real-time inference |
| **Benefits Search** | Alibaba Cloud OpenSearch | Full-text + structured search on government benefit data |
| **Audit Log** | Alibaba Cloud SLS | Immutable, PDPA-compliant credit decision logging |
| **Model Artefacts** | Alibaba Cloud OSS | Store trained PAI model files |
| **External API** | CTOS B2B Data API | Thin-file credit signals for B40 users |

---

## 10. Cloud Architecture — AWS

### Services & Roles

| Service | Role | Why Not Decorative |
|---|---|---|
| **API Gateway** | Single entry point for all client requests | Rate limiting, auth, request routing — load-bearing |
| **Lambda (Core)** | Survival Score computation, Emergency Mode logic | Core business logic — cannot be removed |
| **Lambda (Credit)** | Credit feature engineering, CTOS orchestration, SageMaker invoke | Core credit decisioning — cannot be removed |
| **Bedrock (Claude Haiku)** | Daily nudge generation | Real LLM inference — not a static template |
| **SageMaker** | XGBoost credit scoring model serving | Real ML inference — drives loan decision |
| **DynamoDB** | All persistent state: users, transactions, loans, MCC lists | Primary database — not a cache |

### IAM Roles Required (Hackathon Setup)

```
LambdaCoreRole:    AmazonDynamoDBFullAccess, AmazonBedrockFullAccess
LambdaCreditRole:  AmazonDynamoDBFullAccess, AmazonSageMakerFullAccess
SageMakerRole:     AmazonS3ReadOnlyAccess (for model artefacts)
```

---

## 11. Cloud Architecture — Alibaba Cloud

### Services & Roles

| Service | Role | Why Not Decorative |
|---|---|---|
| **PAI-EAS** | Serve the spending classifier model (needs/wants tagger) | Real ML inference serving — core to Survival Score pipeline |
| **OpenSearch** | B40 government benefit eligibility matching | Full-text search on benefit eligibility rules — not achievable with DynamoDB |
| **SLS (Log Service)** | PDPA-compliant immutable audit trail for all credit decisions | Required for BNM compliance — cannot be done in AWS without extra cost |
| **OSS** | Store PAI model artefacts and training data | Object storage for ML pipeline — separation of compute and storage |

### PAI-EAS Endpoint Contract

```
POST https://<endpoint>.eas.aliyuncs.com/api/predict/spending_classifier
Headers: { "Authorization": "Bearer <token>" }
Body: {
  "merchant_name": "Giant Hypermarket Shah Alam",
  "amount": 45.80,
  "time_hour": 18,
  "mcc": "5411"
}
Response: {
  "category": "Essential",
  "confidence": 0.97,
  "subcategory": "Grocery"
}
```

---

## 12. API Contracts

### 12.1 GET /survival-score

```
Request:  { user_id: string }
Response: {
  survival_days: integer,
  daily_burn_rate: float,        // RM per day
  wallet_balance: float,
  trend_7d: "improving" | "stable" | "declining",
  color_band: "green" | "amber" | "red",
  top_discretionary: { category: string, amount_7d: float }
}
```

### 12.2 POST /emergency-mode

```
Request:  { user_id: string, action: "activate" | "deactivate" }
Response: {
  status: "active" | "inactive",
  survival_countdown: [{ day: integer, projected_balance: float }],  // 14-day projection
  ecl_eligible: boolean,
  benefits_available: [{ name: string, amount: float, apply_url: string }]
}
```

### 12.3 POST /ecl/apply

```
Request:  { user_id: string, ctos_consent: boolean }
Response: {
  decision: "APPROVE" | "DECLINE",
  loan_amount: float,
  risk_tier: string,
  top_factors: [string, string, string],
  repayment_schedule: [{ week: integer, amount: float }],
  disbursed_to: "TNG_VISA_RESTRICTED"
}
```

### 12.4 POST /ecl/transaction-check

```
Request:  { user_id: string, merchant_mcc: string, amount: float }
Response: {
  allowed: boolean,
  reason: string | null,          // null if allowed; "MCC not in essential list" if blocked
  restricted_balance_remaining: float
}
```

---

## 13. Database Schema

### DynamoDB Tables

**users**
```json
{
  "user_id": "string (PK)",
  "name": "string",
  "ic_hash": "string (SHA-256 of NRIC)",
  "income_tier": "B40 | M40",
  "emergency_mode_active": "boolean",
  "survival_score": "number",
  "daily_burn_rate": "number",
  "onboarded_at": "ISO8601",
  "ctos_consent": "boolean",
  "ctos_consent_timestamp": "ISO8601"
}
```

**transactions** (partition key: user_id, sort key: timestamp)
```json
{
  "user_id": "string (PK)",
  "timestamp": "ISO8601 (SK)",
  "merchant_name": "string",
  "amount": "number",
  "mcc": "string",
  "category": "Essential | Discretionary | Savings",
  "category_confidence": "number",
  "source": "TNG_WALLET | TNG_VISA"
}
```

**loans**
```json
{
  "loan_id": "string (PK)",
  "user_id": "string (GSI)",
  "amount": "number",
  "status": "ACTIVE | REPAID | DEFAULTED",
  "disbursed_at": "ISO8601",
  "restricted_balance_remaining": "number",
  "repayment_schedule": "[{week, amount, status}]",
  "credit_score_snapshot": "object",
  "top_factors": "[string]"
}
```

**mcc_allowlist**
```json
{
  "mcc_code": "string (PK)",
  "category": "string",
  "description": "string",
  "txn_cap_rm": "number | null"
}
```

---

## 14. Compliance & Privacy

### PDPA Compliance

| Requirement | Implementation |
|---|---|
| **Consent before data use** | Explicit consent screen on onboarding covers transaction analysis. Separate consent screen before CTOS API call. |
| **Data minimisation** | Raw transaction strings not stored on Alibaba Cloud — only aggregated feature vectors |
| **Right to withdraw** | User can deactivate SurvivAI module and request data deletion from settings |
| **Data residency** | User PII stays in AWS ap-southeast-1 (Singapore). Alibaba Cloud receives only anonymised feature vectors. |
| **Audit trail** | All credit decisions logged to Alibaba Cloud SLS with anonymised ID — no NRIC, no name |

### BNM Compliance

| Concern | Position |
|---|---|
| **Micro-lending licence** | SurvivAI facilitates access to TNG Digital's **existing licensed e-money and prepaid card credit facility** — it is not an independent lender. All credit is extended under TNG's existing BNM licence. |
| **Fair lending** | XGBoost + SHAP explainability satisfies fair lending transparency. Decision factors shown to user in plain language. |
| **Credit bureau reporting** | Repayment history reported back to CTOS to build B40 users' credit profiles over time. |
| **Regulatory sandbox** | If a full standalone lending product is pursued post-hackathon, BNM's Regulatory Sandbox provides the pathway. |

---

## 15. MVP Scope & Prioritisation

### Must Have — Demo-Blocking (by 9am Day 2)

- [ ] Survival Score displayed from mock transaction data
- [ ] Spending classifier tagging transactions (Essential / Discretionary)
- [ ] Emergency Mode screen with countdown and daily burn
- [ ] ECL application flow — mock CTOS response + TNG signals → approval/decline
- [ ] MCC-locked card screen showing restricted balance + allowed/blocked transaction simulation
- [ ] AWS Lambda endpoints for all above
- [ ] DynamoDB seeded with Siti's demo data

### Should Have — Demo-Enhancing

- [ ] Daily nudge generated by AWS Bedrock (live call)
- [ ] Repayment schedule displayed post-approval
- [ ] Trend chart on Survival Score (7-day history)

### Nice to Have — If Time Allows

- [ ] Alibaba Cloud PAI-EAS live call (vs fallback classifier)
- [ ] Government benefits checker via OpenSearch
- [ ] Spend lock warning on non-essential transaction attempts

---

## 16. Implementation Plan

### Team Role Assignments

| Role | Responsibilities |
|---|---|
| **@frontend-dev** | TNG MiniApp UI, all screens, state management |
| **@backend-dev** | AWS Lambda functions, DynamoDB schema, API contracts |
| **@ai-dev** | Bedrock nudge integration, SageMaker model, PAI-EAS classifier |
| **@infra-dev** | AWS provisioning, Alibaba Cloud setup, deployment |

### Hour-by-Hour Build Timeline

| Window | Milestone | Owner |
|---|---|---|
| **17:00–19:00** | Repo init + CCPM setup. DynamoDB tables created. Siti's mock transaction data seeded. AWS Lambda skeleton deployed. UI scaffold: 4 screens stubbed. | Backend + Infra + Frontend |
| **19:00–21:00** | Spending classifier Lambda live (rule-based fallback). Survival Score formula working. Emergency Mode API connected to frontend. | Backend + AI |
| **21:00–23:00** | ECL application flow: feature engineering Lambda + mock CTOS response + hardcoded XGBoost stub → decision returned to frontend. MCC-locked card screen showing restricted balance. | Backend + Frontend |
| **23:00–01:00** | AWS Bedrock nudge integration live. MCC transaction check API (allowlist enforcement). Frontend ↔ Backend fully integrated for core flow. | AI + Backend + Frontend |
| **01:00–03:00** | Alibaba Cloud PAI-EAS endpoint called from Lambda (spending classifier upgrade). OpenSearch benefits lookup (if time). SLS logging wired up. | Infra + AI |
| **03:00–05:00** | Repayment schedule UI. UI polish. Edge cases (no CTOS consent path, decline flow). Demo data rehearsal. | Frontend + Backend |
| **05:00–07:00** | Demo video recorded (Siti's full journey: onboard → crisis → ECL → MCC block at Shopee). Pitch deck built (7 slides). | All |
| **07:00–08:30** | GitHub README. Submission form filled. Final demo dry run. Q&A role assignment. | All |

### Critical Path

```
DynamoDB schema  →  Survival Score Lambda  →  Frontend Score Screen
                                          ↘
CTOS mock setup  →  Credit Lambda         →  ECL Application Screen  →  MCC Card Screen
                                          ↗
Bedrock nudge    →  Nudge Lambda          →  Emergency Mode Screen
```

Bedrock nudge and MCC card screen can be parallelised after the core Lambda is working.

---

## 17. Demo Script

**Duration**: 2 minutes 30 seconds | **Presenter**: Lead + AI dev for technical Q&A

---

**[0:00–0:20] — Open with Siti (Wing's moment)**

*"This is Siti. She's 34, works in a factory in Shah Alam, earns RM1,800 a month. Right now she has RM87 in her TNG wallet. She doesn't know it, but she's 11 days away from financial collapse."*

Show: Survival Score screen. **"11 days"** in red. Daily burn rate: RM7.90/day.

---

**[0:20–0:50] — The AI Engine (Leslie's moment)**

*"SurvivAI analysed 90 days of Siti's TNG transactions. Our classifier — running on Alibaba Cloud PAI, trained on Malaysian merchant data — tagged every transaction: Giant is Essential, Grab is Discretionary, kedai runcit is Essential."*

Show: Transaction list with category tags animating in. Pie chart: 62% Essential / 38% Discretionary.

*"The Survival Score is live. Every new transaction updates it in real time."*

---

**[0:50–1:20] — Crisis Hits**

*"Today, Siti was laid off."*

Tap Emergency Mode. Screen transitions to red survival dashboard.

*"Day 3. Her score drops to 4 days. SurvivAI offers her a lifeline."*

Show ECL prompt. Siti taps Apply. 30-second animation.

*"Our model fused her CTOS thin-file with 90 days of TNG behavioural data — top-up regularity, utility payments, spending volatility. Decision in under 30 seconds: approved. RM150."*

Show approval screen with top 3 factors.

---

**[1:20–1:50] — The MCC Lock (Enshu's moment)**

*"But here's what makes this responsible lending, not reckless lending."*

Show TNG Visa Card with restricted balance: **RM150 — Essential Spend Only**.

Siti taps to buy groceries at Giant. ✅ **Approved.**

Siti taps to buy from Shopee. ❌ **Declined. This balance is for essentials only.**

*"Every ringgit goes to rice and fuel — not Shopee. The MCC allowlist is enforced at the card processor layer."*

---

**[1:50–2:20] — The Bigger Picture**

*"Siti repays RM15/week from her next top-ups. For the first time, she has a credit history. Next time her limit is RM200. In Year 2, one million B40 users build credit profiles through SurvivAI — closing Malaysia's credit invisibility gap."*

Show Year 2 vision slide: credit history growth curve.

---

**[2:20–2:30] — Close**

*"SurvivAI. Because knowing you have 11 days is the first step to having 30."*

---

## 18. Judging Criteria Alignment

| Criterion | How We Win It | Judge |
|---|---|---|
| **AI & Intelligent Systems** | Two distinct AI mechanisms: (1) Alibaba PAI-EAS spending classifier fine-tuned on Malaysian merchant data, (2) AWS SageMaker XGBoost credit scorer fusing CTOS + TNG behavioural features. Plus Bedrock LLM for nudge generation. All three are purposeful — none decorative. | Leslie |
| **Technical Implementation** | Serverless AWS stack (Lambda + API Gateway + DynamoDB), MCC-locked card sub-balance (production-architecture pattern), CTOS B2B API integration, SHAP explainability on credit decisions. Ambitious and functional for 24 hours. | Leslie |
| **Multi-Cloud Service Usage** | AWS: API Gateway + Lambda + Bedrock + SageMaker + DynamoDB — core compute and ML. Alibaba Cloud: PAI-EAS (AI inference) + OpenSearch (benefit search) + SLS (compliance audit). Both clouds serve non-substitutable roles. | Enshu |
| **Impact & Feasibility** | Named persona (Siti). Addresses 5.8M B40 households. Extends survival by 6–8 days per emergency. Responsible MCC-locked lending. Repayment builds credit history — long-term poverty gap reduction. TNG's 24M users are the distribution moat. | Wing + Leslie |
| **Presentation & Teamwork** | Demo opens with Siti's story (not architecture). Live functional demo — not Figma. Clear one-sentence value prop. Compliance addressed proactively. Year 2 vision closes the pitch. | Wing |

---

## 19. Year 2 Roadmap

| Phase | Timeline | What Ships |
|---|---|---|
| **Hackathon MVP** | Apr 2026 | Survival Score, Emergency Mode, ECL with MCC lock, Bedrock nudges |
| **Beta (TNG Pilot)** | Q3 2026 | Live CTOS integration, real SageMaker model trained on TNG data, 10K B40 users |
| **Scale** | Q1 2027 | 100K users, repayment data fed back to CTOS for credit history building, ECL limit increases |
| **Ecosystem** | Q3 2027 | Partner with Bank Rakyat / BSN to convert SurvivAI credit history into formal micro-loan products. 1M B40 users with verifiable credit profiles. |
| **Policy Impact** | 2028 | BNM partnership — SurvivAI data used to inform B40 financial resilience policy. Potential mandatory TNG integration. |

**The long game**: Every B40 user who repays an ECL builds a credit history. After 3 cycles, they have enough history to access formal financial products. SurvivAI is not just a survival tool — it is the **credit onramp** for Malaysia's credit-invisible population.

---

*Document prepared for TNGD FinHack 2026 | SurvivAI Team | 25 April 2026*
*All CTOS API details are illustrative — confirm B2B API access with CTOS directly.*
*Cloud service names and endpoint formats are correct as of April 2026.*
