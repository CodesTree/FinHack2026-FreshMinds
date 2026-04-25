import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

with open(BASE_DIR / "mcc_mapping.json", "r", encoding="utf-8") as f:
    MCC_MAPPING = json.load(f)["mcc"]

def get_mcc_info(mcc_code: str) -> dict:
    code = str(mcc_code).zfill(4)
    return MCC_MAPPING.get(code, {
        "mcc_code": code,
        "merchant_category": "Unknown MCC",
        "bucket": "want",
        "subcategory": "unknown",
        "emergency_mode_allowed": False,
        "transaction_cap_rm": None,
        "monthly_cap_rm": None,
        "risk_level": "unknown",
        "block_reason": "Unknown MCC. Transaction requires review before approval.",
        "demo_examples": []
    })

def classify_transaction(transaction: dict) -> dict:
    info = get_mcc_info(transaction.get("mcc"))
    amount = float(transaction.get("amount_rm", 0))
    allowed = bool(info["emergency_mode_allowed"])
    cap = info.get("transaction_cap_rm")

    if allowed and cap is not None and amount > float(cap):
        allowed = False
        block_reason = f"Transaction exceeds RM{cap:.0f} cap for {info['subcategory']}."
    else:
        block_reason = None if allowed else info.get("block_reason")

    return {
        **transaction,
        "bucket": info["bucket"],
        "subcategory": info["subcategory"],
        "merchant_category": info["merchant_category"],
        "emergency_mode_allowed": allowed,
        "block_reason": block_reason,
        "risk_level": info["risk_level"]
    }
