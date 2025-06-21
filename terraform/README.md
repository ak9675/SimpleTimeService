# DevOps Team Challenge

This repository contains the solution for the Particle41 DevOps Team Challenge, focusing on application containerization with Docker and infrastructure deployment using Terraform on AWS. This guide provides instructions for both tasks.

**Task 1: SimpleTimeService (Application & Docker)**

This task involves developing a minimalist Python microservice and containerizing it with Docker.

**Project Purpose**

The SimpleTimeService is a web application that returns a JSON response with the current date and time, and the visitor's IP address.

Example Response:

`{
  "timestamp": "2025-06-21T10:30:00.123456Z",
  "ip": "192.168.1.100"
}`

Prerequisites
**Git**: For cloning the repository.

**Docker**: For building and running containers.

**Docker Hub Account**: Required for publishing your Docker image.

**Sign up for Docker Hub**

**Workflow**
Follow these steps from the root of your project directory:

**1. Clone the Repository**:

`git clone https://github.com/ak9675/SimpleTimeService.git`

`cd simple-time-service`


**2. Build the Docker Image:**

`docker build -t simple-time-service .`

**3. Run the Docker Container:**

`docker run -d -p 8080:8080 --name simple-time-service-container simple-time-service`

**4. Test the Application:**

`curl http://localhost:8080`

You should see the JSON output in your terminal.

**5. Publish the Image to Docker Hub (Mandatory for Task 2):**

`docker login`

`docker tag simple-time-service <your-dockerhub-username>/simple-time-service:latest`

`docker push <your-dockerhub-username>/simple-time-service:latest`

Replace <_your-dockerhub-username_> with your actual Docker Hub username.



****Infrastructure Overview****

**The Terraform setup provisions:**

1-A Virtual Private Cloud (VPC) with 2 public and 2 private subnets.

2-An Internet Gateway.

3-An Application Load Balancer (ALB) in public subnets to expose the service.

4-An ECS Cluster.

5-An ECS Fargate task/service to run your container, deployed to private subnets.

6-Appropriate Security Groups and IAM Roles.`**_

**Prerequisites**

*_Terraform CLI_:
*_AWS CLI_:
*AWS Account & Credentials: Configure your AWS CLI with programmatic access (aws configure). Ensure your IAM user has necessary permissions (VPC, EC2, ECS, ALB, IAM, CloudWatch access).

Published Docker Image: Your simple-time-service image from Task 1 must be publicly available on Docker Hub.

****Workflow****

Navigate to the terraform/ directory within this repository:

**1. Update Terraform Variables:**
Open variables.tf and update the docker_image_name variable's default value to your published Docker image name.

**terraform/variables.tf**

`variable "docker_image_name" {`

 ` description = "..."`
 
  `type        = string`
  
  `default     = "your_dockerhub_username/simple-time-service:latest" # <-- UPDATE THIS`
  
`}`

**2. Initialize Terraform:**

`terraform init`

**3. Plan the Deployment:**

`terraform plan`

**4. Apply the Deployment**:

`terraform apply`

Type _yes_ when prompted. This will create the AWS infrastructure.

**5. Destroy the Infrastructure (Cleanup):**
When finished, de-provision all resources to avoid costs.

`terraform destroy`

Type _yes_ when prompted.
