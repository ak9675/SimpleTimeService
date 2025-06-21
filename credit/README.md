# Extra Credit Task
# Terraform Remote Backend Configuration

This repository contains the setup for using an AWS S3 bucket for Terraform state storage and an AWS DynamoDB table for state locking. This is important for teamwork and preventing state corruption.

## What It Does

* **S3 Bucket:** Stores your Terraform state file (`.tfstate`). This file tracks all your deployed infrastructure.
* **DynamoDB Table:** Provides a locking mechanism. It ensures only one person (or process) can modify the state at a time, preventing errors.

## Before You Start (Prerequisites)

Make sure these resources already exist in your AWS account before you run Terraform:

* **S3 Bucket:**
    * Must have a **globally unique name**.
    * Enable **Versioning** on the bucket (for history and recovery).
    * Enable **Encryption** (e.g., AES256) for security.
* **DynamoDB Table:**
    * Must have a primary key named `LockID` (case-sensitive, String type).

## How to Configure Your Backend

1.  **Create `backend.tf` File:**
    In your main Terraform project directory, create a file named `backend.tf` and add the following content.

2.  **Update Placeholders:**
    Replace `"your-unique-s3-bucket-name"` and `"your-dynamodb-lock-table-name"` with the actual names of your S3 bucket and DynamoDB table. Also, confirm your `region`.

    ```terraform
    # backend.tf
    terraform {
      backend "s3" {
        bucket         = "your-unique-s3-bucket-name" # <--- YOUR S3 BUCKET NAME
        key            = "my-project/my-env/terraform.tfstate" # <--- YOUR STATE FILE PATH/NAME
        region         = "us-east-1" # <--- YOUR AWS REGION
        dynamodb_table = "your-dynamodb-lock-table-name" # <--- YOUR DYNAMODB TABLE NAME
        encrypt        = true
      }
    }
    ```

## How to Use It

1.  **Initialize Terraform:**
    Navigate to your Terraform project directory in your terminal.
    Run `terraform init`.

    ```bash
    terraform init
    ```
    If you had a local `.tfstate` file, Terraform will ask if you want to migrate it to S3. Type `yes`.

2.  **Continue with Terraform:**
    From now on, all `terraform plan`, `terraform apply`, and `terraform destroy` commands will automatically use this remote backend for state and locking.
