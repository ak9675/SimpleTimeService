# DevOps Team Challenge
This repository contains the solution for the Particle41 DevOps Team Challenge, focusing on application containerization with Docker and infrastructure deployment using Terraform on AWS. This guide provides instructions for both tasks.

# Task 1: SimpleTimeService (Application & Docker)
This task involves developing a minimalist Python microservice and containerizing it with Docker.

**Project Purpose**
The SimpleTimeService is a web application that returns a JSON response with the current date and time, and the visitor's IP address.

Example Response:

`{
  "timestamp": "2025-06-21T10:30:00.123456Z",
  "ip": "192.168.1.100"
}`

**Prerequisites**

-_Git_: For cloning the repository
Installation Guide git docs https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

-_Docker_: For building and running containers.
Installation Guide for Docker Docs https://docs.docker.com/get-docker/

-_Docker Hub Account_: Required for publishing your Docker image.
Sign up for Docker Hub at https://hub.docker.com/signup

**Workflow**
Follow these steps from the root of your project directory:

**1. Clone the Repository:**

`git clone https://github.com/ak9675/SimpleTimeService.git`

`cd SimpleTimeService`

**2. Build the Docker Image:**

`docker build -t simple-time-service .`

**3. Run the Docker Container:**

`docker run -d -p 8080:8080 --name simple-time-service-container simpletimeservice`

**4. Test the Application:**

`curl http://localhost:8080`

_You should see the JSON output in your terminal._

**5. Publish the Image to Docker Hub (Mandatory for Task 2):**

`docker login`

`docker tag simple-time-service <your-dockerhub-username>/simple-time-service:latest`
**For this task image is published at _kumar2167/simpletimeservice_ public docker hub repository.**

`docker push <your-dockerhub-username>/simple-time-service:latest`

Replace <your-dockerhub-username> with your actual Docker Hub username.


# Task 2: Infrastructure with Terraform (AWS ECS Fargate)

This task involves deploying the SimpleTimeService to AWS using Terraform to provision the necessary cloud infrastructure.

**Infrastructure Overview**

The Terraform setup provisions:

1-A Virtual Private Cloud (VPC) with 2 public and 2 private subnets.

2-An Internet Gateway.

3-An Application Load Balancer (ALB) in public subnets to expose the service.

4-An ECS Cluster.

5-An ECS Fargate task/service to run your container, deployed to private subnets.

6-Appropriate Security Groups and IAM Roles.

**Prerequisites**

Terraform CLI:
Installation Guide (HashiCorp) at https://developer.hashicorp.com/terraform/downloads

AWS CLI:
Installation Guide (AWS Docs) at https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

AWS Account & Credentials: Configure your AWS CLI with programmatic access (aws configure). Ensure your IAM user has necessary permissions (VPC, EC2, ECS, ALB, IAM, CloudWatch access).

Published Docker Image: Your simple-time-service image from Task 1 must be publicly available on Docker Hub.

**Workflow**

Navigate to the terraform/ directory within this repository:

**1. Update Terraform Variables:**

Open _variables.tf_ and update the docker_image_name variable's default value to your published Docker image name.

**terraform/variables.tf**

`variable "docker_image_name" {`

  `description = "..."`
  
 ` type        = string`
 
 ` default     = "your_dockerhub_username/simple-time-service:latest" # <-- UPDATE THIS`
 
`}`

**2. Initialize Terraform:**

`terraform init`

**3. Plan the Deployment:**

`terraform plan`

**4. Apply the Deployment:**

`terraform apply`

Type _yes_ when prompted. This will create the AWS infrastructure.

**5. Destroy the Infrastructure (Cleanup optional):**

When finished, de-provision all resources to avoid costs.

`terraform destroy`

Type _yes_ when prompted.

# Credit Task

A README.md file present at credit/README.md guides through the process of using remote .tfstate files along with using dynamodb table.

**Code Quality and Best Practices**

**Application (Task 1)**

*Small Image Size: Uses a slim base image and efficient pip installation.
*Non-Root User: Application runs as a non-privileged user inside the container.
*Production-Ready Server: Utilizes Gunicorn for robust serving.

**Infrastructure (Task 2**)

*Modular Design: Organized Terraform files (main.tf, variables.tf, outputs.tf).
*Resource Tagging: All AWS resources are properly tagged.
*Security: Uses specific Security Groups and IAM Roles following the principle of least privilege.
*Serverless: Leverages AWS Fargate for managed container compute.
*Networking: Employs public/private subnets for secure network segregation.
