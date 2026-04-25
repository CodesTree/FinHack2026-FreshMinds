from pathlib import Path
import json
import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data"

TRANSACTION_PATH = DATA_DIR / "transaction.xlsx"
MCC_MAPPING_PATH = DATA_DIR / "mcc_mapping.json"


def load_mcc_mapping():
    with open(MCC_MAPPING_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def normalise_columns(df: pd.DataFrame) -> pd.DataFrame:
    df.columns = (
        df.columns.astype(str)
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace("-", "_")
    )
    return df


def find_column(df: pd.DataFrame, possible_names: list[str]) -> str:
    for name in possible_names:
        if name in df.columns:
            return name

    raise ValueError(f"Missing required column. Expected one of: {possible_names}")

def normalise_bucket(value: str) -> str:
    value = str(value).lower().strip()

    bucket_map = {
        "need": "need",
        "needs": "need",
        "essential": "need",
        "essentials": "need",

        "want": "want",
        "wants": "want",
        "discretionary": "want",
        "non_essential": "want",
        "non-essential": "want",

        "save": "save",
        "saving": "save",
        "savings": "save",

        "income": "income",
        "topup": "income",
        "top_up": "income",
        "wallet_topup": "income",
        "income_topup": "income",
    }

    return bucket_map.get(value, value)


def parse_excel_date_column(series: pd.Series) -> pd.Series:
    """
    Handles both:
    1. Normal date string: 2026-01-01
    2. Excel serial number: 46023
    """

    numeric_series = pd.to_numeric(series, errors="coerce")

    # If most values are numeric and look like Excel serial dates
    if numeric_series.notna().mean() > 0.8:
        return pd.to_datetime(
            numeric_series,
            unit="D",
            origin="1899-12-30",
            errors="coerce"
        )

    return pd.to_datetime(series, errors="coerce")

def load_transactions() -> pd.DataFrame:
    df = pd.read_excel(TRANSACTION_PATH)
    df = normalise_columns(df)

    user_col = find_column(df, ["user_id", "userid", "user", "customer_id"])
    date_col = find_column(df, ["transaction_date", "date", "timestamp", "created_at", "paid_time"])
    amount_col = find_column(df, ["amount", "transaction_amount", "amount_rm", "value", "amount_value"])
    mcc_col = find_column(df, ["mcc", "merchant_mcc", "merchantmcc", "mcc_code"])

    df = df.rename(
        columns={
            user_col: "user_id",
            date_col: "transaction_date",
            amount_col: "amount",
            mcc_col: "mcc",
        }
    )

    df["transaction_date"] = parse_excel_date_column(df["transaction_date"])

    df["amount"] = pd.to_numeric(df["amount"], errors="coerce").fillna(0)

    # If amount is in cents/sen, convert to RM.
    # Example: 4500 means RM45.00
    if df["amount"].median() > 1000:
        df["amount"] = df["amount"] / 100

    df["mcc"] = (
        df["mcc"]
        .astype(str)
        .str.replace(".0", "", regex=False)
        .str.strip()
    )

    return df

def classify_transactions(df: pd.DataFrame) -> pd.DataFrame:
    mcc_mapping = load_mcc_mapping()

    buckets = []
    subcategories = []
    emergency_allowed = []
    risk_levels = []

    for _, row in df.iterrows():
        mcc = str(row["mcc"]).strip()
        info = mcc_mapping.get(mcc, {})

        mapped_bucket = info.get("bucket")
        existing_bucket = row.get("bucket", "unknown")

        if mapped_bucket not in [None, "", "nan"]:
            bucket = mapped_bucket
        else:
            bucket = existing_bucket

        buckets.append(normalise_bucket(bucket))
        subcategories.append(info.get("subcategory", row.get("subcategory", "unknown")))
        emergency_allowed.append(info.get("emergency_mode_allowed", row.get("emergency_mode_allowed", False)))
        risk_levels.append(info.get("risk_level", row.get("risk_level", "unknown")))

    df["bucket"] = buckets
    df["subcategory"] = subcategories
    df["emergency_mode_allowed"] = emergency_allowed
    df["risk_level"] = risk_levels

    return df

def prepare_transactions(debug: bool = True) -> pd.DataFrame:
    df = load_transactions()
    df = classify_transactions(df)

    df["date"] = df["transaction_date"].dt.date
    df["month"] = df["transaction_date"].dt.to_period("M").astype(str)
    df["day_of_week"] = df["transaction_date"].dt.dayofweek
    df["day_of_month"] = df["transaction_date"].dt.day
    df["is_weekend"] = df["day_of_week"].isin([5, 6]).astype(int)

    if debug:
        print("\n=== RAW DEBUG BEFORE SPENDING FILTER ===")
        print("Total raw rows:", len(df))
        print("Raw users:", df["user_id"].unique())
        print("Raw date range:", df["transaction_date"].min(), "to", df["transaction_date"].max())
        print("Raw bucket counts:")
        print(df["bucket"].value_counts(dropna=False))

        print("\nRaw sample:")
        print(
            df[
                [
                    "user_id",
                    "transaction_date",
                    "amount",
                    "mcc",
                    "bucket",
                    "subcategory",
                ]
            ].head(20)
        )

    # Only spending transactions are used for the spending model.
    # Income/top-up rows are excluded.
    spending_df = df[df["bucket"].isin(["need", "want"])].copy()

    return spending_df

def get_90_day_history(
    df: pd.DataFrame,
    user_id: str,
    prediction_date: str
) -> pd.DataFrame:
    prediction_date = pd.to_datetime(prediction_date)
    start_date = prediction_date - pd.Timedelta(days=90)

    user_df = df[
        (df["user_id"].astype(str).str.lower() == str(user_id).lower())
        & (df["transaction_date"] >= start_date)
        & (df["transaction_date"] < prediction_date)
    ].copy()

    return user_df