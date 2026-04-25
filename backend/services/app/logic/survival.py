def compute_survival(wallet_balance: float, daily_burn_rate: float) -> dict:
    if daily_burn_rate <= 0:
        survival_days = 999
    else:
        survival_days = int(wallet_balance // daily_burn_rate)

    if survival_days > 30:
        color_band = "green"
    elif survival_days >= 15:
        color_band = "amber"
    else:
        color_band = "red"

    return {"survival_days": survival_days, "color_band": color_band}
