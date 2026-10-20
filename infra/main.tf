data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Mission     = "GoldenEye"
  }
}

# Virtual Private Cloud
resource "aws_vpc" "goldeneye" {
  cidr_block           = "10.70.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name  = "goldeneye-vpc"
    Owner = "GoldenEye"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "goldeneye" {
  vpc_id = aws_vpc.goldeneye.id

  tags = merge(local.common_tags, {
    Name = "goldeneye-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id = aws_vpc.goldeneye.id

  cidr_block = cidrsubnet(
    aws_vpc.goldeneye.cidr_block,
    8,
    count.index + 1
  )

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "goldeneye-public-${count.index + 1}"
    Tier = "public"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.goldeneye.id

  tags = merge(local.common_tags, {
    Name = "goldeneye-public-rt"
  })
}

# Default Route to the Internet
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.goldeneye.id
}

# Associate Public Subnets with the Route Table
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "goldeneye-alb-sg"
  description = "Allow HTTP access to the demonstration ALB"
  vpc_id      = aws_vpc.goldeneye.id

  ingress {
    description = "HTTP demonstration access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "goldeneye-alb-sg"
  })
}

# Application Load Balancer
resource "aws_lb" "goldeneye" {
  name               = "goldeneye-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = merge(local.common_tags, {
    Name  = "goldeneye-alb"
    Owner = "GoldenEye"
  })
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.goldeneye.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "MI6 GOLDENEYE: Mission control is operational."
      status_code  = "200"
    }
  }

  tags = local.common_tags
}
