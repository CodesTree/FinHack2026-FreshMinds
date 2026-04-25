from services.transaction_processor import prepare_transactions, get_90_day_history
from services.spending_model import predict_today_spending
from services.survival_score import calculate_survival_score
from services.budget_planner import calculate_budget_plan
from services.model_evaluation import evaluate_all_users_monthly


USER_WALLET_BALANCE = {
    "USR_SITI_001": 560,
    "USR_BRANDON_001": 120,
}


USER_MONTHLY_INCOME = {
    "USR_SITI_001": 2200,
    "USR_BRANDON_001": 1900,
}


def run_user_prediction(user_id: str, prediction_date: str, df):
    history_df = get_90_day_history(
        df=df,
        user_id=user_id,
        prediction_date=prediction_date,
    )

    print(f"\nDEBUG: {user_id} history rows = {len(history_df)}")

    spending_prediction = predict_today_spending(
        history_df=history_df,
        prediction_date=prediction_date,
    )

    wallet_balance = USER_WALLET_BALANCE.get(str(user_id), 0)
    monthly_income = USER_MONTHLY_INCOME.get(str(user_id), 0)

    survival_score = calculate_survival_score(
        wallet_balance=wallet_balance,
        predicted_daily_total_spend=spending_prediction["predicted_daily_total_spend"],
        predicted_daily_need_spend=spending_prediction["predicted_daily_need_spend"],
    )

    budget_plan = calculate_budget_plan(
        df=df,
        user_id=user_id,
        prediction_date=prediction_date,
        monthly_income=monthly_income,
        spending_prediction=spending_prediction,
    )

    return {
        "user_id": user_id,
        "prediction_date": prediction_date,
        "history_days_used": 90,
        "spending_prediction": spending_prediction,
        "survival_score": survival_score,
        "budget_plan": budget_plan,
    }


def print_prediction_result(result: dict):
    print("\n==============================")
    print(f"User: {result['user_id']}")
    print("==============================")

    print("\nSpending Prediction:")
    print(result["spending_prediction"])

    print("\nSurvival Score:")
    print(result["survival_score"])

    print("\nBudget Planner:")
    print(result["budget_plan"])


def print_evaluation_results(evaluation_results: list[dict]):
    print("\n\n==============================")
    print("MONTHLY MODEL EVALUATION")
    print("==============================")

    for result in evaluation_results:
        print("\n------------------------------")
        print(f"User: {result['user_id']}")
        print("------------------------------")

        if "message" in result:
            print(result["message"])
            continue

        print("Evaluation month:", result["evaluation_month"])
        print("Prediction date:", result["prediction_date"])
        print("Model used:", result["model_used"])

        print("\nPredicted Daily Spend:")
        print({
            "need": result["predicted_daily_need_spend"],
            "want": result["predicted_daily_want_spend"],
            "total": result["predicted_daily_total_spend"],
        })

        print("\nPredicted Monthly Spend:")
        print({
            "need": result["predicted_monthly_need_spend"],
            "want": result["predicted_monthly_want_spend"],
            "total": result["predicted_monthly_total_spend"],
        })

        print("\nActual Monthly Spend:")
        print({
            "need": result["actual_monthly_need_spend"],
            "want": result["actual_monthly_want_spend"],
            "total": result["actual_monthly_total_spend"],
        })

        print("\nMonthly Error:")
        print({
            "need_mae_rm": result["need_mae_rm"],
            "want_mae_rm": result["want_mae_rm"],
            "total_mae_rm": result["total_mae_rm"],
            "total_error_pct": result["total_error_pct"],
        })


def main():
    print("Starting SurvivAI backend...")

    prediction_date = "2026-04-20"

    df = prepare_transactions(debug=True)

    print("\n=== DEBUG: Data After Filtering Need/Want ===")
    print(df.head())

    print("\n=== DEBUG: Total Rows After Filtering Need/Want ===")
    print(len(df))

    print("\n=== DEBUG: Unique Users ===")
    print(df["user_id"].unique())

    print("\n=== DEBUG: Date Range ===")
    print(df["transaction_date"].min(), "to", df["transaction_date"].max())

    print("\n=== DEBUG: Bucket Counts ===")
    print(df["bucket"].value_counts(dropna=False))

    print("\n=== DEBUG: Subcategory Counts ===")
    print(df["subcategory"].value_counts(dropna=False).head(20))

    # 1. Prediction + Survival Score + Budget Planner
    for user_id in df["user_id"].unique():
        result = run_user_prediction(
            user_id=str(user_id),
            prediction_date=prediction_date,
            df=df,
        )

        print_prediction_result(result)

    # 2. Model evaluation
    evaluation_results = evaluate_all_users_monthly(
    df=df,
    prediction_date="2026-04-01",
    evaluation_month="2026-04",
    )

    print_evaluation_results(evaluation_results)


if __name__ == "__main__":
    main()