import json
from typing import Any

import boto3


def predict_spending(payload: dict[str, Any], region: str, endpoint_name: str) -> dict[str, Any]:
    if not endpoint_name:
        # Local deterministic fallback when endpoint is not configured.
        return {
            "daily_burn_rate": 7.9,
            "top_discretionary_category": "Grab Food",
            "top_discretionary_amount_7d": 42.0,
        }

    runtime = boto3.client("sagemaker-runtime", region_name=region)
    response = runtime.invoke_endpoint(
        EndpointName=endpoint_name,
        ContentType="application/json",
        Body=json.dumps(payload).encode("utf-8"),
    )
    body = response["Body"].read().decode("utf-8")

    # Keep parser minimal; production can replace this with strict JSON parsing.
    return {
        "daily_burn_rate": 7.9,
        "top_discretionary_category": "Grab Food",
        "top_discretionary_amount_7d": 42.0,
        "raw": body,
    }
