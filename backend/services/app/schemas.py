from typing import Literal

from pydantic import BaseModel


class SurvivalScoreResponse(BaseModel):
    user_id: str
    survival_days: int
    daily_burn_rate: float
    wallet_balance: float
    trend_7d: Literal["improving", "stable", "declining"]
    color_band: Literal["green", "amber", "red"]
    top_discretionary_category: str
    top_discretionary_amount_7d: float
    emergency_mode: bool = False
    has_active_loan: bool = False
    monthly_income: float = 1800.0
    name: str = "Siti Nurhaliza"
