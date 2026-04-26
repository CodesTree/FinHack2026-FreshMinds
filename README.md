# SurvivAI — Financial Survival Coach

> Built for TNG FinHack 2026 by Team FreshMinds

SurvivAI is a Flutter mobile app that helps B40 households in Malaysia understand their financial runway and access emergency credit when needed.

---

## What It Does

SurvivAI answers one question: **"How many days can I survive without income?"**

It connects to a user's TNG eWallet transaction history, computes a **Survival Score** (in days), and provides:
- Real-time burn rate tracking
- AI-powered spending recommendations
- Emergency Credit Lifeline (ECL) — auto-triggered when survival score drops critically low
- MCC-restricted card to prevent misuse of loan funds
- Government benefits eligibility checker

---

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Welcome | `/welcome` | App intro with TNG branding and B40 stats |
| Consent | `/onboarding/consent` | PDPA data access consent toggles |
| Home | `/home` | Survival score, recommendations, spending breakdown |
| Emergency | `/emergency` | Emergency Mode dashboard with 14-day countdown |
| ECL Apply | `/ecl/apply` | Loan tier selector (RM100 / RM150 / RM200) |
| ECL Consent | `/ecl/consent` | CTOS credit check consent |
| ECL Processing | `/ecl/processing` | 6-step AI credit assessment animation |
| ECL Result | `/ecl/result` | Approval/decline with SHAP explainability |
| Card | `/card` | TNG ECL card with MCC merchant simulator |
| Transactions | `/transactions` | Full transaction history with category filter |
| Nudges | `/nudges` | AI recommendations with streak tracker |
| Settings | `/settings` | Profile management and salary update |

---

## User Journey

```
New User:
Welcome → Consent → Home

Daily Usage:
Home → Nudges → Transactions → Settings

Emergency Flow (auto-triggered when survival score ≤ 5 days):
Home (red alert banner) → Emergency → ECL Apply → ECL Consent
  → ECL Processing → ECL Result → Card (restricted spending)
```

---

## Emergency Mode Auto-Trigger

Emergency Mode activates **automatically** when `survivalDays <= 5`. No manual action needed.

- A red alert banner appears on the Home screen
- Tapping it navigates directly to the Emergency screen
- Emergency Credit Lifeline (ECL) becomes available immediately
- The MCC card restricts spending to essential merchants only

The threshold is defined in `lib/core/providers/app_provider.dart`:
```dart
const int kEmergencyThreshold = 5;
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Flutter 3.x | Cross-platform mobile + web |
| Dart | Language |
| Provider | State management |
| GoRouter | Navigation / routing |
| Google Fonts | Outfit (headlines) + Inter (body) |
| FL Chart | Spending charts |

---

## Project Structure

```
lib/
├── app.dart                          # Router config (all 12 routes)
├── main.dart                         # Entry point
├── core/
│   ├── models/
│   │   ├── user_model.dart           # UserModel, SurvivalBand, SurvivalTrend
│   │   ├── transaction_model.dart    # TransactionModel, TransactionCategory
│   │   ├── loan_model.dart           # LoanModel
│   │   └── nudge_model.dart          # NudgeModel
│   ├── providers/
│   │   └── app_provider.dart         # State + auto-emergency logic
│   ├── services/
│   │   └── mock_data_service.dart    # All mock data (profile, transactions, nudges)
│   └── theme/
│       ├── app_colors.dart           # Color palette (Warga Blue + Warga Gold)
│       └── app_typography.dart       # Typography (Outfit + Inter)
├── features/
│   ├── onboarding/screens/
│   │   ├── welcome_screen.dart
│   │   └── consent_screen.dart
│   ├── dashboard/screens/
│   │   └── home_screen.dart
│   ├── emergency/screens/
│   │   └── emergency_screen.dart
│   ├── ecl/screens/
│   │   ├── ecl_apply_screen.dart
│   │   ├── ecl_consent_screen.dart
│   │   ├── ecl_processing_screen.dart
│   │   └── ecl_result_screen.dart
│   ├── card/screens/
│   │   └── mcc_card_screen.dart
│   ├── transactions/screens/
│   │   └── transactions_screen.dart
│   ├── nudges/screens/
│   │   └── nudges_screen.dart
│   └── settings/screens/
│       └── settings_screen.dart
└── shared/
    └── widgets/
        ├── bottom_nav.dart            # App bottom navigation bar
        ├── glass_card.dart            # Reusable card widget
        ├── survival_score_ring.dart   # Animated circular score ring
        └── category_chip.dart         # Transaction category label
```

---

## Design System

### Colors

| Name | Hex | Usage |
|------|-----|-------|
| Warga Blue | `#0066FF` | Primary — headers, buttons, links |
| Warga Gold | `#FFD54F` | Accent — highlights, CTAs, badges |
| Soft Yellow | `#FFF8E1` | App background surface |
| Survival Green | `#00C853` | Safe (> 30 days) |
| Survival Amber | `#FFAB00` | Warning (15–30 days) |
| Emergency Red | `#E53935` | Critical (< 5 days, auto-trigger) |

### Typography

| Style | Font | Size | Weight |
|-------|------|------|--------|
| headlineXl | Outfit | 48px | 800 |
| headlineLg | Outfit | 38px | 700 |
| headlineMd | Outfit | 28px | 700 |
| headlineSm | Outfit | 20px | 700 |
| bodyBold | Inter | 17px | 700 |
| bodyBase | Inter | 15px | 500 |
| bodySm | Inter | 13px | 400 |

---

## Running the App

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x
- iOS Simulator / Android Emulator / Chrome

### Install & Run
```bash
cd survivai
flutter pub get

# iOS
flutter run -d ios

# Android
flutter run -d android

# Chrome (web)
flutter run -d chrome

# List all available devices
flutter devices
```

### Analyze
```bash
flutter analyze
```

---

## Mock Data

All data is mocked via `MockDataService`. The demo user is **Siti Nurhaliza**:

| Field | Value |
|-------|-------|
| Wallet Balance | RM 87.00 |
| Survival Days | 11 days |
| Daily Burn Rate | RM 7.90/day |
| Monthly Income | RM 1,800 |
| Trend | Declining |
| Emergency Threshold | Auto-activates at ≤ 5 days |

---

## Team FreshMinds — TNG FinHack 2026

## Backend API Link Configuration

SurvivAI now supports loading dashboard data from backend API instead of only mock data.

Run with explicit API base URL:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api
```

Current endpoint used by provider:
- `GET /api/survival-score?user_id=<id>`

Fallback behavior:
- If API call fails, `AppProvider` falls back to `MockDataService` so demo flow stays available.
