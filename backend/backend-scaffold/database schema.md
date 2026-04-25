## 12. Database Schema

### 12.1 ApsaraDB RDS (Alibaba Cloud) — MySQL

**users**
```sql
CREATE TABLE users (
  user_id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100),
  wallet_balance DECIMAL(10,2),
  monthly_income DECIMAL(10,2),
  income_tier ENUM('B40','M40','T20') DEFAULT 'B40',
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
  transaction_id VARCHAR(36) PRIMARY KEY,

  user_id VARCHAR(36) NOT NULL,

  transaction_timestamp TIMESTAMP NOT NULL,

  reference_order_id VARCHAR(100),
  order_description TEXT,

  currency CHAR(3) DEFAULT 'MYR',

  -- Original value from provider (usually in cents)
  amount_value BIGINT NOT NULL,

  -- Human readable RM amount
  amount_rm DECIMAL(12,2) NOT NULL,

  direction ENUM('CREDIT', 'DEBIT') NOT NULL,

  source VARCHAR(50),

  payment_method_type VARCHAR(50),

  reference_merchant_id VARCHAR(100),

  merchant_mcc VARCHAR(10),

  merchant_name VARCHAR(255),

  merchant_display_name VARCHAR(255),

  -- MCC-based category
  mcc_category VARCHAR(100),

  -- Needs / Wants / Income
  bucket ENUM(
    'Needs',
    'Wants',
    'Income',
    'Savings',
    'Transfers',
    'Unknown'
  ) DEFAULT 'Unknown',

  -- rental, groceries, utilities, etc.
  subcategory VARCHAR(100),

  -- AI classifier output
  classifier_category ENUM(
    'Essential',
    'Discretionary',
    'Savings',
    'Income',
    'Unknown'
  ) DEFAULT 'Unknown',

  category_confidence DECIMAL(4,3) DEFAULT 0.000,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(user_id),

  INDEX idx_user_timestamp (user_id, transaction_timestamp),
  INDEX idx_bucket (bucket),
  INDEX idx_subcategory (subcategory),
  INDEX idx_classifier (classifier_category),
  INDEX idx_mcc (merchant_mcc),
  INDEX idx_merchant (merchant_name)
);
```

**scores**
```sql
CREATE TABLE scores (
  score_id VARCHAR(36) PRIMARY KEY,

  user_id VARCHAR(36) NOT NULL,

  survival_days INT,

  daily_burn_rate DECIMAL(12,2),

  needs_pct DECIMAL(5,2),
  wants_pct DECIMAL(5,2),
  savings_pct DECIMAL(5,2),

  total_income DECIMAL(12,2),
  total_expenses DECIMAL(12,2),

  emergency_survival_days DECIMAL(5,2),

  color_band ENUM(
    'green',
    'yellow',
    'red'
  ),

  computed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(user_id),

  INDEX idx_user_time (user_id, computed_at)
);
```

**nudge_log**
```sql
CREATE TABLE nudge_log (
  nudge_id VARCHAR(36) PRIMARY KEY,

  user_id VARCHAR(36) NOT NULL,

  transaction_id VARCHAR(36) NULL,

  slot ENUM('morning', 'afternoon', 'evening'),

  nudge_type VARCHAR(50),

  nudge_text TEXT,

  bucket VARCHAR(50),

  subcategory VARCHAR(100),

  amount_rm DECIMAL(12,2),

  predicted_savings_rm DECIMAL(12,2),

  survival_days_delta INT,

  acknowledged BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(user_id),

  FOREIGN KEY (transaction_id)
    REFERENCES transactions(transaction_id),

  INDEX idx_user_created (user_id, created_at)
);
  
