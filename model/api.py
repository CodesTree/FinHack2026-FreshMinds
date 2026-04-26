"""
FastAPI backend for SurvivAI model.
Exposes prediction endpoints for direct backend integration.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import pandas as pd
from datetime import datetime

from services.transaction_processor import prepare_transactions, get_90_day_history
from services.spending_model import predict_today_spending
from services.survival_score import calculate_survival_score
from services.budget_planner import calculate_budget_plan


app = FastAPI(
    title="SurvivAI Model API",
    description="Backend API for financial survival predictions",
    version="1.0.0"
)

# CORS middleware for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Cache the transaction data to avoid reloading
_transaction_cache: Optional[pd.DataFrame] = None


def get_transaction_data() -> pd.DataFrame:
    """Load and cache transaction data."""
    global _transaction_cache
    if _transaction_cache is None:
        _transaction_cache = prepare_transactions(debug=False)
    return _transaction_cache


# Request/Response Models
class PredictionRequest(BaseModel):
    user_id: str = Field(..., description="User identifier")
    prediction_date: Optional[str] = Field(None, description="Date for prediction (YYYY-MM-DD). Defaults to today.")
    wallet_balance: float = Field(..., description="Current wallet balance in RM", ge=0)
    monthly_income: float = Field(..., description="Monthly income in RM", ge=0)


class PredictionResponse(BaseModel):
    user_id: str
    prediction_date: str
    history_days_used: int
    spending_prediction: Dict[str, Any]
    survival_score: Dict[str, Any]
    budget_plan: Dict[str, Any]


class HealthResponse(BaseModel):
    status: str
    timestamp: str
    data_loaded: bool
    total_transactions: int
    unique_users: int


@app.get("/", response_model=Dict[str, str])
async def root():
    """Root endpoint."""
    return {
        "message": "SurvivAI Model API",
        "docs": "/docs",
        "health": "/health"
    }


@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    try:
        df = get_transaction_data()
        return HealthResponse(
            status="healthy",
            timestamp=datetime.now().isoformat(),
            data_loaded=True,
            total_transactions=len(df),
            unique_users=len(df["user_id"].unique())
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")


@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Generate spending prediction, survival score, and budget plan for a user.
    
    This endpoint combines all model components:
    - Spending prediction (need/want breakdown)
    - Survival score (days until wallet depletes)
    - Budget planner (60/30/10 rule analysis)
    """
    try:
        df = get_transaction_data()
        
        # Use today if no prediction date provided
        prediction_date = request.prediction_date or datetime.now().strftime("%Y-%m-%d")
        
        # Validate user exists
        user_ids = df["user_id"].astype(str).str.lower().unique()
        if request.user_id.lower() not in user_ids:
            raise HTTPException(
                status_code=404,
                detail=f"User {request.user_id} not found in transaction data"
            )
        
        # Get 90-day history
        history_df = get_90_day_history(
            df=df,
            user_id=request.user_id,
            prediction_date=prediction_date,
        )
        
        # Spending prediction
        spending_prediction = predict_today_spending(
            history_df=history_df,
            prediction_date=prediction_date,
        )
        
        # Survival score
        survival_score = calculate_survival_score(
            wallet_balance=request.wallet_balance,
            predicted_daily_total_spend=spending_prediction["predicted_daily_total_spend"],
            predicted_daily_need_spend=spending_prediction["predicted_daily_need_spend"],
        )
        
        # Budget plan
        budget_plan = calculate_budget_plan(
            df=df,
            user_id=request.user_id,
            prediction_date=prediction_date,
            monthly_income=request.monthly_income,
            spending_prediction=spending_prediction,
        )
        
        return PredictionResponse(
            user_id=request.user_id,
            prediction_date=prediction_date,
            history_days_used=90,
            spending_prediction=spending_prediction,
            survival_score=survival_score,
            budget_plan=budget_plan,
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")


@app.get("/users")
async def list_users():
    """List all available users in the transaction data."""
    try:
        df = get_transaction_data()
        users = df["user_id"].unique().tolist()
        return {
            "users": users,
            "count": len(users)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list users: {str(e)}")


@app.post("/reload-data")
async def reload_data():
    """Reload transaction data from disk."""
    global _transaction_cache
    try:
        _transaction_cache = None
        df = get_transaction_data()
        return {
            "status": "success",
            "message": "Transaction data reloaded",
            "total_transactions": len(df),
            "unique_users": len(df["user_id"].unique())
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to reload data: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
