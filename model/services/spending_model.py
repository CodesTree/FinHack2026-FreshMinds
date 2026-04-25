import pandas as pd


RECURRING_SUBCATEGORIES = {
    "rental",
    "utilities",
    "telecom",
}


def weighted_rolling_average(history_df: pd.DataFrame, subcategory: str) -> float:
    """
    Predict variable daily spending using personalised 7/30/90-day behaviour.
    This is used for groceries, food, transport, entertainment, etc.
    """

    if history_df.empty:
        return 0.0

    latest_date = history_df["transaction_date"].max()
    sub_df = history_df[history_df["subcategory"] == subcategory].copy()

    if sub_df.empty:
        return 0.0

    def avg_daily(days: int) -> float:
        start = latest_date - pd.Timedelta(days=days)
        temp = sub_df[sub_df["transaction_date"] >= start]

        if temp.empty:
            return 0.0

        return temp["amount"].sum() / days

    avg_7 = avg_daily(7)
    avg_30 = avg_daily(30)
    avg_90 = avg_daily(90)

    predicted = (avg_7 * 0.50) + (avg_30 * 0.30) + (avg_90 * 0.20)

    return round(float(predicted), 2)


def predict_recurring_daily_amount(history_df: pd.DataFrame, subcategory: str) -> float:
    """
    Predict daily cost of recurring bills.

    Example:
    Rent = RM650/month
    Daily rent burn = RM650 / 30 = RM21.67

    This prevents rent/utilities/telco from being treated as daily transactions.
    """

    sub_df = history_df[history_df["subcategory"] == subcategory].copy()

    if sub_df.empty:
        return 0.0

    sub_df["month"] = sub_df["transaction_date"].dt.to_period("M").astype(str)

    monthly_totals = (
        sub_df.groupby("month")["amount"]
        .sum()
        .reset_index()
    )

    if monthly_totals.empty:
        return 0.0

    predicted_monthly_amount = monthly_totals["amount"].median()
    predicted_daily_amount = predicted_monthly_amount / 30

    return round(float(predicted_daily_amount), 2)


def predict_today_spending(history_df: pd.DataFrame, prediction_date: str) -> dict:
    """
    Predict today's expected spending based on previous 90 days.

    Hybrid personalised model:
    - Recurring bills are converted into daily burn rate.
    - Variable spending uses weighted rolling average.
    """

    if history_df.empty:
        return {
            "prediction_date": prediction_date,
            "model_used": "no_history",
            "predicted_subcategories": [],
            "predicted_daily_need_spend": 0,
            "predicted_daily_want_spend": 0,
            "predicted_daily_total_spend": 0,
        }

    unique_subcategories = (
        history_df[["bucket", "subcategory"]]
        .drop_duplicates()
        .reset_index(drop=True)
    )

    predicted_subcategories = []

    for _, row in unique_subcategories.iterrows():
        bucket = row["bucket"]
        subcategory = row["subcategory"]

        if subcategory in RECURRING_SUBCATEGORIES:
            predicted_amount = predict_recurring_daily_amount(
                history_df=history_df,
                subcategory=subcategory,
            )
            forecast_method = "recurring_bill_daily_burn"
        else:
            predicted_amount = weighted_rolling_average(
                history_df=history_df,
                subcategory=subcategory,
            )
            forecast_method = "weighted_rolling_average"

        predicted_subcategories.append(
            {
                "bucket": bucket,
                "subcategory": subcategory,
                "predicted_amount_rm": round(float(predicted_amount), 2),
                "forecast_method": forecast_method,
            }
        )

    predicted_need = sum(
        item["predicted_amount_rm"]
        for item in predicted_subcategories
        if item["bucket"] == "need"
    )

    predicted_want = sum(
        item["predicted_amount_rm"]
        for item in predicted_subcategories
        if item["bucket"] == "want"
    )

    predicted_total = predicted_need + predicted_want

    predicted_subcategories = sorted(
        predicted_subcategories,
        key=lambda x: x["predicted_amount_rm"],
        reverse=True,
    )

    return {
        "prediction_date": prediction_date,
        "model_used": "hybrid_personalised_90d_forecast",
        "predicted_subcategories": predicted_subcategories,
        "predicted_daily_need_spend": round(float(predicted_need), 2),
        "predicted_daily_want_spend": round(float(predicted_want), 2),
        "predicted_daily_total_spend": round(float(predicted_total), 2),
    }