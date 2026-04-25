
import pandas as pd

from services.transaction_processor import get_90_day_history
from services.spending_model import predict_today_spending


def get_actual_monthly_spending(df: pd.DataFrame, user_id: str, month: str) -> dict:
    month_df = df[
        (df["user_id"].astype(str).str.lower() == str(user_id).lower())
        & (df["month"] == month)
    ].copy()

    actual_need = month_df[month_df["bucket"] == "need"]["amount"].sum()
    actual_want = month_df[month_df["bucket"] == "want"]["amount"].sum()
    actual_total = actual_need + actual_want

    return {
        "actual_monthly_need_spend": round(float(actual_need), 2),
        "actual_monthly_want_spend": round(float(actual_want), 2),
        "actual_monthly_total_spend": round(float(actual_total), 2),
    }


def evaluate_user_monthly_model(
    df: pd.DataFrame,
    user_id: str,
    prediction_date: str = "2026-04-01",
    evaluation_month: str = "2026-04",
) -> dict:
    """
    Better evaluation for Survival Score model.

    We predict daily burn rate from the previous 90 days,
    then compare predicted monthly spending with actual monthly spending.
    """

    history_df = get_90_day_history(
        df=df,
        user_id=user_id,
        prediction_date=prediction_date,
    )

    if history_df.empty:
        return {
            "user_id": user_id,
            "message": "No history available for evaluation.",
        }

    prediction = predict_today_spending(
        history_df=history_df,
        prediction_date=prediction_date,
    )

    actual = get_actual_monthly_spending(
        df=df,
        user_id=user_id,
        month=evaluation_month,
    )

    predicted_monthly_need = prediction["predicted_daily_need_spend"] * 30
    predicted_monthly_want = prediction["predicted_daily_want_spend"] * 30
    predicted_monthly_total = prediction["predicted_daily_total_spend"] * 30

    need_error = actual["actual_monthly_need_spend"] - predicted_monthly_need
    want_error = actual["actual_monthly_want_spend"] - predicted_monthly_want
    total_error = actual["actual_monthly_total_spend"] - predicted_monthly_total

    return {
        "user_id": user_id,
        "evaluation_month": evaluation_month,
        "prediction_date": prediction_date,
        "model_used": prediction["model_used"],

        "predicted_daily_need_spend": prediction["predicted_daily_need_spend"],
        "predicted_daily_want_spend": prediction["predicted_daily_want_spend"],
        "predicted_daily_total_spend": prediction["predicted_daily_total_spend"],

        "predicted_monthly_need_spend": round(predicted_monthly_need, 2),
        "predicted_monthly_want_spend": round(predicted_monthly_want, 2),
        "predicted_monthly_total_spend": round(predicted_monthly_total, 2),

        "actual_monthly_need_spend": actual["actual_monthly_need_spend"],
        "actual_monthly_want_spend": actual["actual_monthly_want_spend"],
        "actual_monthly_total_spend": actual["actual_monthly_total_spend"],

        "need_mae_rm": round(abs(need_error), 2),
        "want_mae_rm": round(abs(want_error), 2),
        "total_mae_rm": round(abs(total_error), 2),

        "total_error_pct": round(
            abs(total_error) / actual["actual_monthly_total_spend"] * 100,
            2
        ) if actual["actual_monthly_total_spend"] > 0 else None,
    }


def evaluate_all_users_monthly(
    df: pd.DataFrame,
    prediction_date: str = "2026-04-01",
    evaluation_month: str = "2026-04",
) -> list[dict]:
    results = []

    for user_id in df["user_id"].unique():
        results.append(
            evaluate_user_monthly_model(
                df=df,
                user_id=str(user_id),
                prediction_date=prediction_date,
                evaluation_month=evaluation_month,
            )
        )

    return results