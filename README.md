# Serverless API Platform with Terraform

![Terraform](https://github.com/Aneshailam/serverless-api-terraform/actions/workflows/terraform.yml/badge.svg)

A serverless REST-style API and static website, provisioned entirely as code with Terraform. The same reusable modules deploy two isolated environments, **dev** and **prod**, each with its own remote state.

## Architecture

```
                    Browser
                       |
          +------------+-------------+
          |                          |
     CloudFront (HTTPS)        API Gateway (HTTP API)
          |                          |
   private S3 bucket        +---------+----------+
   (static frontend)        |         |          |
                       create_item get_items delete_item     <- 3 Lambda functions,
                            |         |          |              each with its own IAM role
                            +---------+----------+
                                      |
                                  DynamoDB
```

## Tech stack

| Area | Tools |
|------|-------|
| Infrastructure as code | Terraform (modules, remote state, state locking) |
| API | Amazon API Gateway (HTTP API) |
| Compute | AWS Lambda (Python 3.12) |
| Database | Amazon DynamoDB (on-demand) |
| Frontend hosting | Amazon S3 (private) + CloudFront with Origin Access Control |
| Security | IAM, one least-privilege role per Lambda function |
| CI | GitHub Actions (`terraform validate` for dev and prod) |

## Repository structure

```
bootstrap/        One-time setup: S3 bucket and DynamoDB table for remote state
modules/
  dynamodb/       DynamoDB table
  lambda/         Lambda function + its own IAM role + log group
  api_gateway/    API, routes, integrations, Lambda permissions
  frontend/       Private S3 bucket + CloudFront + uploaded site files
envs/
  dev/            Calls the modules with dev settings, own state file
  prod/           Calls the same modules with prod settings, own state file
lambda/           Python code for the three functions
frontend/         Static website (index.html)
```

## API endpoints

| Method and path | Lambda | What it does |
|-----------------|--------|--------------|
| `POST /items` | create_item | Creates an item (`{"name": "..."}`) |
| `GET /items` | get_items | Lists items |
| `DELETE /items/{id}` | delete_item | Deletes an item |

## Least-privilege IAM

Each function has its own role. It can write only to its own log group and use only the DynamoDB action it needs, on this one table.

| Function | DynamoDB permission |
|----------|--------------------|
| create_item | `PutItem` |
| get_items | `Scan` |
| delete_item | `DeleteItem` |

## Dev vs prod

Both use the same modules. Only the values in `terraform.tfvars` differ.

| Setting | dev | prod |
|---------|-----|------|
| Lambda memory | 128 MB | 256 MB |
| Log retention | 7 days | 30 days |
| DynamoDB point-in-time recovery | off | on |
| CloudFront price class | PriceClass_100 | PriceClass_All |
| API throttling (rate / burst) | 5 / 10 | 50 / 100 |
| Delete frontend bucket on destroy | yes | no |

## Prerequisites

- An AWS account and the AWS CLI configured (`aws configure`)
- Terraform 1.5 or newer

## Deploy

**1. Create the remote state backend (once)**

```bash
cd bootstrap
terraform init
terraform apply -var="state_bucket_name=YOUR-UNIQUE-STATE-BUCKET"
```

**2. Point each environment at it**

Edit `envs/dev/backend.tf` and `envs/prod/backend.tf`: replace `YOUR_STATE_BUCKET` with the bucket name and `YOUR_LOCK_TABLE` with `terraform-state-locks`.

**3. Deploy dev**

```bash
cd envs/dev
terraform init
terraform plan
terraform apply
```

**4. Test it**

```bash
API=$(terraform output -raw api_url)

curl -X POST "$API/items" -H "Content-Type: application/json" -d '{"name":"first item"}'
curl "$API/items"
curl -X DELETE "$API/items/<id-from-the-list>"
```

Open the `website_url` output in a browser to use the frontend.

**5. Deploy prod**

```bash
cd ../prod
terraform init
terraform apply
```

## Notes

- If you change `frontend/index.html` and re-apply, CloudFront may keep serving the old file for a while. Create an invalidation to refresh it:
  `aws cloudfront create-invalidation --distribution-id <id> --paths "/*"`
- CORS is open (`*`) so the frontend can call the API. For a real product, restrict it to your CloudFront domain.
- The API has no authentication. Add a JWT authorizer or Cognito before using it with real data.

## Screenshots

Add your own screenshots to a `docs/` folder and show them here, for example:

- `terraform apply` output for dev
- The deployed website
- API Gateway routes and the Lambda functions in the AWS console
- The S3 state bucket showing separate state files for dev and prod

## Cleanup

Destroy prod first if you deployed it, then dev, then the bootstrap resources:

```bash
cd envs/prod && terraform destroy
cd ../dev && terraform destroy
```

The state bucket in `bootstrap/` is versioned, so empty it (including old versions) before destroying it.

## Possible improvements

- Add authentication to the API (Cognito or a JWT authorizer). Right now the API is open.
- Restrict CORS to the CloudFront domain instead of `*`.
- Deploy automatically with GitHub Actions: plan on pull requests, apply on merge.
- Add a custom domain with Route 53 and an ACM certificate.
- Add API Gateway access logs and CloudWatch alarms for Lambda errors.
