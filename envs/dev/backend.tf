# Remote state in S3 with DynamoDB locking.
# Create the bucket and table first (see bootstrap/), then put their names here.
terraform {
  backend "s3" {
    bucket         = "YOUR_STATE_BUCKET"
    key            = "serverless-api/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "YOUR_LOCK_TABLE"
    encrypt        = true
  }
}
