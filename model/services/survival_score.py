def get_color_band(survival_days: float) -> str:
    if survival_days >= 90:
        return "green"
    elif survival_days >= 30:
        return "yellow"
    return "red"

def calculate_survival_score(
    wallet_balance: float,
    predicted_daily_total_spend: float,
    predicted_daily_need_spend: float,
) -> dict:
    """
    Realistic score = based on predicted total spending.
    Emergency score = based on need-only spending.
    """

    if predicted_daily_total_spend <= 0:
        realistic_survival_days = 999
    else:
        realistic_survival_days = wallet_balance / predicted_daily_total_spend

    if predicted_daily_need_spend <= 0:
        emergency_survival_days = 999
    else:
        emergency_survival_days = wallet_balance / predicted_daily_need_spend

    potential_days_saved = emergency_survival_days - realistic_survival_days

    return {
        "wallet_balance": round(wallet_balance, 2),
        "survival_days": round(realistic_survival_days, 1),
        "emergency_survival_days": round(emergency_survival_days, 1),
        "potential_days_saved": round(potential_days_saved, 1),
        "daily_total_burn_rate": round(predicted_daily_total_spend, 2),
        "daily_need_burn_rate": round(predicted_daily_need_spend, 2),
        "color_band": get_color_band(realistic_survival_days),
    }

def calculate_score_delta(previous_score: float, new_score: float) -> float:
    if previous_score <= 0:
        return 0.0

    return round(((new_score - previous_score) / previous_score) * 100, 2)