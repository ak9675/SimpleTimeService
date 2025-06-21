terraform {
  backend "s3" {
    # This unique bucket must exist before 'terraform init'.
    bucket = "my-terraform-state-bucket-unique-name-12345"

    # The path within the S3 bucket with the "filename" for your state file.
    key    = "devops-challenge/ecs-fargate/terraform.tfstate"

    # The AWS region where S3 bucket and DynamoDB table are located.
    region = "us-east-1" 

    # The DynamoDB table used for state locking  must exist before 'terraform init' and must have a
    # primary key named 'LockID' (case-sensitive, String type).
    dynamodb_table = "my-terraform-locks"
    
    # Recommended for server-side encryption for the state file in S3 security.
    encrypt = true
  }
}

