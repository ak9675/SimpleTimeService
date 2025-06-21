# variables.tf

# AWS Region to deploy resources
variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1" 
}

# Project name to tag resources and ensure uniqueness
variable "project_name" {
  description = "A unique prefix for naming resources in this project."
  type        = string
  default     = "particle41-devops-challenge"
}

# CIDR block for the VPC
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# CIDR blocks for public subnets
variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# CIDR blocks for private subnets
variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# Port on which the application runs inside the container
variable "app_port" {
  description = "The port on which the SimpleTimeService application listens."
  type        = number
  default     = 8080
}

# Docker image name for the SimpleTimeService
variable "docker_image_name" {
  description = "Kumar2167-SimpleTimeService-latest-image."
  type        = string
  default     = "kumar2167/simpletimeservice:latest"
}

# CPU units for the Fargate task (1024 units = 1 vCPU)
variable "task_cpu" {
  description = "The number of CPU units (e.g., 256, 512, 1024, 2048, 4096) for the Fargate task."
  type        = number
  default     = 256 # 0.25 vCPU
}

# Memory (in MiB) for the Fargate task
variable "task_memory" {
  description = "The amount of memory (in MiB, e.g., 512, 1024, 2048, 4096, 8192) for the Fargate task."
  type        = number
  default     = 512 # 0.5 GB
}

# Desired number of running tasks for the ECS service
variable "desired_count" {
  description = "The desired number of instances of the SimpleTimeService to run."
  type        = number
  default     = 1
}
