# outputs.tf

# Output the DNS name of the Application Load Balancer
# This is the public URL where your application will be accessible.
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer for SimpleTimeService."
  value       = aws_lb.app_alb.dns_name
}

# Output the name of the ECS Cluster
output "ecs_cluster_name" {
  description = "The name of the ECS Cluster."
  value       = aws_ecs_cluster.app_cluster.name
}

# Output the URL of the deployed application
output "simple_time_service_url" {
  description = "The URL where the SimpleTimeService can be accessed."
  value       = "http://${aws_lb.app_alb.dns_name}"
}
