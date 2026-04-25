# SurvivAI — Technical Spec Sheet

**Version**: 3.0 | **Date**: 25 April 2026 | **Hackathon**: TNGD FinHack 2026
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

| Stage               | Event                                | SurvivAI Response                                                               |
| ------------------- | ------------------------------------ | ------------------------------------------------------------------------------- |
| **Onboarding**      | Siti installs SurvivAI module in TNG | Analyses 90-day transaction history. Computes first Survival Score: **11 days** |
| **Daily Use**       | Morning routine                      | Nudge: _"Skip one Grab order today = +2 survival days"_                         |
| **Crisis Trigger**  | Siti is laid off                     | She taps Emergency Mode. Survival countdown begins. Daily burn shown.           |
| **Day 3 of Crisis** | Survival Score drops to 4 days       | App prompts: _"You may qualify for an Emergency Credit Lifeline"_               |
| **Application**     | Siti applies with one tap            | AI credit scorer runs in 30 seconds: CTOS thin-file + 90-day TNG signals        |
| **Approval**        | RM150 approved                       | Disbursed to TNG Visa Card as a **restricted sub-balance**                      |
| **Spending**        | Siti buys groceries at Giant         | Transaction goes through. She tries Shopee — **card declined at POS**           |
| **Recovery**        | Siti gets new job                    | Repayment: RM15/week auto-deducted from TNG wallet top-ups over 10 weeks        |
| **Credit History**  | Repayment complete                   | Positive repayment record stored. Next ECL eligibility increases.               |

---

## 4. System Architecture

### 4.1 Multi-Cloud Domain Separation

The architecture follows a strict **one cloud = one concern domain** principle. AI/ML is not distributed across both clouds — all model serving is consolidated on Alibaba Cloud PAI-EAS. AWS owns all user-facing compute, business logic, and data persistence. This is the correct multi-cloud pattern: each provider does what it does best, with a clean API boundary between them.

```
┌──────────────────────────────────────────────────────────────┐
│               Flutter Client (iOS · Android · TNG MiniApp)   │
│                    Dart · HTTPS/REST                         │
└─────────────────────────┬────────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────────┐
│          AWS — ap-southeast-1 (Singapore)                    │
│          Compute · data persistence · auth · nudge templates │
│                                                              │
│  ┌───────────────────────────────────────────────────────┐   │
│  │           API Gateway                                 │   │
│  │    Rate limiting · JWT auth · request routing         │   │
│  └──────────┬────────────────────────┬──────────────────┘   │
│             │                        │                       │
│  ┌──────────▼──────────┐  ┌──────────▼──────────────────┐   │
│  │  Lambda — core      │  │  Lambda — credit engine      │   │
│  │  Survival score     │  │  CTOS call · feature eng.    │   │
│  │  Emergency mode     │  │  Loan decision · MCC disburse│   │
│  │  Nudge orchestration│  └──────────────────────────────┘   │
│  └──────────┬──────────┘                                     │
│             │                                                 │
│  ┌──────────▼──────────┐  ┌──────────────────────────────┐   │
│  │  DynamoDB           │  │  Secrets Manager             │   │
│  │  users · txns       │  │  PAI-EAS token · CTOS key    │   │
│  │  loans · MCC list   │  │  Rotation-ready              │   │
│  └─────────────────────┘  └──────────────────────────────┘   │
│                                                              │
│  → Feature vectors cross to Alibaba Cloud PAI-EAS           │
│    via EAS Dedicated Gateway (IP-whitelisted)               │
└──────────────────────────────────────────────────────────────┘
          │ Feature vectors only — no PII crosses this boundary
          │ EAS Dedicated Gateway endpoint (stable, versioned)
┌─────────▼────────────────────────────────────────────────────┐
│          Alibaba Cloud — ap-southeast-1 (Singapore)          │
│          All AI/ML serving · compliance audit trail          │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  EAS Dedicated Gateway                              │     │
│  │  Stable endpoint · IP whitelist · canary releases   │     │
│  └──────────┬──────────────────────────┬──────────────┘     │
│             │                          │                     │
│  ┌──────────▼──────────┐  ┌────────────▼────────────────┐   │
│  │  PAI-EAS            │  │  PAI-EAS                    │   │
│  │  Spending classifier│  │  Credit scorer (XGBoost)    │   │
│  │  MY merchant tagging│  │  CTOS + TNG feature fusion  │   │
│  └──────────┬──────────┘  └────────────┬────────────────┘   │
│             │                          │                     │
│  ┌──────────▼──────────────────────────▼────────────────┐   │
│  │  SLS — Unified Audit Trail                           │   │
│  │  Ingests: PAI-EAS inference logs (co-located)        │   │
│  │           Lambda Credit logs (via LoongCollector)    │   │
│  │  Full credit decision chain in one immutable store   │   │
│  │  PDPA-compliant · anonymised IDs · no NRIC/name     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────┐  ┌────────────────────────────┐   │
│  │  OpenSearch          │  │  OSS                       │   │
│  │  B40 benefits lookup │  │  Model artefacts · training│   │
│  └──────────────────────┘  └────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

### 4.2 Why This Split

| Decision                                        | Rationale                                                                                                                                                                                                                                                              |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| All ML serving on Alibaba Cloud PAI-EAS         | Consolidates inference in one place. Malaysian merchant data fine-tuning is native to Alibaba Cloud's SEA infrastructure. Avoids scattered AI across two clouds.                                                                                                       |
| Audit trail on Alibaba Cloud SLS (not AWS)      | SLS is co-located with PAI-EAS — the most compute-intensive layer. Credit scoring inference + audit log belong together. Cross-cloud audit logging adds latency and cost for no gain.                                                                                  |
| AWS Bedrock removed                             | Nudge generation uses a bilingual template engine inside Lambda Core — no external LLM call. Bedrock is the Year 2 upgrade path at 100K+ users where personalisation across 50+ regional sub-categories justifies generative capability.             |
| AWS SageMaker removed                           | Replaced by PAI-EAS. Running two separate ML hosting platforms (SageMaker + PAI) for the same problem was the original anti-pattern. One platform, one place.                                                                                                          |
| Flutter replaces React Native / TNG MiniApp SDK | Flutter supports iOS, Android, and web from a single Dart codebase. TNG MiniApp can be packaged as a Flutter WebView embed. Cross-platform without code duplication.                                                                                                   |
| No PII crosses cloud boundary                   | Lambda sends only feature vectors (numbers) to PAI-EAS, never raw transaction strings, NRIC, or names. Raw merchant names sent to the spending classifier carry no user identifiers. PDPA data residency maintained.                                                   |
| Inline try/catch fallback (no circuit breaker)  | PAI-EAS exceptions caught inline in Lambda Core. On failure, the same invocation runs the keyword-based rule classifier. Eliminates the health check Lambda, CloudWatch alarm, and any DynamoDB flag.                                                |

### 4.3 Data Flow — Path A: Survival Score (Synchronous Classification)

```
Flutter → API Gateway → Lambda Core
       → [fetch 90d pre-classified transactions from DynamoDB]
         (categories written synchronously when each transaction was ingested)
       → [compute: daily_burn = avg(essential_spend) / 30]
       → [compute: survival_days = wallet_balance / daily_burn]
       → [Template Engine: select EN/BM template for top discretionary category + compute savings delta]
       → API response → Flutter renders Survival Score UI

On new TNG transaction write (same Lambda invocation, synchronous):
       try:
         → [send merchant name + amount to PAI-EAS via EAS Dedicated Gateway]
           ← [receive Essential / Discretionary / Savings tag + confidence]
       catch (PAI-EAS timeout or error):
         → [rule-based fallback: keyword list classification — same execution, no queue]
       → [DynamoDB: write category + confidence to transaction record]

Production scaling note: replace synchronous classification with an SQS queue +
consumer Lambda when transaction volume justifies async decoupling.
```

### 4.4 Data Flow — Path B: Emergency Credit Lifeline (Synchronous)

```
Flutter (user consents) → API Gateway → Lambda Credit
       → [Secrets Manager: fetch CTOS API key]
       → [CTOS API: fetch thin-file signal]
       → [DynamoDB: aggregate 90d TNG transaction features]
       → [PAI-EAS credit scorer via EAS Dedicated Gateway: XGBoost inference on feature vector]
       ← [decision: APPROVE RM150 / DECLINE, top 3 SHAP factors]
       → [SLS: log decision + anonymised feature vector — PDPA compliant]
         (LoongCollector agent on Lambda ships structured log to SLS Logstore)
       → [DynamoDB: write loan record, MCC-locked sub-balance]
       → API response → Flutter shows approval + restricted card balance
```

### 4.5 PAI-EAS Fallback — Inline Try/Catch

```
Lambda Core (on transaction write):
  try:
    → POST to EAS Dedicated Gateway (spending classifier)
    ← receive category + confidence
  catch (timeout | connection error | non-200 response):
    → run keyword-based rule classifier (hardcoded merchant list)
    → set confidence = 0.0 to signal fallback was used
  → DynamoDB: write category + confidence to transaction record

Lambda Credit (on ECL application):
  try:
    → POST to EAS Dedicated Gateway (credit scorer)
    ← receive decision + SHAP factors
  catch (timeout | connection error | non-200 response):
    → return DECLINE with reason "scoring service unavailable — please retry"
    → log error to CloudWatch for alerting
```

---

## 5. Feature Specification

### 5.1 Survival Score

| Attribute            | Detail                                                            |
| -------------------- | ----------------------------------------------------------------- |
| **Definition**       | `(current_wallet_balance + accessible_savings) ÷ daily_burn_rate` |
| **daily_burn_rate**  | Rolling 30-day average of essential spending ÷ 30                 |
| **Update frequency** | Recalculated on every TNG transaction + daily at 00:00            |
| **Display**          | "You can survive **X days** if you lose your income today"        |
| **Colour coding**    | Green: >30 days │ Amber: 15–30 days │ Red: <15 days               |
| **Trend indicator**  | Week-on-week delta shown (↑ improving / ↓ declining)              |

### 5.2 Emergency Mode

| Attribute                 | Detail                                                                                |
| ------------------------- | ------------------------------------------------------------------------------------- |
| **Trigger**               | Manual user activation (self-declared emergency)                                      |
| **Dashboard shows**       | Survival countdown by day, daily burn rate, essential vs discretionary breakdown      |
| **Nudges**                | 2x daily — morning and evening — with specific RM/day savings suggestions             |
| **ECL eligibility check** | Auto-triggered when Survival Score < 5 days                                           |
| **Exit condition**        | User manually deactivates, or new income transaction detected (> RM500 single inflow) |

### 5.3 Emergency Credit Lifeline (ECL)

| Attribute                  | Detail                                                                                    |
| -------------------------- | ----------------------------------------------------------------------------------------- |
| **Loan amounts**           | RM100, RM150, or RM200 (tiered by credit score)                                           |
| **Decision time**          | ≤ 30 seconds                                                                              |
| **Disbursal**              | To TNG Visa Card restricted sub-balance — immediate                                       |
| **Repayment**              | Weekly micro-deductions from TNG wallet top-ups (e.g., RM15/week over 10 weeks for RM150) |
| **Interest**               | Zero interest for first loan. Small service fee (RM5) for subsequent loans.               |
| **First loan eligibility** | Survival Score triggered Emergency Mode + 60 days of TNG transaction history              |

### 5.4 Nudge System (Twice Daily)

| Attribute              | Detail                                                                                                                                                                              |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Frequency**          | Twice daily — morning (8am) and evening (8pm)                                                                                                                                       |
| **Morning nudge**      | Top discretionary category + weekly RM amount + survival days saved. Example: _"You spent RM42 on Grab this week. Cutting 2 orders = +3 survival days."_                            |
| **Evening nudge**      | Day's spending recap + projected survival delta. Example: _"You spent RM18 today. At this rate, your runway is 9 days. Tomorrow's target: under RM12."_                             |
| **Emergency Mode**     | Same slots, elevated urgency. Morning: category savings. Evening: tomorrow's projected burn rate vs current runway.                                                                 |
| **Generation**         | Bilingual template engine (EN + BM) inside Lambda Core. Category + weekly amount + survival-days delta injected into pre-written template strings. No external API call.            |
| **Languages**          | English and Bahasa Malaysia. User language preference stored in `users` DynamoDB table.                                                                                             |
| **Categories covered** | food_delivery · ride_hailing · cafes · entertainment · online_shopping · subscriptions · clothing · other_discretionary                                                             |
| **Habit loop**         | User taps to acknowledge — acknowledgement streak tracked and celebrated                                                                                                            |
| **Demo integration**   | Siti's seed data ships with a pre-delivered morning nudge. A `?demo_nudge=evening` URL param fires the evening template inline — presenter triggers during demo, no timing required |

### 5.5 Government Benefits Checker (Nice-to-Have)

| Attribute       | Detail                                                                                  |
| --------------- | --------------------------------------------------------------------------------------- |
| **Data source** | Alibaba Cloud OpenSearch index of B40 benefits (Bantuan Rahmah, STR, e-Kasih)           |
| **Matching**    | User income tier + age + household size → eligible benefits surfaced                    |
| **Display**     | Card in Emergency Mode: _"You may be eligible for Bantuan Rahmah RM200 — tap to apply"_ |

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

### 6.2 Nudge Template Engine (Lambda Core — inline)

**Purpose**: Generate personalised, actionable daily nudge messages with zero external API dependency.

**Implementation**: Pure JavaScript inside Lambda Core. No external call, no cold-start risk, no API cost.

**Template structure**:

```javascript
const NUDGE_TEMPLATES = {
  en: {
    food_delivery: (amt, days) =>
      `You spent RM${amt} on food delivery this week. Cutting 2 orders saves +${days} survival days.`,
    ride_hailing: (amt, days) =>
      `RM${amt} on rides this week. Taking the bus twice could save +${days} days.`,
    cafes: (amt, days) =>
      `RM${amt} on cafes this week. Brewing at home 3 days saves +${days} days.`,
    entertainment: (amt, days) =>
      `RM${amt} on entertainment this week. One less outing = +${days} survival days.`,
    online_shopping: (amt, days) =>
      `RM${amt} on shopping this week. Waiting 48hrs before buying saves +${days} days.`,
    subscriptions: (amt, days) =>
      `RM${amt} in subscriptions this month. Pausing one saves +${days} days.`,
    clothing: (amt, days) =>
      `RM${amt} on clothing this week. One less purchase = +${days} survival days.`,
    other_discretionary: (amt, days) =>
      `RM${amt} in discretionary spend this week. Small cuts could add +${days} days.`,
  },
  bm: {
    food_delivery: (amt, days) =>
      `Anda belanja RM${amt} untuk penghantaran makanan minggu ini. Kurangkan 2 pesanan = +${days} hari survival.`,
    ride_hailing: (amt, days) =>
      `RM${amt} untuk pengangkutan minggu ini. Naik bas dua kali jimat +${days} hari.`,
    cafes: (amt, days) =>
      `RM${amt} di kafe minggu ini. Buat kopi sendiri 3 hari jimat +${days} hari.`,
    entertainment: (amt, days) =>
      `RM${amt} untuk hiburan minggu ini. Kurangkan satu aktiviti = +${days} hari survival.`,
    online_shopping: (amt, days) =>
      `RM${amt} membeli-belah minggu ini. Tunggu 48 jam sebelum beli jimat +${days} hari.`,
    subscriptions: (amt, days) =>
      `RM${amt} dalam langganan bulan ini. Tangguh satu jimat +${days} hari.`,
    clothing: (amt, days) =>
      `RM${amt} untuk pakaian minggu ini. Satu pembelian kurang = +${days} hari survival.`,
    other_discretionary: (amt, days) =>
      `RM${amt} perbelanjaan pilihan minggu ini. Jimat sedikit boleh tambah +${days} hari.`,
  },
};

function generateNudge(
  topCategory,
  weeklyAmount,
  survivalDaysDelta,
  lang = "en",
) {
  const template =
    NUDGE_TEMPLATES[lang][topCategory] ??
    NUDGE_TEMPLATES[lang].other_discretionary;
  return template(weeklyAmount.toFixed(0), survivalDaysDelta);
}
```

**Input**: `{ top_category, weekly_amount_rm, survival_days_delta, lang: "en" | "bm" }`

**Output**: Plain string nudge message, max 25 words. Computed entirely in-process — no network hop.

**Year 2 upgrade path**: When the user base exceeds 100K and spending patterns diversify across 50+ regional sub-categories, replace `generateNudge()` with a Bedrock call using the same input signature. The rest of the system is unchanged.

### 6.3 Credit Scoring Model (Alibaba Cloud PAI-EAS — XGBoost)

See Section 7 for full specification. The model is trained offline and deployed to PAI-EAS for real-time inference. This consolidates both AI models on one platform — PAI-EAS serves both the spending classifier and the credit scorer. Lambda (Python) calls PAI-EAS for both; there is no second ML hosting platform.

---

## 7. Credit Scoring Mechanism

### 7.1 Data Sources

| Source                          | Data Points                                                    | Weight |
| ------------------------------- | -------------------------------------------------------------- | ------ |
| **CTOS Thin-File API**          | Existing credit enquiries, CCRIS status, negative records flag | 30%    |
| **TNG Top-Up Regularity**       | Frequency and consistency of wallet top-ups over 90 days       | 20%    |
| **TNG Utility Payment History** | Tenaga, Air Selangor, Unifi paid via TNG (consistency signal)  | 20%    |
| **Spending Volatility**         | Standard deviation of weekly spend (high variance = risk)      | 15%    |
| **Essential Spend Ratio**       | % of spend on essentials vs discretionary over 90 days         | 10%    |
| **Survival Score Trajectory**   | Improving vs declining over past 30 days                       | 5%     |

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

### 7.4 Model Hosting

The XGBoost model is trained offline using scikit-learn / XGBoost and deployed to **Alibaba Cloud PAI-EAS**. This is the same serving endpoint used by the spending classifier — both models run on PAI-EAS, keeping all ML inference on one platform.

**Training** (pre-hackathon prep): Synthetic dataset of 5,000 labelled B40 user profiles. Features derived from simulated TNG transaction patterns + CTOS score bands.

**Inference call**: Lambda (Python) → PAI-EAS REST endpoint → JSON response in ~200ms.

### 7.5 Explainability (BNM Requirement)

Every decision shows the user the top 3 contributing factors:

- ✅ _"Regular weekly top-ups (+)"_
- ✅ _"Electricity bill paid consistently (+)"_
- ⚠️ _"High food delivery spending (-)"_

This is not a black box. XGBoost SHAP values drive the factor labels. This satisfies BNM's fair lending transparency expectations.

---

## 8. MCC-Locked Disbursal System

### 8.1 Concept

Upon loan approval, RM150 (example) is added to the user's TNG Visa Card as a **restricted sub-balance**, separate from their main wallet balance. The card processor enforces an MCC allowlist: any transaction attempted against the restricted sub-balance at a non-allowed MCC is declined at POS.

### 8.2 Allowed MCC Codes

| MCC  | Category                         | Example Merchants                     |
| ---- | -------------------------------- | ------------------------------------- |
| 5411 | Grocery Stores & Supermarkets    | Giant, Aeon, Mydin, Econsave          |
| 5541 | Service Stations (Fuel)          | Petronas, Shell, BHPetrol, Caltex     |
| 5912 | Drug Stores & Pharmacies         | Watson's, Guardian, farmasi kerajaan  |
| 4900 | Utilities (Electric, Gas, Water) | Tenaga, Air Selangor, Syabas          |
| 5441 | Sundry/Provision Stores          | Kedai runcit, 7-Eleven (food items)   |
| 5812 | Eating Places — Essential Only   | Mamak, hawker stalls (≤ RM15 txn cap) |

### 8.3 Blocked MCC Examples

| MCC  | Category                             |
| ---- | ------------------------------------ |
| 5965 | Online Marketplaces (Shopee, Lazada) |
| 7995 | Gambling Establishments              |
| 5734 | Electronics / Computer Stores        |
| 5691 | Clothing Stores                      |
| 7832 | Motion Picture Theatres              |

### 8.4 Implementation Note

For the hackathon MVP, MCC enforcement is **simulated at the API layer** — the Lambda function checks the MCC of an incoming transaction request against the allowlist and returns approve/decline. In production, this would be implemented at the card processor (Visa/TNG card issuing infrastructure) level.

---

## 9. Tech Stack

| Layer                   | Technology                          | Justification                                                                                                                                                                                                              |
| ----------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Frontend**            | Flutter (Dart)                      | Single codebase for iOS, Android, and TNG MiniApp WebView. Faster UI iteration than React Native for a 16-hour build.                                                                                                      |
| **API Gateway**         | AWS API Gateway                     | Serverless, scales to TNG's 24M user base. JWT auth + rate limiting at edge.                                                                                                                                               |
| **Core Lambda**         | AWS Lambda (Node.js 20)             | Survival Score, Emergency Mode, nudge dispatch, template engine, inline transaction classification                                                                                                                          |
| **Credit Lambda**       | AWS Lambda (Python 3.11)            | Credit feature engineering, CTOS API call, PAI-EAS invoke, MCC disbursal                                                                                                                                                   |
| **Primary DB**          | AWS DynamoDB                        | Low-latency key-value, serverless, scales instantly                                                                                                                                                                        |
| **Spending Classifier** | Alibaba Cloud PAI-EAS               | All ML serving consolidated here. MY merchant name fine-tuning (kedai runcit, pasar malam, mamak).                                                                                                                         |
| **Credit Scorer**       | Alibaba Cloud PAI-EAS               | XGBoost model hosted on PAI-EAS. Same platform as classifier — one ML serving layer, not two.                                                                                                                              |
| **ML Serving Gateway**  | Alibaba Cloud EAS Dedicated Gateway | Stable versioned endpoint for all cross-cloud PAI-EAS calls. IP whitelisting (Lambda NAT gateway only). Canary release support for model rollouts.                                                                         |
| **Unified Audit Trail** | Alibaba Cloud SLS                   | Co-located with PAI-EAS. Extended to ingest Lambda Credit structured logs via LoongCollector agent. Full decision chain (AWS invocation → Alibaba inference → decision outcome) in one immutable Logstore. PDPA-compliant. |
| **Benefits Search**     | Alibaba Cloud OpenSearch            | Full-text search on B40 government benefit eligibility rules                                                                                                                                                               |
| **Model Artefacts**     | Alibaba Cloud OSS                   | PAI model files + training data. OSS → PAI pipeline is native Alibaba Cloud workflow.                                                                                                                                      |
| **External API**        | CTOS B2B Data API                   | Thin-file credit signals for B40 users                                                                                                                                                                                     |

> **Removed from v1.0**: AWS SageMaker. Running SageMaker (AWS) alongside PAI-EAS (Alibaba) for the same ML serving function violated the single-domain principle. All model serving now lives on Alibaba Cloud.
>
> **Removed from v2.0**: AWS Bedrock. Nudge generation uses the bilingual template engine inside Lambda Core — no LLM call required for MVP. Bedrock is the Year 2 upgrade path at 100K+ users.

> **Removed from v1.0**: AWS SageMaker. Running SageMaker (AWS) alongside PAI-EAS (Alibaba) for the same ML serving function violated the single-domain principle. All model serving now lives on Alibaba Cloud.

---

## 10. Cloud Architecture — AWS

### Domain: Compute, Data, Auth

AWS is responsible for everything user-facing and all stateful data. It does not host any ML models and does not call any external LLM APIs.

| Service             | Role                                                                                              | Why Non-Negotiable      |
| ------------------- | ------------------------------------------------------------------------------------------------- | ----------------------- |
| **API Gateway**     | Single entry point — rate limiting, JWT auth, routing                                             | Load-bearing edge layer |
| **Lambda (Core)**   | Survival Score, Emergency Mode, nudge orchestration (template engine), inline transaction tagging | Core business logic     |
| **Lambda (Credit)** | CTOS API, feature engineering, PAI-EAS credit invoke, MCC disbursal                              | Core credit decisioning |
| **DynamoDB**        | All persistent state: users, transactions, loans, MCC allowlist                                   | Primary database        |

### What AWS Does Not Do

- **No ML model hosting** — that is Alibaba Cloud's domain
- **No audit trail** — SLS is co-located with PAI-EAS on Alibaba Cloud

### IAM Roles

```
LambdaCoreRole:    AmazonDynamoDBFullAccess
                   secretsmanager:GetSecretValue (inline policy, scoped to survivai/pai-eas-token)
LambdaCreditRole:  AmazonDynamoDBFullAccess
                   secretsmanager:GetSecretValue (inline policy, scoped to survivai/pai-eas-token + survivai/ctos-key)
```

---

## 11. Cloud Architecture — Alibaba Cloud

### Domain: All AI/ML Serving + Unified Compliance Audit Trail

Alibaba Cloud owns the entire ML serving layer. The EAS Dedicated Gateway is the single entry point for all cross-cloud inference calls. SLS has been extended to serve as the unified audit trail for the full credit decision chain — not just the Alibaba-side inference logs, but also the Lambda Credit invocation on AWS (shipped via LoongCollector). This gives compliance auditors one immutable store covering both clouds.

| Service                           | Role                                                                                                                                                                                                           | Why This Cloud                                                                                                                                                                                                     |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **EAS Dedicated Gateway**         | Single stable endpoint for all Lambda → PAI-EAS calls. IP-whitelisted to Lambda NAT gateway. Canary release support for model version rollouts.                                                                | Prevents raw PAI-EAS URLs from being exposed or changing on redeployment. Standard pattern for cross-cloud EAS access per Alibaba Cloud documentation.                                                             |
| **PAI-EAS (Spending Classifier)** | Serve Malaysian merchant spending tagger in real time                                                                                                                                                          | SEA-native infrastructure; fine-tuned on MY merchant names. AWS has no equivalent MY-tuned offering.                                                                                                               |
| **PAI-EAS (Credit Scorer)**       | Serve XGBoost credit model — CTOS + TNG feature fusion                                                                                                                                                         | Consolidated on same platform as classifier. One ML serving layer, not two.                                                                                                                                        |
| **SLS (Log Service)**             | Unified audit trail: PAI-EAS inference logs (co-located) + Lambda Credit structured logs (via LoongCollector). Full decision chain from AWS invocation to Alibaba inference outcome in one immutable Logstore. | SLS natively supports multi-cloud log ingestion. LoongCollector agent on Lambda ships structured JSON logs to SLS endpoint over HTTPS. Zero additional infrastructure required. PDPA-compliant anonymised records. |
| **OpenSearch**                    | B40 government benefit eligibility search                                                                                                                                                                      | Full-text matching on benefit rules — not a DynamoDB use case.                                                                                                                                                     |
| **OSS**                           | Model artefacts and training datasets                                                                                                                                                                          | Native PAI-EAS model registry. OSS → PAI pipeline requires no external tooling. Model deployment sequence: export locally → upload to OSS → mount OSS path in EAS service config → EAS loads on startup.           |

### EAS Dedicated Gateway Configuration

**Spending Classifier**
```
Gateway type:    Fully-managed Dedicated Gateway
Network access:  Public + internal (same VPC as PAI-EAS services)
IP whitelist:    <Lambda NAT Gateway EIP>  # only source permitted
Custom domain:   survivai-inference.eas.example.com  # stable across redeployments
Canary policy:   10% traffic to new model version → monitor P99 → cut over at 0% error rate
```

### PAI-EAS Endpoint Contracts

All calls route through the EAS Dedicated Gateway, not directly to the PAI-EAS service URL.

**Spending Classifier**

```
POST https://survivai-inference.eas.example.com/api/predict/spending_classifier
Headers: { "Authorization": "Bearer <token-from-secrets-manager>" }
Body:   { "merchant_name": "Giant Hypermarket Shah Alam", "amount": 45.80, "mcc": "5411" }
Return: { "category": "Essential", "confidence": 0.97, "subcategory": "Grocery" }
```

**Credit Scorer**

```
POST https://survivai-inference.eas.example.com/api/predict/credit_scorer
Headers: { "Authorization": "Bearer <token-from-secrets-manager>" }
Body:   { "ctos_score_band": 3, "topup_frequency_90d": 14, "utility_payment_rate": 0.92,
          "spend_volatility": 0.21, "essential_spend_ratio": 0.64, "survival_score_delta": 2 }
Return: { "decision": "APPROVE", "loan_amount": 150, "risk_tier": "MEDIUM",
          "shap_factors": ["Regular top-ups (+)", "Utility bills paid (+)", "High Grab spend (-)"] }
```
POST https://<endpoint>.eas.aliyuncs.com/api/predict/credit_scorer
Headers: { "Authorization": "Bearer <token>" }
Body:   { "ctos_score_band": 3, "topup_frequency_90d": 14, "utility_payment_rate": 0.92,
          "spend_volatility": 0.21, "essential_spend_ratio": 0.64, "survival_score_delta": 2 }
Return: { "decision": "APPROVE", "loan_amount": 150, "risk_tier": "MEDIUM",
          "shap_factors": ["Regular top-ups (+)", "Utility bills paid (+)", "High Grab spend (-)"] }
```

> Note: No PII is sent to Alibaba Cloud. All inputs are numerical feature vectors derived by Lambda. Raw merchant names are sent to the classifier only — no user identifiers travel with them.

### OSS → PAI-EAS Model Deployment Sequence

```
1. Train XGBoost model locally → export model.pkl + model.json
2. Upload to OSS:
   oss://survivai-models/credit-scorer/v1/model.pkl
   oss://survivai-models/spending-classifier/v1/model.pkl
3. PAI console: Create EAS service → Custom deployment
   → Mount OSS path: oss://survivai-models/credit-scorer/v1/ → /home/model/
   → EAS service loads model from /home/model/model.pkl at startup
4. Attach service to EAS Dedicated Gateway
5. Copy gateway endpoint → store in AWS Secrets Manager as survivai/pai-eas-token
```

> Note: No PII is sent to Alibaba Cloud. All inputs to both PAI-EAS endpoints are numerical feature vectors derived by Lambda. Raw merchant names sent to the spending classifier carry no user identifiers — no `user_id`, no `ic_hash`, no name.

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

| Requirement                 | Implementation                                                                                                   |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Consent before data use** | Explicit consent screen on onboarding covers transaction analysis. Separate consent screen before CTOS API call. |
| **Data minimisation**       | Raw transaction strings not stored on Alibaba Cloud — only aggregated feature vectors                            |
| **Right to withdraw**       | User can deactivate SurvivAI module and request data deletion from settings                                      |
| **Data residency**          | User PII stays in AWS ap-southeast-1 (Singapore). Alibaba Cloud receives only anonymised feature vectors.        |
| **Audit trail**             | All credit decisions logged to Alibaba Cloud SLS with anonymised ID — no NRIC, no name                           |

### BNM Compliance

| Concern                     | Position                                                                                                                                                                                                |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Micro-lending licence**   | SurvivAI facilitates access to TNG Digital's **existing licensed e-money and prepaid card credit facility** — it is not an independent lender. All credit is extended under TNG's existing BNM licence. |
| **Fair lending**            | XGBoost + SHAP explainability satisfies fair lending transparency. Decision factors shown to user in plain language.                                                                                    |
| **Credit bureau reporting** | Repayment history reported back to CTOS to build B40 users' credit profiles over time.                                                                                                                  |
| **Regulatory sandbox**      | If a full standalone lending product is pursued post-hackathon, BNM's Regulatory Sandbox provides the pathway.                                                                                          |

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
- [ ] Bilingual nudge displayed on Survival Score screen (template engine — no external API required)

### Should Have — Demo-Enhancing

- [ ] Repayment schedule displayed post-approval
- [ ] Trend chart on Survival Score (7-day history)

### Nice to Have — If Time Allows

- [ ] Alibaba Cloud PAI-EAS live call (vs fallback classifier)
- [ ] Government benefits checker via OpenSearch
- [ ] Spend lock warning on non-essential transaction attempts

---

## 16. Implementation Plan

### Team Role Assignments

| Role              | Responsibilities                                                                                      |
| ----------------- | ----------------------------------------------------------------------------------------------------- |
| **@frontend-dev** | TNG MiniApp UI, all screens, state management                                                         |
| **@backend-dev**  | AWS Lambda functions, DynamoDB schema, API contracts                                                  |
| **@ai-dev**       | PAI-EAS classifier deployment, XGBoost credit scorer, SLS logging, nudge template authoring (EN + BM) |
| **@infra-dev**    | AWS provisioning, Alibaba Cloud setup, deployment                                                     |

### Hour-by-Hour Build Timeline

| Window          | Milestone                                                                                                                                            | Owner                      |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| **17:00–19:00** | Repo init. DynamoDB tables created. Siti's mock data seeded. AWS Lambda skeleton deployed. Flutter project initialised — 4 screens scaffolded.       | Backend + Infra + Frontend |
| **19:00–21:00** | Spending classifier Lambda live (calls PAI-EAS or rule-based fallback). Survival Score formula working end-to-end. Emergency Mode API live.          | Backend + AI               |
| **21:00–23:00** | ECL application flow: feature engineering Lambda → PAI-EAS credit scorer (or stub) → decision returned to Flutter. MCC-locked card screen rendering. | Backend + Frontend         |
| **23:00–01:00** | Nudge template engine live (EN + BM, 8 categories). MCC transaction check API. Flutter ↔ Backend fully integrated for core flow.                     | AI + Backend + Frontend    |
| **01:00–03:00** | PAI-EAS both endpoints confirmed live (spending classifier + credit scorer). OpenSearch benefits lookup (if time). SLS logging wired up.             | Infra + AI                 |
| **03:00–05:00** | Repayment schedule UI. Flutter UI polish. Edge cases (no CTOS consent, decline flow). Demo data rehearsal.                                           | Frontend + Backend         |
| **05:00–07:00** | Demo video recorded (Siti's full journey). Pitch deck built (7 slides).                                                                              | All                        |
| **07:00–08:30** | GitHub README. Submission form filled. Final demo dry run. Q&A roles assigned.                                                                       | All                        |

### Critical Path

```
DynamoDB schema  →  Survival Score Lambda  →  Frontend Score Screen
                                          ↘
CTOS mock setup  →  Credit Lambda         →  ECL Application Screen  →  MCC Card Screen
                                          ↗
Template Engine  →  Nudge Lambda          →  Emergency Mode Screen
```

Template Engine and MCC card screen can be parallelised after the core Lambda is working. Template authoring (EN + BM strings) can be done offline by @ai-dev while @backend-dev wires the Lambda.

---

## 17. Demo Script

**Duration**: 3 minutes 00 seconds | **Presenter**: Lead + AI dev for technical Q&A

---

**[0:00–0:20] — Open with Siti (Wing's moment)**

_"This is Siti. She's 34, works in a factory in Shah Alam, earns RM1,800 a month. Right now she has RM87 in her TNG wallet. She doesn't know it, but she's 11 days away from financial collapse."_

Show: Survival Score screen. **"11 days"** in red. Daily burn rate: RM7.90/day.

---

**[0:20–0:40] — The Morning Nudge**

Show: Morning nudge card on the Survival Score screen (pre-delivered in seed data).

_"Every morning at 8am, SurvivAI sends Siti a nudge. This morning: she spent RM42 on Grab this week. Cut two orders — that's +3 survival days."_

Tap the language toggle. Card flips to Bahasa Malaysia: _"Anda belanja RM42 untuk penghantaran makanan minggu ini. Kurangkan 2 pesanan = +3 hari survival."_

_"Bilingual. No LLM call. The template engine runs inside Lambda — zero API cost, instant response."_

Trigger the evening nudge via the demo button. Show the projected burn card: _"You spent RM18 today. At this rate, your runway is 9 days. Tomorrow's target: under RM12."_

---

**[0:40–1:10] — The AI Engine (Leslie's moment)**

_"SurvivAI analysed 90 days of Siti's TNG transactions. Our classifier — running on Alibaba Cloud PAI, trained on Malaysian merchant data — tagged every transaction: Giant is Essential, Grab is Discretionary, kedai runcit is Essential."_

Show: Transaction list with category tags animating in. Pie chart: 62% Essential / 38% Discretionary.

_"The Survival Score is live. Every new transaction updates it in real time."_

---

**[1:10–1:40] — Crisis Hits**

_"Today, Siti was laid off."_

Tap Emergency Mode. Screen transitions to red survival dashboard.

_"Day 3. Her score drops to 4 days. SurvivAI offers her a lifeline."_

Show ECL prompt. Siti taps Apply. 30-second animation.

_"Our model fused her CTOS thin-file with 90 days of TNG behavioural data — top-up regularity, utility payments, spending volatility. Decision in under 30 seconds: approved. RM150."_

Show approval screen with top 3 factors.

---

**[1:40–2:10] — The MCC Lock (Enshu's moment)**

_"But here's what makes this responsible lending, not reckless lending."_

Show TNG Visa Card with restricted balance: **RM150 — Essential Spend Only**.

Siti taps to buy groceries at Giant. ✅ **Approved.**

Siti taps to buy from Shopee. ❌ **Declined. This balance is for essentials only.**

_"Every ringgit goes to rice and fuel — not Shopee. The MCC allowlist is enforced at the card processor layer."_

---

**[2:10–2:45] — The Bigger Picture**

_"Siti repays RM15/week from her next top-ups. For the first time, she has a credit history. Next time her limit is RM200. In Year 2, one million B40 users build credit profiles through SurvivAI — closing Malaysia's credit invisibility gap."_

Show Year 2 vision slide: credit history growth curve.

---

**[2:45–3:00] — Close**

_"SurvivAI. Because knowing you have 11 days is the first step to having 30."_

---

## 18. Judging Criteria Alignment

| Criterion                     | How We Win It                                                                                                                                                                                                                                                                                                   | Judge         |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| **AI & Intelligent Systems**  | Two distinct PAI-EAS models on Alibaba Cloud (spending classifier + XGBoost credit scorer). Both are purposeful — none decorative. AI is consolidated on one platform. The nudge system is a deliberate template engine — a conscious engineering tradeoff judges can engage with ("why not LLM?" → cost and latency; Bedrock enters at Year 2 at 100K users). | Leslie        |
| **Technical Implementation**  | Serverless AWS stack (Lambda + API Gateway + Secrets Manager + DynamoDB), MCC-locked card sub-balance (production-architecture pattern), CTOS B2B API integration, SHAP explainability on credit decisions, bilingual template nudge engine (twice daily), inline PAI-EAS fallback. Ambitious and functional for 24 hours.                               | Leslie        |
| **Multi-Cloud Service Usage** | AWS: API Gateway + Lambda + Secrets Manager + DynamoDB — core compute and data. Alibaba Cloud: PAI-EAS (AI inference) + EAS Dedicated Gateway + SLS with LoongCollector (unified audit trail) + OpenSearch (benefit search) + OSS (model artefacts). Both clouds serve non-substitutable roles.                                                          | Enshu         |
| **Impact & Feasibility**      | Named persona (Siti). Addresses 5.8M B40 households. Extends survival by 6–8 days per emergency. Responsible MCC-locked lending. Repayment builds credit history — long-term poverty gap reduction. TNG's 24M users are the distribution moat.                                                                  | Wing + Leslie |
| **Presentation & Teamwork**   | Demo opens with Siti's story (not architecture). Live functional demo — not Figma. Clear one-sentence value prop. Compliance addressed proactively. Year 2 vision closes the pitch.                                                                                                                             | Wing          |

---

## 19. Year 2 Roadmap

| Phase                | Timeline | What Ships                                                                                                                                                                                                                                      |
| -------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hackathon MVP**    | Apr 2026 | Survival Score, Emergency Mode, ECL with MCC lock, bilingual template nudges                                                                                                                                                                    |
| **Beta (TNG Pilot)** | Q3 2026  | Live CTOS integration, real PAI-EAS model trained on TNG data, 10K B40 users                                                                                                                                                                    |
| **Scale**            | Q1 2027  | 100K users, repayment data fed back to CTOS for credit history building, ECL limit increases. Bedrock LLM nudges replace template engine — personalisation across 50+ regional spending patterns justifies generative capability at this scale. |
| **Ecosystem**        | Q3 2027  | Partner with Bank Rakyat / BSN to convert SurvivAI credit history into formal micro-loan products. 1M B40 users with verifiable credit profiles.                                                                                                |
| **Policy Impact**    | 2028     | BNM partnership — SurvivAI data used to inform B40 financial resilience policy. Potential mandatory TNG integration.                                                                                                                            |

**The long game**: Every B40 user who repays an ECL builds a credit history. After 3 cycles, they have enough history to access formal financial products. SurvivAI is not just a survival tool — it is the **credit onramp** for Malaysia's credit-invisible population.

---

_Document prepared for TNGD FinHack 2026 | SurvivAI Team | 25 April 2026_
_All CTOS API details are illustrative — confirm B2B API access with CTOS directly._
_Cloud service names and endpoint formats are correct as of April 2026._
