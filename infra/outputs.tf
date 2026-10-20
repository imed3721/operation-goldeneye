output "vpc_id" {
  description = "ID of the GoldenEye VPC"
  value       = aws_vpc.goldeneye.id
}

output "alb_dns_name" {
  description = "Public DNS name of the GoldenEye Application Load Balancer"
  value       = aws_lb.goldeneye.dns_name
}

output "alb_url" {
  description = "HTTP URL of the GoldenEye demonstration endpoint"
  value       = "http://${aws_lb.goldeneye.dns_name}"
}
