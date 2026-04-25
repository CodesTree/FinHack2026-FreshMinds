from calendar import monthrange
import pandas as pd


def calculate_60_30_10_budget(monthly_income: float) -> dict:
    """
    60/30/10 rule:
    - 60% needs
    - 30% wants
    - 10% save portion
    """

    return {
        "need_budget": round(monthly_income * 0.60, 2),
        "want_budget": round(monthly_income * 0.30, 2),
        "save_goal": round(monthly_income * 0.10, 2),
        "max_spend_before_touching_save": round(monthly_income * 0.90, 2),
    }


def get_days_remaining_in_month(prediction_date: str) -> int:
    prediction_date = pd.to_datetime(prediction_date)

    last_day = monthrange(prediction_date.year, prediction_date.month)[1]

    return max(last_day - prediction_date.day + 1, 1)


def get_month_to_date_spending(df: pd.DataFrame, user_id: str, prediction_date: str) -> dict:
    """
    Calculates actual month-to-date spending before the prediction date.
    """

    prediction_date = pd.to_datetime(prediction_date)
    month_start = prediction_date.replace(day=1)

    user_month_df = df[
        (df["user_id"].astype(str).str.lower() == str(user_id).lower())
        & (df["transaction_date"] >= month_start)
        & (df["transaction_date"] < prediction_date)
    ].copy()

    need_spend = user_month_df[user_month_df["bucket"] == "need"]["amount"].sum()
    want_spend = user_month_df[user_month_df["bucket"] == "want"]["amount"].sum()
    total_spend = need_spend + want_spend

    return {
        "actual_need_spend_mtd": round(float(need_spend), 2),
        "actual_want_spend_mtd": round(float(want_spend), 2),
        "actual_total_spend_mtd": round(float(total_spend), 2),
    }


def get_top_risk_subcategory(spending_prediction: dict) -> dict:
    """
    Finds the highest predicted want subcategory.
    Useful for frontend nudges.
    """

    wants = [
        item for item in spending_prediction.get("predicted_subcategories", [])
        if item.get("bucket") == "want"
    ]

    if not wants:
        return {
            "subcategory": None,
            "predicted_amount_rm": 0,
        }

    top = max(wants, key=lambda x: x.get("predicted_amount_rm", 0))

    return {
        "subcategory": top.get("subcategory"),
        "predicted_amount_rm": round(float(top.get("predicted_amount_rm", 0)), 2),
    }


def calculate_budget_plan(
    df: pd.DataFrame,
    user_id: str,
    prediction_date: str,
    monthly_income: float,
    spending_prediction: dict,
) -> dict:
    """
    Main budget planner.

    Purpose:
    - Calculate whether the user is protecting the 10% save portion.
    - Calculate safe daily spend target.
    - Calculate projected spending until month-end.
    - Generate useful stats for frontend nudges.
    """

    budget = calculate_60_30_10_budget(monthly_income)

    mtd = get_month_to_date_spending(
        df=df,
        user_id=user_id,
        prediction_date=prediction_date,
    )

    days_remaining = get_days_remaining_in_month(prediction_date)

    predicted_daily_need = spending_prediction["predicted_daily_need_spend"]
    predicted_daily_want = spending_prediction["predicted_daily_want_spend"]
    predicted_daily_total = spending_prediction["predicted_daily_total_spend"]

    projected_need_until_month_end = predicted_daily_need * days_remaining
    projected_want_until_month_end = predicted_daily_want * days_remaining
    projected_total_until_month_end = predicted_daily_total * days_remaining

    projected_month_end_total_spend = (
        mtd["actual_total_spend_mtd"] + projected_total_until_month_end
    )

    projected_month_end_need_spend = (
        mtd["actual_need_spend_mtd"] + projected_need_until_month_end
    )

    projected_month_end_want_spend = (
        mtd["actual_want_spend_mtd"] + projected_want_until_month_end
    )

    remaining_need_budget = budget["need_budget"] - mtd["actual_need_spend_mtd"]
    remaining_want_budget = budget["want_budget"] - mtd["actual_want_spend_mtd"]

    remaining_safe_spend_before_touching_save = (
        budget["max_spend_before_touching_save"] - mtd["actual_total_spend_mtd"]
    )

    safe_spend_today = remaining_safe_spend_before_touching_save / days_remaining

    if mtd["actual_total_spend_mtd"] > budget["max_spend_before_touching_save"]:
        save_portion_status = "touched"
    elif projected_month_end_total_spend > budget["max_spend_before_touching_save"]:
        save_portion_status = "at_risk"
    else:
        save_portion_status = "protected"

    top_risk = get_top_risk_subcategory(spending_prediction)

    return {
        "monthly_income": round(monthly_income, 2),

        "need_budget": budget["need_budget"],
        "want_budget": budget["want_budget"],
        "save_goal": budget["save_goal"],
        "max_spend_before_touching_save": budget["max_spend_before_touching_save"],

        "actual_need_spend_mtd": mtd["actual_need_spend_mtd"],
        "actual_want_spend_mtd": mtd["actual_want_spend_mtd"],
        "actual_total_spend_mtd": mtd["actual_total_spend_mtd"],

        "remaining_need_budget": round(remaining_need_budget, 2),
        "remaining_want_budget": round(remaining_want_budget, 2),
        "remaining_safe_spend_before_touching_save": round(
            remaining_safe_spend_before_touching_save, 2
        ),

        "days_remaining_in_month": days_remaining,
        "safe_spend_today": round(max(safe_spend_today, 0), 2),

        "projected_need_until_month_end": round(projected_need_until_month_end, 2),
        "projected_want_until_month_end": round(projected_want_until_month_end, 2),
        "projected_total_until_month_end": round(projected_total_until_month_end, 2),

        "projected_month_end_need_spend": round(projected_month_end_need_spend, 2),
        "projected_month_end_want_spend": round(projected_month_end_want_spend, 2),
        "projected_month_end_total_spend": round(projected_month_end_total_spend, 2),

        "projected_wants_leakage_until_month_end": round(projected_want_until_month_end, 2),
        "save_portion_status": save_portion_status,

        "top_risk_subcategory": top_risk["subcategory"],
        "top_risk_subcategory_predicted_amount": top_risk["predicted_amount_rm"],
    }