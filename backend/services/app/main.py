from fastapi import FastAPI, Query

from app.clients.sagemaker_client import predict_spending
from app.logic.survival import compute_survival
from app.schemas import SurvivalScoreResponse
from app.settings import Settings

app = FastAPI(title="SurvivAI API")
settings = Settings()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/survival-score", response_model=SurvivalScoreResponse)
def get_survival_score(user_id: str = Query(...)) -> SurvivalScoreResponse:
    if settings.use_sagemaker:
        prediction = predict_spending(
            payload={"user_id": user_id},
            region=settings.aws_region,
            endpoint_name=settings.sagemaker_endpoint_name,
        )
        daily_burn = float(prediction["daily_burn_rate"])
        top_discretionary_category = str(prediction["top_discretionary_category"])
        top_discretionary_amount = float(prediction["top_discretionary_amount_7d"])
    else:
        daily_burn = 7.9
        top_discretionary_category = "Grab Food"
        top_discretionary_amount = 42.0

    wallet_balance = 87.0
    result = compute_survival(wallet_balance=wallet_balance, daily_burn_rate=daily_burn)

    return SurvivalScoreResponse(
        user_id=user_id,
        survival_days=result["survival_days"],
        daily_burn_rate=daily_burn,
        wallet_balance=wallet_balance,
        trend_7d="declining",
        color_band=result["color_band"],
        top_discretionary_category=top_discretionary_category,
        top_discretionary_amount_7d=top_discretionary_amount,
        emergency_mode=result["survival_days"] <= 5,
    )
