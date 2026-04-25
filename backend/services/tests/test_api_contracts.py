from fastapi.testclient import TestClient

from app.main import app
from app.schemas import SurvivalScoreResponse


def test_survival_contract_has_required_fields():
    payload = SurvivalScoreResponse(
        user_id="user_siti_001",
        survival_days=11,
        daily_burn_rate=7.9,
        wallet_balance=87.0,
        trend_7d="declining",
        color_band="red",
        top_discretionary_category="Grab Food",
        top_discretionary_amount_7d=42.0,
    )
    assert payload.color_band == "red"


def test_survival_endpoint_contract():
    client = TestClient(app)
    response = client.get("/api/survival-score", params={"user_id": "user_siti_001"})
    assert response.status_code == 200
    body = response.json()
    assert "survival_days" in body
    assert "daily_burn_rate" in body
