# main.tf

# Configure the AWS provider
# Specifies the region where resources will be deployed.
provider "aws" {
  region = var.aws_region
}

# --- Networking (VPC) Setup ---

# Create a new VPC
# This provides an isolated network environment for our resources.
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = "devops-challenge"
  }
}

# Create public subnets
# These subnets will host resources that need direct internet access, like the Application Load Balancer.
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Instances launched here will get a public IP

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = "devops-challenge"
  }
}

# Create private subnets
# These subnets will host resources that should not have direct internet access, like ECS Fargate tasks.
# Traffic to the internet will go through a NAT Gateway (not included for simplicity but crucial for production).
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-private-subnet-${count.index + 1}"
    Environment = "devops-challenge"
  }
}

# Create an Internet Gateway
# This enables communication between the VPC and the internet.
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a route table for public subnets
# This route table directs internet-bound traffic through the Internet Gateway.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # All traffic
    gateway_id = aws_internet_gateway.app_igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Get availability zones for the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

# --- Security Groups ---

# Security group for the Application Load Balancer
# Allows inbound HTTP (port 80) and HTTPS (port 443) traffic from anywhere.
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS access to ALB"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic for the ALB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Security group for ECS Fargate tasks
# Allows inbound traffic from the ALB on the application's port (8080).
# Allows all outbound traffic (e.g., to pull Docker images, send logs to CloudWatch).
resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.project_name}-ecs-task-sg"
  description = "Allow inbound from ALB and all outbound for ECS tasks"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only allow traffic from ALB
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-task-sg"
  }
}

# --- ECS Cluster and Task Definition ---

# Create an ECS Cluster
# This is a logical grouping for your ECS services and tasks.
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# IAM Role for ECS Task Execution
# Fargate tasks need this role to pull Docker images, write logs to CloudWatch, etc.
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.project_name}-ecs-execution-role"
  }
}

# Attach policy to the execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition for the SimpleTimeService
# Defines the Docker image to use, CPU/memory, port mappings, and logging.
resource "aws_ecs_task_definition" "simple_time_service_task" {
  family                   = "${var.project_name}-simple-time-service"
  requires_compatibilities = ["FARGATE"] # Use Fargate launch type
  network_mode             = "awsvpc"    # Required for Fargate
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name        = "simple-time-service-container",
      image       = var.docker_image_name, # Image pushed in Task 1
      cpu         = var.task_cpu,
      memory      = var.task_memory,
      essential   = true,
      portMappings = [
        {
          containerPort = var.app_port,
          hostPort      = var.app_port,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/simple-time-service",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-simple-time-service-task"
  }
}

# Create CloudWatch Log Group for ECS task logs
resource "aws_cloudwatch_log_group" "simple_time_service_log_group" {
  name = "/ecs/simple-time-service"
  retention_in_days = 7 # Retain logs for 7 days

  tags = {
    Name = "${var.project_name}-ecs-log-group"
  }
}

# --- Application Load Balancer (ALB) ---

# Create an Application Load Balancer
# This will distribute incoming traffic to your ECS tasks.
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  internal           = false # Publicly accessible ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public_subnets : s.id] # ALB lives in public subnets

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Create a Target Group for the ALB
# This group registers your ECS tasks and sends traffic to them.
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/" # Health check endpoint for the application
    protocol            = "HTTP"
    matcher             = "200" # Expect HTTP 200 OK
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Create an ALB Listener for HTTP traffic
# Directs traffic from port 80 on the ALB to the target group.
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name = "${var.project_name}-http-listener"
  }
}

# --- ECS Service ---

# Create an ECS Service
# This maintains the desired number of tasks, performs rolling updates, and integrates with the ALB.
resource "aws_ecs_service" "simple_time_service_ecs_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.simple_time_service_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [for s in aws_subnet.private_subnets : s.id] # Tasks live in private subnets
    security_groups = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = false # Tasks do not get public IPs directly
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "simple-time-service-container" # Name of container in task definition
    container_port   = var.app_port
  }

  # Wait for ALB to be stable before marking service as healthy
  depends_on = [
    aws_lb_listener.http_listener,
  ]

  tags = {
    Name = "${var.project_name}-service"
  }
}
