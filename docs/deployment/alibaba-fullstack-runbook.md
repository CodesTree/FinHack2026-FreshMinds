# Alibaba Fullstack Deployment Runbook

## Backend (Alibaba ECS)

1. Build API image from `backend/services/Dockerfile`.
2. Push image to Alibaba ACR.
3. Deploy container on ECS with port `8000` exposed.
4. Configure environment variables:
   - `ENVIRONMENT=production`
   - `USE_SAGEMAKER=true|false`
   - `AWS_REGION=ap-southeast-1`
   - `SAGEMAKER_ENDPOINT_NAME=<endpoint-name>`
5. Add API route via Alibaba API Gateway (or reverse proxy) to ECS backend.

## Frontend (Alibaba OSS + CDN)

1. Build Flutter web:
   - `flutter build web --dart-define=API_BASE_URL=https://<your-api-domain>/api`
2. Upload `survivai/build/web` assets to OSS bucket.
3. Attach CDN to OSS bucket and enforce HTTPS.
4. Set cache invalidation policy for `index.html` and versioned static assets.

## Cross-Cloud Integration Checks

1. Confirm ECS can egress to AWS SageMaker Runtime endpoint.
2. Hit `/api/survival-score` from deployed frontend and verify JSON.
3. Check Alibaba logging pipeline for request traces.
4. Check AWS CloudWatch/SageMaker metrics for inference traffic when enabled.
