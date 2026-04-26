from app.logic.survival import compute_survival


def test_compute_survival_returns_red_for_low_runway():
    result = compute_survival(wallet_balance=87.0, daily_burn_rate=7.9)
    assert result["survival_days"] == 11
    assert result["color_band"] == "red"
