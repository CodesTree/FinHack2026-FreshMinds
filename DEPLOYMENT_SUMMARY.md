# SurvivAI Model - AWS Deployment Summary

## What's Been Set Up

I've created a complete AWS deployment solution for your SurvivAI model. Here's what you now have:

### Files Created

```
backend/
├── lambda_handler.py          # AWS Lambda entry point
├── Dockerfile                 # Container configuration
├── deploy.sh                  # Deployment script (Linux/Mac)
├── deploy.ps1                 # Deployment script (Windows)
├── test_local.py              # Local testing script
├── README.md                  # Detailed backend guide
└── QUICK_START.md             # 5-minute quick start

docs/
└── AWS_DEPLOYMENT_GUIDE.md    # Complete deployment guide
```

## How It Works

1. **Your Model** → Packaged in Docker container
2. **Docker Image** → Pushed to AWS ECR (Elastic Container Registry)
3. **Lambda Function** → Runs your containerized model
4. **API Gateway** → Exposes HTTP endpoint for predictions
5. **Clients** → Send requests via REST API

## Quick Start (3 Steps)

### 1. Configure AWS
```bash
aws configure
# Enter your AWS credentials
```

### 2. Deploy
```bash
cd backend
./deploy.sh          # macOS/Linux
# OR
.\deploy.ps1         # Windows
```

### 3. Test
```bash
curl -X POST https://<API_ID>.execute-api.us-east-1.amazonaws.com/predict \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "USR_SITI_001",
    "prediction_date": "2026-04-20",
    "wallet_balance": 560,
    "monthly_income": 2200
  }'
```

## API Endpoint

After deployment, you'll have an HTTP endpoint that accepts:

**Request:**
```json
{
  "user_id": "USR_SITI_001",
  "prediction_date": "2026-04-20",
  "wallet_balance": 560,
  "monthly_income": 2200
}
```

**Response:**
```json
{
  "user_id": "USR_SITI_001",
  "prediction_date": "2026-04-20",
  "spending_prediction": {
    "predicted_daily_total_spend": 57.73,
    "predicted_monthly_total_spend": 1732.00,
    "spending_by_subcategory": { ... }
  },
  "survival_score": {
    "survival_days": 9.7,
    "color_band": "red"
  },
  "budget_plan": {
    "monthly_income": 2200,
    "budget_60_30_10": { ... }
  }
}
```

## Key Features

✅ **Containerized** - Docker ensures consistency across environments
✅ **Serverless** - No servers to manage, auto-scaling included
✅ **Cost-Effective** - Pay only for what you use (~$1/month for typical usage)
✅ **Scalable** - Handles 1000s of concurrent requests
✅ **Monitored** - CloudWatch logs and metrics included
✅ **Easy Deployment** - One-command deployment scripts

## Architecture

```
┌─────────────────────────────────────────┐
│         Your Application                │
│      (Web/Mobile/Desktop)               │
└────────────────┬────────────────────────┘
                 │ HTTP Request
                 ▼
┌─────────────────────────────────────────┐
│         API Gateway (HTTP)              │
│      (Handles routing & auth)           │
└────────────────┬────────────────────────┘
                 │ Invoke
                 ▼
┌─────────────────────────────────────────┐
│      AWS Lambda Function                │
│   (Runs your model in container)        │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │  Docker Container               │  │
│  │  ├─ Python Runtime              │  │
│  │  ├─ Model Code                  │  │
│  │  ├─ Dependencies                │  │
│  │  └─ Lambda Handler              │  │
│  └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Estimated Costs

| Service | Free Tier | Typical Usage |
|---------|-----------|---------------|
| Lambda | 1M requests/month | $0.02 |
| API Gateway | 1M requests/month | $0.35 |
| ECR | 500 MB free | $0.10 |
| CloudWatch | 5 GB logs/month | $0.50 |
| **Total** | **Free** | **~$1.00/month** |

## Next Steps

1. **Deploy**: Run the deployment script
2. **Test**: Use curl or Postman to test the API
3. **Monitor**: Check CloudWatch logs for any issues
4. **Integrate**: Connect your frontend/app to the API
5. **Scale**: Add authentication, caching, or database as needed

## Documentation

- **Quick Start**: `backend/QUICK_START.md` (5 minutes)
- **Backend Guide**: `backend/README.md` (detailed)
- **Full Guide**: `docs/AWS_DEPLOYMENT_GUIDE.md` (comprehensive)

## Support

If you encounter issues:

1. Check the logs: `aws logs tail /aws/lambda/survivai-prediction --follow`
2. Review the troubleshooting section in `docs/AWS_DEPLOYMENT_GUIDE.md`
3. Verify AWS credentials: `aws sts get-caller-identity`
4. Ensure Docker is running: `docker ps`

## What's Included

### Lambda Handler (`lambda_handler.py`)
- Accepts HTTP requests from API Gateway
- Loads transaction data (cached for performance)
- Runs your model's prediction logic
- Returns JSON response

### Docker Container (`Dockerfile`)
- Uses AWS Lambda Python 3.11 runtime
- Installs all dependencies from `requirements.txt`
- Copies model code and data
- Optimized for Lambda execution

### Deployment Scripts
- **Linux/Mac**: `deploy.sh` - Bash script
- **Windows**: `deploy.ps1` - PowerShell script
- Automates: IAM setup, ECR creation, Docker build/push, Lambda creation, API Gateway setup

### Testing
- `test_local.py` - Test handler locally before deploying
- Includes test cases for valid/invalid requests

## Deployment Checklist

- [ ] AWS Account created
- [ ] AWS CLI installed and configured
- [ ] Docker installed and running
- [ ] `requirements.txt` updated with all dependencies
- [ ] Data files exist in `data/` directory
- [ ] Run deployment script
- [ ] Test API endpoint
- [ ] Monitor CloudWatch logs
- [ ] Integrate with your application

## Cleanup

When you're done, remove all resources to avoid charges:

```bash
aws lambda delete-function --function-name survivai-prediction
aws apigatewayv2 delete-api --api-id <API_ID>
aws iam delete-role --role-name survivai-lambda-role
aws ecr delete-repository --repository-name survivai-model --force
```

---

**Ready to deploy?** Start with `backend/QUICK_START.md` or run the deployment script!
