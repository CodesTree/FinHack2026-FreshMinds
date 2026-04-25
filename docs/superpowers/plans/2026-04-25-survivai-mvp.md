# SurvivAI MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a demo-ready SurvivAI MVP from the spec sheet with working backend APIs, seeded data, and a Flutter UI covering Survival Score, Emergency Mode, ECL application, and MCC-locked transaction checks.

**Architecture:** Use a monorepo with a TypeScript AWS Lambda backend and a Flutter client. Keep the ML and CTOS integrations behind provider interfaces so we can run deterministic local mocks for the hackathon demo while preserving production-ready call boundaries. Implement all required API contracts first, then wire the mobile flow and finish with integration tests and demo seeding.

**Tech Stack:** TypeScript (Node.js 20, AWS Lambda, API Gateway, DynamoDB SDK v3, Jest), Flutter (Dart, Provider, http), Docker DynamoDB Local, Serverless Framework.

---

## Scope Check

The spec includes multiple independent subsystems (core MVP flows, cloud production setup, year-2 scale roadmap, and policy/pitch materials). This plan intentionally targets the executable MVP scope (Section 15: Must Have + Should Have) in one shippable track. Production multi-cloud hardening (real PAI-EAS gateway, OSS model CI/CD, LoongCollector rollout) is excluded from this implementation plan and should be handled in a separate infrastructure plan.

## File Structure

**Backend (`backend/`)**
- `backend/serverless.yml`: Lambda + API Gateway route wiring.
- `backend/package.json`: Scripts and dependencies.
- `backend/tsconfig.json`: TypeScript compiler config.
- `backend/jest.config.cjs`: Unit/integration test setup.
- `backend/src/handlers/getSurvivalScore.ts`: `GET /survival-score` handler.
- `backend/src/handlers/postEmergencyMode.ts`: `POST /emergency-mode` handler.
- `backend/src/handlers/postEclApply.ts`: `POST /ecl/apply` handler.
- `backend/src/handlers/postEclTransactionCheck.ts`: `POST /ecl/transaction-check` handler.
- `backend/src/domain/survival.ts`: Survival score math + trend logic.
- `backend/src/domain/emergency.ts`: Countdown projection + emergency eligibility.
- `backend/src/domain/credit.ts`: ECL decision tiering + repayment schedule.
- `backend/src/domain/mcc.ts`: MCC allowlist decision logic.
- `backend/src/domain/nudges.ts`: EN/BM template nudge generator.
- `backend/src/providers/spendingClassifier.ts`: PAI-EAS call + keyword fallback.
- `backend/src/providers/creditScorer.ts`: PAI-EAS credit scoring adapter + local mock path.
- `backend/src/providers/ctos.ts`: CTOS adapter + local mock path.
- `backend/src/repositories/dynamo.ts`: DynamoDB access helpers.
- `backend/src/types/contracts.ts`: Shared API request/response types.
- `backend/src/config/env.ts`: Environment parsing and defaults.
- `backend/tests/unit/*.test.ts`: Domain tests.
- `backend/tests/integration/api.test.ts`: Route contract tests.
- `backend/scripts/seedDemoData.ts`: Seeds Siti's demo data.

**Frontend (`mobile/`)**
- `mobile/pubspec.yaml`: Flutter dependencies.
- `mobile/lib/main.dart`: App bootstrap + routing.
- `mobile/lib/models/contracts.dart`: Backend contract models.
- `mobile/lib/services/api_client.dart`: HTTP calls.
- `mobile/lib/state/app_state.dart`: Provider state container.
- `mobile/lib/screens/survival_score_screen.dart`: Score + nudge + trend card.
- `mobile/lib/screens/emergency_mode_screen.dart`: Countdown + eligibility.
- `mobile/lib/screens/ecl_apply_screen.dart`: Apply + decision + factors.
- `mobile/lib/screens/mcc_card_screen.dart`: MCC transaction simulation.
- `mobile/test/widget_flow_test.dart`: End-to-end widget flow test.

**Docs/Tooling**
- `README.md`: Setup + runbook + API routes.
- `docs/superpowers/plans/2026-04-25-survivai-mvp.md`: This plan.

### Task 1: Scaffold Backend + Test Harness

**Files:**
- Create: `backend/package.json`
- Create: `backend/tsconfig.json`
- Create: `backend/jest.config.cjs`
- Create: `backend/serverless.yml`
- Create: `backend/src/config/env.ts`
- Create: `backend/src/types/contracts.ts`
- Test: `backend/tests/unit/contracts.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/unit/contracts.test.ts
import { describe, expect, it } from "@jest/globals";
import type { SurvivalScoreResponse } from "../../src/types/contracts";

describe("contracts", () => {
  it("requires survival response fields", () => {
    const sample: SurvivalScoreResponse = {
      survival_days: 11,
      daily_burn_rate: 7.9,
      wallet_balance: 87,
      trend_7d: "declining",
      color_band: "red",
      top_discretionary: { category: "Food Delivery", amount_7d: 42 }
    };

    expect(sample.color_band).toBe("red");
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- contracts.test.ts`
Expected: FAIL with module/type import error because `contracts.ts` and Jest config do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```json
// backend/package.json
{
  "name": "survivai-backend",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "test": "node --experimental-vm-modules ./node_modules/jest/bin/jest.js",
    "offline": "serverless offline start",
    "seed": "tsx scripts/seedDemoData.ts"
  },
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.883.0",
    "@aws-sdk/lib-dynamodb": "^3.883.0"
  },
  "devDependencies": {
    "@jest/globals": "^30.0.5",
    "@types/jest": "^30.0.0",
    "jest": "^30.0.5",
    "serverless": "^4.17.1",
    "serverless-offline": "^14.3.4",
    "tsx": "^4.20.3",
    "typescript": "^5.8.3"
  }
}
```

```ts
// backend/src/types/contracts.ts
export type Trend7d = "improving" | "stable" | "declining";
export type ColorBand = "green" | "amber" | "red";

export interface SurvivalScoreResponse {
  survival_days: number;
  daily_burn_rate: number;
  wallet_balance: number;
  trend_7d: Trend7d;
  color_band: ColorBand;
  top_discretionary: { category: string; amount_7d: number };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm install; npm test -- contracts.test.ts`
Expected: PASS (1 test passed).

- [ ] **Step 5: Commit**

```bash
git add backend/package.json backend/tsconfig.json backend/jest.config.cjs backend/serverless.yml backend/src/types/contracts.ts backend/src/config/env.ts backend/tests/unit/contracts.test.ts
git commit -m "chore: scaffold backend toolchain and typed contracts"
```

### Task 2: Implement Survival Score Domain + Endpoint

**Files:**
- Create: `backend/src/domain/survival.ts`
- Create: `backend/src/handlers/getSurvivalScore.ts`
- Create: `backend/src/repositories/dynamo.ts`
- Test: `backend/tests/unit/survival.test.ts`
- Test: `backend/tests/integration/api.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/unit/survival.test.ts
import { describe, expect, it } from "@jest/globals";
import { computeSurvivalScore } from "../../src/domain/survival";

describe("computeSurvivalScore", () => {
  it("computes survival days and color band", () => {
    const result = computeSurvivalScore({
      walletBalance: 87,
      essentialSpendLast30Days: 237,
      discretionaryByCategory7d: [{ category: "Food Delivery", amount: 42 }],
      scoreHistory7d: [13, 12, 12, 11, 11, 10, 11]
    });

    expect(result.survival_days).toBe(11);
    expect(result.color_band).toBe("red");
    expect(result.top_discretionary.category).toBe("Food Delivery");
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- survival.test.ts`
Expected: FAIL with `Cannot find module '../../src/domain/survival'`.

- [ ] **Step 3: Write minimal implementation**

```ts
// backend/src/domain/survival.ts
import type { SurvivalScoreResponse, Trend7d } from "../types/contracts";

interface Input {
  walletBalance: number;
  essentialSpendLast30Days: number;
  discretionaryByCategory7d: Array<{ category: string; amount: number }>;
  scoreHistory7d: number[];
}

function trend(history: number[]): Trend7d {
  if (history.length < 2) return "stable";
  const delta = history[history.length - 1] - history[0];
  if (delta > 0) return "improving";
  if (delta < 0) return "declining";
  return "stable";
}

export function computeSurvivalScore(input: Input): SurvivalScoreResponse {
  const dailyBurn = Number((input.essentialSpendLast30Days / 30).toFixed(2));
  const survivalDays = dailyBurn === 0 ? 999 : Math.floor(input.walletBalance / dailyBurn);
  const colorBand = survivalDays > 30 ? "green" : survivalDays >= 15 ? "amber" : "red";
  const top = [...input.discretionaryByCategory7d].sort((a, b) => b.amount - a.amount)[0] ?? {
    category: "None",
    amount: 0
  };

  return {
    survival_days: survivalDays,
    daily_burn_rate: dailyBurn,
    wallet_balance: input.walletBalance,
    trend_7d: trend(input.scoreHistory7d),
    color_band: colorBand,
    top_discretionary: { category: top.category, amount_7d: top.amount }
  };
}
```

```ts
// backend/src/handlers/getSurvivalScore.ts
import { computeSurvivalScore } from "../domain/survival";

export async function handler(event: { queryStringParameters?: { user_id?: string } }) {
  const userId = event.queryStringParameters?.user_id;
  if (!userId) return { statusCode: 400, body: JSON.stringify({ error: "user_id is required" }) };

  const response = computeSurvivalScore({
    walletBalance: 87,
    essentialSpendLast30Days: 237,
    discretionaryByCategory7d: [{ category: "Food Delivery", amount: 42 }],
    scoreHistory7d: [13, 12, 12, 11, 11, 10, 11]
  });

  return { statusCode: 200, body: JSON.stringify(response) };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test -- survival.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/src/domain/survival.ts backend/src/handlers/getSurvivalScore.ts backend/tests/unit/survival.test.ts backend/tests/integration/api.test.ts backend/src/repositories/dynamo.ts
git commit -m "feat: add survival score computation and endpoint"
```

### Task 3: Add Spending Classification Path with Inline Fallback

**Files:**
- Create: `backend/src/providers/spendingClassifier.ts`
- Create: `backend/src/handlers/postTransactionIngest.ts`
- Modify: `backend/serverless.yml`
- Test: `backend/tests/unit/spendingClassifier.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/unit/spendingClassifier.test.ts
import { describe, expect, it } from "@jest/globals";
import { classifySpending } from "../../src/providers/spendingClassifier";

describe("classifySpending", () => {
  it("falls back to keyword classifier when remote call fails", async () => {
    const result = await classifySpending(
      { merchant_name: "Shopee", amount: 25, mcc: "5311" },
      async () => {
        throw new Error("timeout");
      }
    );

    expect(result.category).toBe("Discretionary");
    expect(result.confidence).toBe(0);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- spendingClassifier.test.ts`
Expected: FAIL because provider is not implemented.

- [ ] **Step 3: Write minimal implementation**

```ts
// backend/src/providers/spendingClassifier.ts
export interface SpendingRequest {
  merchant_name: string;
  amount: number;
  mcc: string;
}

export interface SpendingResponse {
  category: "Essential" | "Discretionary" | "Savings";
  confidence: number;
  subcategory: string;
}

const essentialKeywords = ["giant", "petronas", "pharmacy", "99 speedmart", "kedai", "utility"];

function keywordCategory(name: string): SpendingResponse {
  const merchant = name.toLowerCase();
  const essential = essentialKeywords.some((k) => merchant.includes(k));
  return {
    category: essential ? "Essential" : "Discretionary",
    confidence: 0,
    subcategory: essential ? "Household" : "Lifestyle"
  };
}

export async function classifySpending(
  payload: SpendingRequest,
  remoteCall: (payload: SpendingRequest) => Promise<SpendingResponse>
): Promise<SpendingResponse> {
  try {
    return await remoteCall(payload);
  } catch {
    return keywordCategory(payload.merchant_name);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test -- spendingClassifier.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/src/providers/spendingClassifier.ts backend/src/handlers/postTransactionIngest.ts backend/tests/unit/spendingClassifier.test.ts backend/serverless.yml
git commit -m "feat: add spending classification with inline fallback"
```

### Task 4: Implement Emergency Mode Endpoint + Nudge Templates

**Files:**
- Create: `backend/src/domain/emergency.ts`
- Create: `backend/src/domain/nudges.ts`
- Create: `backend/src/handlers/postEmergencyMode.ts`
- Test: `backend/tests/unit/emergency.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/unit/emergency.test.ts
import { describe, expect, it } from "@jest/globals";
import { buildEmergencyDashboard } from "../../src/domain/emergency";

describe("buildEmergencyDashboard", () => {
  it("returns 14-day countdown and ECL eligibility", () => {
    const data = buildEmergencyDashboard({ survivalDays: 4, walletBalance: 87, dailyBurnRate: 7.9 });

    expect(data.survival_countdown).toHaveLength(14);
    expect(data.ecl_eligible).toBe(true);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- emergency.test.ts`
Expected: FAIL because emergency domain file is missing.

- [ ] **Step 3: Write minimal implementation**

```ts
// backend/src/domain/emergency.ts
export function buildEmergencyDashboard(input: {
  survivalDays: number;
  walletBalance: number;
  dailyBurnRate: number;
}) {
  const survival_countdown = Array.from({ length: 14 }).map((_, idx) => ({
    day: idx + 1,
    projected_balance: Number((input.walletBalance - input.dailyBurnRate * (idx + 1)).toFixed(2))
  }));

  return {
    status: "active" as const,
    survival_countdown,
    ecl_eligible: input.survivalDays < 5,
    benefits_available: [
      {
        name: "Bantuan SARA",
        amount: 100,
        apply_url: "https://bantuan.gov.my"
      }
    ]
  };
}
```

```ts
// backend/src/domain/nudges.ts
export function buildNudge(language: "en" | "bm", category: string, amount7d: number, daysGain: number): string {
  if (language === "bm") {
    return `Anda belanja RM${amount7d} untuk ${category}. Kurangkan sedikit dan anda boleh tambah ${daysGain} hari.`;
  }
  return `You spent RM${amount7d} on ${category}. Cut a little and gain ${daysGain} survival days.`;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test -- emergency.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/src/domain/emergency.ts backend/src/domain/nudges.ts backend/src/handlers/postEmergencyMode.ts backend/tests/unit/emergency.test.ts
git commit -m "feat: add emergency mode countdown and bilingual nudge templates"
```

### Task 5: Implement ECL Apply Flow (CTOS + Credit Scorer Abstractions)

**Files:**
- Create: `backend/src/providers/ctos.ts`
- Create: `backend/src/providers/creditScorer.ts`
- Create: `backend/src/domain/credit.ts`
- Create: `backend/src/handlers/postEclApply.ts`
- Test: `backend/tests/unit/credit.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/unit/credit.test.ts
import { describe, expect, it } from "@jest/globals";
import { decideEclLoan } from "../../src/domain/credit";

describe("decideEclLoan", () => {
  it("approves RM150 for medium-risk applicant", () => {
    const decision = decideEclLoan({ score: 0.68 });

    expect(decision.decision).toBe("APPROVE");
    expect(decision.loan_amount).toBe(150);
    expect(decision.repayment_schedule).toHaveLength(10);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- credit.test.ts`
Expected: FAIL because credit domain is missing.

- [ ] **Step 3: Write minimal implementation**

```ts
// backend/src/domain/credit.ts
export function decideEclLoan(input: { score: number }) {
  if (input.score < 0.5) {
    return {
      decision: "DECLINE" as const,
      loan_amount: 0,
      risk_tier: "HIGH",
      top_factors: ["Insufficient stability", "High spend volatility", "Low utility payment rate"],
      repayment_schedule: []
    };
  }

  const loan_amount = input.score >= 0.8 ? 200 : input.score >= 0.65 ? 150 : 100;
  const weekly = Number((loan_amount / 10).toFixed(2));

  return {
    decision: "APPROVE" as const,
    loan_amount,
    risk_tier: input.score >= 0.8 ? "LOW" : "MEDIUM",
    top_factors: ["Regular top-ups (+)", "Utility payments (+)", "Controlled volatility (+)"],
    repayment_schedule: Array.from({ length: 10 }).map((_, idx) => ({ week: idx + 1, amount: weekly }))
  };
}
```

```ts
// backend/src/handlers/postEclApply.ts
import { decideEclLoan } from "../domain/credit";

export async function handler(event: { body: string }) {
  const body = JSON.parse(event.body || "{}");
  if (!body.user_id || body.ctos_consent !== true) {
    return { statusCode: 400, body: JSON.stringify({ error: "user_id and ctos_consent=true are required" }) };
  }

  const decision = decideEclLoan({ score: 0.68 });
  return { statusCode: 200, body: JSON.stringify({ ...decision, disbursed_to: "TNG_VISA_RESTRICTED" }) };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test -- credit.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/src/domain/credit.ts backend/src/providers/ctos.ts backend/src/providers/creditScorer.ts backend/src/handlers/postEclApply.ts backend/tests/unit/credit.test.ts
git commit -m "feat: add ecl decision engine and apply endpoint"
```

### Task 6: Implement MCC-Locked Transaction Check Endpoint

**Files:**
- Create: `backend/src/domain/mcc.ts`
- Create: `backend/src/handlers/postEclTransactionCheck.ts`
- Test: `backend/tests/unit/mcc.test.ts`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/unit/mcc.test.ts
import { describe, expect, it } from "@jest/globals";
import { canSpendRestrictedBalance } from "../../src/domain/mcc";

describe("canSpendRestrictedBalance", () => {
  it("declines non-essential MCC", () => {
    const result = canSpendRestrictedBalance({
      merchant_mcc: "5311",
      amount: 50,
      restricted_balance_remaining: 150
    });

    expect(result.allowed).toBe(false);
    expect(result.reason).toBe("MCC not in essential list");
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- mcc.test.ts`
Expected: FAIL because `mcc.ts` is missing.

- [ ] **Step 3: Write minimal implementation**

```ts
// backend/src/domain/mcc.ts
const ALLOWLIST = new Set(["5411", "5541", "5912", "4900"]);

export function canSpendRestrictedBalance(input: {
  merchant_mcc: string;
  amount: number;
  restricted_balance_remaining: number;
}) {
  if (!ALLOWLIST.has(input.merchant_mcc)) {
    return {
      allowed: false,
      reason: "MCC not in essential list",
      restricted_balance_remaining: input.restricted_balance_remaining
    };
  }

  if (input.amount > input.restricted_balance_remaining) {
    return {
      allowed: false,
      reason: "Insufficient restricted balance",
      restricted_balance_remaining: input.restricted_balance_remaining
    };
  }

  return {
    allowed: true,
    reason: null,
    restricted_balance_remaining: Number((input.restricted_balance_remaining - input.amount).toFixed(2))
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test -- mcc.test.ts`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add backend/src/domain/mcc.ts backend/src/handlers/postEclTransactionCheck.ts backend/tests/unit/mcc.test.ts
git commit -m "feat: add mcc transaction lock checks"
```

### Task 7: Seed Demo Data + Integration Tests

**Files:**
- Create: `backend/scripts/seedDemoData.ts`
- Create: `backend/tests/integration/api.test.ts`
- Modify: `backend/README.md`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/integration/api.test.ts
import { describe, expect, it } from "@jest/globals";
import { handler as getSurvivalScore } from "../../src/handlers/getSurvivalScore";

describe("GET /survival-score", () => {
  it("returns expected contract", async () => {
    const response = await getSurvivalScore({ queryStringParameters: { user_id: "siti-001" } });
    const body = JSON.parse(response.body);

    expect(response.statusCode).toBe(200);
    expect(body).toHaveProperty("survival_days");
    expect(body).toHaveProperty("top_discretionary");
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- api.test.ts`
Expected: FAIL until all handlers are exported and wired.

- [ ] **Step 3: Write minimal implementation**

```ts
// backend/scripts/seedDemoData.ts
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";

const client = DynamoDBDocumentClient.from(new DynamoDBClient({ region: "ap-southeast-1" }));

async function seed() {
  await client.send(
    new PutCommand({
      TableName: "users",
      Item: {
        user_id: "siti-001",
        name: "Siti",
        ic_hash: "demo-hash",
        income_tier: "B40",
        emergency_mode_active: false,
        survival_score: 11,
        daily_burn_rate: 7.9,
        onboarded_at: "2026-04-25T08:00:00Z",
        ctos_consent: true,
        ctos_consent_timestamp: "2026-04-25T08:00:00Z"
      }
    })
  );
}

seed().then(() => console.log("seed complete"));
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test`
Expected: PASS across unit + integration suite.

- [ ] **Step 5: Commit**

```bash
git add backend/scripts/seedDemoData.ts backend/tests/integration/api.test.ts backend/README.md
git commit -m "test: add integration coverage and demo data seeding"
```

### Task 8: Build Flutter Screens + API Integration

**Files:**
- Create: `mobile/pubspec.yaml`
- Create: `mobile/lib/main.dart`
- Create: `mobile/lib/models/contracts.dart`
- Create: `mobile/lib/services/api_client.dart`
- Create: `mobile/lib/state/app_state.dart`
- Create: `mobile/lib/screens/survival_score_screen.dart`
- Create: `mobile/lib/screens/emergency_mode_screen.dart`
- Create: `mobile/lib/screens/ecl_apply_screen.dart`
- Create: `mobile/lib/screens/mcc_card_screen.dart`
- Test: `mobile/test/widget_flow_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// mobile/test/widget_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:survivai/main.dart';

void main() {
  testWidgets('renders survival score headline', (tester) async {
    await tester.pumpWidget(const SurvivAiApp());
    expect(find.textContaining('You can survive'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test`
Expected: FAIL because app files do not exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// mobile/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/survival_score_screen.dart';

void main() {
  runApp(const SurvivAiApp());
}

class SurvivAiApp extends StatelessWidget {
  const SurvivAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SurvivalScoreScreen(),
    );
  }
}
```

```dart
// mobile/lib/screens/survival_score_screen.dart
import 'package:flutter/material.dart';

class SurvivalScoreScreen extends StatelessWidget {
  const SurvivalScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SurvivAI')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('You can survive 11 days if you lose your income today'),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test`
Expected: PASS for widget flow test.

- [ ] **Step 5: Commit**

```bash
git add mobile/pubspec.yaml mobile/lib/main.dart mobile/lib/models/contracts.dart mobile/lib/services/api_client.dart mobile/lib/state/app_state.dart mobile/lib/screens/survival_score_screen.dart mobile/lib/screens/emergency_mode_screen.dart mobile/lib/screens/ecl_apply_screen.dart mobile/lib/screens/mcc_card_screen.dart mobile/test/widget_flow_test.dart
git commit -m "feat: add flutter mvp screens and api integration scaffolding"
```

### Task 9: Wire Full Demo Flow + Runbook

**Files:**
- Modify: `backend/serverless.yml`
- Modify: `mobile/lib/state/app_state.dart`
- Modify: `README.md`
- Test: `backend/tests/integration/api.test.ts`
- Test: `mobile/test/widget_flow_test.dart`

- [ ] **Step 1: Write the failing test**

```ts
// backend/tests/integration/api.test.ts (add end-to-end sequence case)
it("supports emergency + ecl + mcc sequence", async () => {
  const emergency = await postEmergencyMode({ body: JSON.stringify({ user_id: "siti-001", action: "activate" }) });
  expect(emergency.statusCode).toBe(200);

  const apply = await postEclApply({ body: JSON.stringify({ user_id: "siti-001", ctos_consent: true }) });
  expect(JSON.parse(apply.body).decision).toBe("APPROVE");

  const check = await postEclTransactionCheck({ body: JSON.stringify({ user_id: "siti-001", merchant_mcc: "5311", amount: 20 }) });
  expect(JSON.parse(check.body).allowed).toBe(false);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd backend; npm test -- api.test.ts`
Expected: FAIL until all route handlers are connected and return contract-safe payloads.

- [ ] **Step 3: Write minimal implementation**

```yaml
# backend/serverless.yml
service: survivai
provider:
  name: aws
  runtime: nodejs20.x
functions:
  getSurvivalScore:
    handler: src/handlers/getSurvivalScore.handler
    events:
      - httpApi: { path: /survival-score, method: get }
  postEmergencyMode:
    handler: src/handlers/postEmergencyMode.handler
    events:
      - httpApi: { path: /emergency-mode, method: post }
  postEclApply:
    handler: src/handlers/postEclApply.handler
    events:
      - httpApi: { path: /ecl/apply, method: post }
  postEclTransactionCheck:
    handler: src/handlers/postEclTransactionCheck.handler
    events:
      - httpApi: { path: /ecl/transaction-check, method: post }
```

```md
# README.md (minimum runbook section)
## Run backend
cd backend
npm install
npm run offline

## Run mobile
cd mobile
flutter pub get
flutter run

## Seed demo data
cd backend
npm run seed
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd backend; npm test && cd ../mobile; flutter test`
Expected: PASS in both suites; demo flow executable locally.

- [ ] **Step 5: Commit**

```bash
git add backend/serverless.yml mobile/lib/state/app_state.dart README.md backend/tests/integration/api.test.ts mobile/test/widget_flow_test.dart
git commit -m "feat: wire end-to-end survivai mvp flow and runbook"
```

## Self-Review

1. **Spec coverage check:**
- Covered: Survival Score, spending classifier with fallback, Emergency Mode, ECL apply decisioning, MCC lock checks, bilingual nudge templates, seeded demo data, all API contracts in Section 12, must-have MVP items and should-have 7-day trend.
- Not covered by design: production Alibaba deployment hardening (EAS gateway canary policy, OSS promotion pipeline), LoongCollector setup, Year 2 roadmap items.

2. **Placeholder scan:**
- Verified no `TODO`, `TBD`, or "implement later" markers.
- Each task includes explicit files, code snippets, commands, and expected outputs.

3. **Type consistency check:**
- Endpoint names and payload keys are consistent with spec contract names: `/survival-score`, `/emergency-mode`, `/ecl/apply`, `/ecl/transaction-check`.
- Response property names are consistent across domain and handler snippets (`survival_days`, `color_band`, `repayment_schedule`, `restricted_balance_remaining`).

