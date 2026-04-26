# SurvivAI Model - Complete AWS Deployment Guide

## Overview

This guide provides step-by-step instructions to deploy your SurvivAI model to AWS Lambda with an HTTP API endpoint.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Application                         │
│                    (Web/Mobile/Desktop)                      │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP Request
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (HTTP)                        │
│              (Handles routing & authentication)              │
└────────────────────────┬────────────────────────────────────┘
                         │ Invoke
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  AWS Lambda Function                         │
│              (Runs your model in container)                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Docker Container                                    │  │
│  │  ├─ Python Runtime                                   │  │
│  │  ├─ Model Code (main.py, services/)                 │  │
│  │  ├─ Dependencies (pandas, numpy, etc.)              │  │
│  │  └─ Lambda Handler (lambda_handler.py)              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Mounted Data Volume                                 │  │
│  │  ├─ transaction.xlsx                                │  │
│  │  ├─ mcc_mapping.json                                │  │
│  │  ├─ mcc_allowlist.json                              │  │
│  │  └─ mcc_blocklist.json                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                         │ Response
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  JSON Response                               │
│  {                                                           │
│    "user_id": "USR_SITI_001",                              │
│    "spending_prediction": {...},                           │
│    "survival_score": {...},                                │
│    "budget_plan": {...}                                    │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

### AWS Account Setup

1. **Create AWS Account** (if you don't have one)
   - Go to https://aws.amazon.com
   - Click "Create an AWS Account"
   - Follow the setup wizard

2. **Create IAM User** (recommended for security)
   - Go to AWS Console → IAM → Users
   - Create new user with programmatic access
   - Attach policies: `AdministratorAccess` (for testing) or specific policies below

3. **Required IAM Permissions**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "lambda:*",
           "apigatewayv2:*",
           "ecr:*",
           "iam:*",
           "logs:*"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

### Local Setup

1. **Install AWS CLI**
   ```bash
   # macOS
   brew install awscli
   
   # Windows (PowerShell)
   msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
   
   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. **Install Docker**
   - Download from https://www.docker.com/products/docker-desktop
   - Start Docker Desktop

3. **Configure AWS Credentials**
   ```bash
   aws configure
   ```
   When prompted, enter:
   - AWS Access Key ID: [from IAM user]
   - AWS Secret Access Key: [from IAM user]
   - Default region: us-east-1
   - Default output format: json

4. **Verify Setup**
   ```bash
   aws sts get-caller-identity
   ```
   Should return your AWS account info.

## Deployment Steps

### Step 1: Prepare Your Code

The deployment scripts expect this structure:
```
project/
├── model/
│   ├── main.py
│   ├── services/
│   │   ├── budget_planner.py
│   │   ├── mcc_loader.py
│   │   ├── model_evaluation.py
│   │   ├── spending_model.py
│   │   ├── survival_score.py
│   │   └── transaction_processor.py
│   └── __pycache__/
├── data/
│   ├── transaction.xlsx
│   ├── mcc_mapping.json
│   ├── mcc_allowlist.json
│   └── mcc_blocklist.json
├── backend/
│   ├── lambda_handler.py
│   ├── Dockerfile
│   ├── deploy.sh (or deploy.ps1)
│   └── README.md
└── requirements.txt
```

### Step 2: Update requirements.txt

Ensure all dependencies are listed:
```
pandas>=1.3.0
numpy>=1.21.0
openpyxl>=3.6.0
```

### Step 3: Run Deployment Script

**On macOS/Linux:**
```bash
cd backend
chmod +x deploy.sh
./deploy.sh
```

**On Windows (PowerShell):**
```powershell
cd backend
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\deploy.ps1
```

**With custom region:**
```powershell
.\deploy.ps1 -AwsRegion us-west-2
```

### Step 4: Wait for Deployment

The script will:
1. Create IAM role (if needed)
2. Create ECR repository
3. Build Docker image
4. Push image to ECR
5. Create/update Lambda function
6. Create API Gateway

This typically takes 2-5 minutes.

### Step 5: Get Your API Endpoint

After deployment completes, you'll see:
```
API Endpoint: https://abc123def.execute-api.us-east-1.amazonaws.com
```

## Testing Your Deployment

### Test 1: Using curl

```bash
curl -X POST https://abc123def.execute-api.us-east-1.amazonaws.com/predict \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "USR_SITI_001",
    "prediction_date": "2026-04-20",
    "wallet_balance": 560,
    "monthly_income": 2200
  }'
```

### Test 2: Using Python

```python
import requests
import json

url = "https://abc123def.execute-api.us-east-1.amazonaws.com/predict"
payload = {
    "user_id": "USR_SITI_001",
    "prediction_date": "2026-04-20",
    "wallet_balance": 560,
    "monthly_income": 2200
}

response = requests.post(url, json=payload)
print(json.dumps(response.json(), indent=2))
```

### Test 3: Using Postman

1. Open Postman
2. Create new POST request
3. URL: `https://abc123def.execute-api.us-east-1.amazonaws.com/predict`
4. Headers: `Content-Type: application/json`
5. Body (raw JSON):
   ```json
   {
     "user_id": "USR_SITI_001",
     "prediction_date": "2026-04-20",
     "wallet_balance": 560,
     "monthly_income": 2200
   }
   ```
6. Click Send

## Monitoring & Debugging

### View Lambda Logs

```bash
# Real-time logs
aws logs tail /aws/lambda/survivai-prediction --follow

# Last 100 lines
aws logs tail /aws/lambda/survivai-prediction --max-items 100

# Specific time range
aws logs filter-log-events \
  --log-group-name /aws/lambda/survivai-prediction \
  --start-time $(date -d '1 hour ago' +%s)000
```

### Check Lambda Metrics

```bash
# Invocations
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=survivai-prediction \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Errors
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=survivai-prediction \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Duration
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=survivai-prediction \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum
```

### View in AWS Console

1. Go to AWS Console
2. Search for "Lambda"
3. Click on `survivai-prediction` function
4. View logs in "Monitor" tab

## Troubleshooting

### Issue: "Permission Denied" during deployment

**Solution:**
```bash
# Check credentials
aws sts get-caller-identity

# Verify IAM permissions
aws iam get-user
```

### Issue: Docker build fails

**Solution:**
```bash
# Ensure Docker is running
docker ps

# Rebuild without cache
docker build --no-cache -t survivai-model:latest .

# Check Docker logs
docker logs <container_id>
```

### Issue: Lambda timeout

**Solution:**
Edit `deploy.sh` or `deploy.ps1`:
```bash
--timeout 120  # Increase from 60 to 120 seconds
--memory-size 1024  # Increase from 512 to 1024 MB
```

### Issue: "No transaction history found"

**Solution:**
Ensure data files exist in `data/` directory:
```bash
ls -la data/
# Should show:
# - transaction.xlsx
# - mcc_mapping.json
# - mcc_allowlist.json
# - mcc_blocklist.json
```

### Issue: API returns 500 error

**Solution:**
1. Check Lambda logs: `aws logs tail /aws/lambda/survivai-prediction --follow`
2. Look for error messages
3. Common issues:
   - Missing data files
   - Invalid user_id
   - Incorrect date format (should be YYYY-MM-DD)

## Cost Estimation

### Monthly Costs (Typical Usage)

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | 100K requests | $0.02 |
| API Gateway | 100K requests | $0.35 |
| ECR | 1 GB storage | $0.10 |
| CloudWatch Logs | 1 GB logs | $0.50 |
| **Total** | | **~$1.00** |

### Free Tier (First 12 months)

- Lambda: 1M requests/month
- API Gateway: 1M requests/month
- CloudWatch: 5 GB logs/month

## Advanced Configuration

### 1. Add API Key Authentication

```bash
# Create API key
aws apigatewayv2 create-api-key \
  --name survivai-api-key \
  --enabled

# Create usage plan
aws apigatewayv2 create-usage-plan \
  --name survivai-usage-plan \
  --api-stages ApiId=<API_ID>,Stage=default
```

### 2. Enable CORS

```bash
aws apigatewayv2 update-api \
  --api-id <API_ID> \
  --cors-configuration \
    AllowOrigins=https://yourdomain.com \
    AllowMethods=POST \
    AllowHeaders=Content-Type,Authorization
```

### 3. Custom Domain

```bash
# Create certificate in ACM first
aws acm request-certificate \
  --domain-name api.survivai.com

# Then create domain mapping
aws apigatewayv2 create-domain-name \
  --domain-name api.survivai.com \
  --domain-name-configurations CertificateArn=arn:aws:acm:...
```

### 4. Auto-Scaling

Lambda automatically scales, but you can set concurrency limits:

```bash
aws lambda put-function-concurrency \
  --function-name survivai-prediction \
  --reserved-concurrent-executions 100
```

## Cleanup

To remove all resources and stop incurring charges:

```bash
# Delete Lambda function
aws lambda delete-function --function-name survivai-prediction

# Delete API Gateway
aws apigatewayv2 delete-api --api-id <API_ID>

# Delete IAM role
aws iam detach-role-policy \
  --role-name survivai-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name survivai-lambda-role

# Delete ECR repository
aws ecr delete-repository --repository-name survivai-model --force

# Delete CloudWatch log group
aws logs delete-log-group --log-group-name /aws/lambda/survivai-prediction
```

## Next Steps

1. **Add Monitoring**: Set up CloudWatch alarms for errors
2. **Add Caching**: Use ElastiCache for frequently accessed data
3. **Add Database**: Store predictions in DynamoDB
4. **Add Authentication**: Implement OAuth2 or API keys
5. **CI/CD Pipeline**: Automate deployments with GitHub Actions
6. **Load Testing**: Test with Apache JMeter or k6

## Support & Resources

- AWS Lambda Docs: https://docs.aws.amazon.com/lambda/
- API Gateway Docs: https://docs.aws.amazon.com/apigateway/
- AWS CLI Reference: https://docs.aws.amazon.com/cli/
- AWS Support: https://console.aws.amazon.com/support/

## Questions?

For issues or questions:
1. Check CloudWatch logs
2. Review AWS documentation
3. Check AWS Support (if you have a support plan)
