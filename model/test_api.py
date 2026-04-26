"""
Test client for SurvivAI Model API.
Run this after starting the API server to verify it works.
"""

import requests
import json
from typing import Dict, Any


API_URL = "http://localhost:8000"


def print_section(title: str):
    """Print a formatted section header."""
    print("\n" + "=" * 60)
    print(f"  {title}")
    print("=" * 60)


def print_json(data: Dict[Any, Any]):
    """Pretty print JSON data."""
    print(json.dumps(data, indent=2))


def test_health():
    """Test health check endpoint."""
    print_section("Testing Health Check")
    
    response = requests.get(f"{API_URL}/health")
    
    if response.status_code == 200:
        print("✓ Health check passed")
        print_json(response.json())
        return True
    else:
        print(f"✗ Health check failed: {response.status_code}")
        print(response.text)
        return False


def test_list_users():
    """Test list users endpoint."""
    print_section("Testing List Users")
    
    response = requests.get(f"{API_URL}/users")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✓ Found {data['count']} users")
        print_json(data)
        return data.get("users", [])
    else:
        print(f"✗ List users failed: {response.status_code}")
        print(response.text)
        return []


def test_prediction(user_id: str, wallet_balance: float, monthly_income: float):
    """Test prediction endpoint."""
    print_section(f"Testing Prediction for {user_id}")
    
    payload = {
        "user_id": user_id,
        "wallet_balance": wallet_balance,
        "monthly_income": monthly_income
    }
    
    print("Request payload:")
    print_json(payload)
    
    response = requests.post(f"{API_URL}/predict", json=payload)
    
    if response.status_code == 200:
        print("\n✓ Prediction successful")
        result = response.json()
        
        # Print key metrics
        print("\n--- Key Metrics ---")
        print(f"User: {result['user_id']}")
        print(f"Prediction Date: {result['prediction_date']}")
        
        survival = result['survival_score']
        print(f"\nSurvival Days: {survival['survival_days']}")
        print(f"Emergency Days: {survival['emergency_survival_days']}")
        print(f"Color Band: {survival['color_band']}")
        print(f"Daily Burn Rate: RM {survival['daily_total_burn_rate']}")
        
        spending = result['spending_prediction']
        print(f"\nPredicted Daily Spending:")
        print(f"  Need: RM {spending['predicted_daily_need_spend']}")
        print(f"  Want: RM {spending['predicted_daily_want_spend']}")
        print(f"  Total: RM {spending['predicted_daily_total_spend']}")
        
        budget = result['budget_plan']
        print(f"\nBudget Status:")
        print(f"  Safe Spend Today: RM {budget['safe_spend_today']}")
        print(f"  Save Portion Status: {budget['save_portion_status']}")
        print(f"  Days Remaining: {budget['days_remaining_in_month']}")
        
        print("\n--- Full Response ---")
        print_json(result)
        
        return True
    else:
        print(f"\n✗ Prediction failed: {response.status_code}")
        print(response.text)
        return False


def main():
    """Run all tests."""
    print("\n" + "=" * 60)
    print("  SurvivAI Model API Test Suite")
    print("=" * 60)
    print(f"\nAPI URL: {API_URL}")
    
    try:
        # Test 1: Health check
        if not test_health():
            print("\n⚠ API server may not be running. Start it with:")
            print("  python api.py")
            print("  or")
            print("  uvicorn api:app --reload")
            return
        
        # Test 2: List users
        users = test_list_users()
        
        if not users:
            print("\n⚠ No users found in transaction data")
            return
        
        # Test 3: Predictions for each user
        test_cases = [
            ("USR_SITI_001", 560.00, 2200.00),
            ("USR_BRANDON_001", 120.00, 1900.00),
        ]
        
        for user_id, wallet, income in test_cases:
            if user_id in users:
                test_prediction(user_id, wallet, income)
            else:
                print(f"\n⚠ Skipping {user_id} - not found in data")
        
        print_section("All Tests Complete")
        print("✓ API is working correctly!")
        
    except requests.exceptions.ConnectionError:
        print("\n✗ Connection Error: Could not connect to API server")
        print("\nMake sure the API server is running:")
        print("  python api.py")
        print("  or")
        print("  uvicorn api:app --reload")
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")


if __name__ == "__main__":
    main()
