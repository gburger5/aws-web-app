data "aws_subnet" "public_subnets" {
  count = 2
  filter {
    name   = "tag:Name"
    values = ["Public-Subnet : Public Subnet ${count.index + 1}"]
  }
}

data "aws_vpc" "default" {
    filter {
        name   = "tag:Name"
        values = ["VPC: Web Instance VPC"]
    }
}


# ALB Security Group, Allows all outbound and HTTP Inbound
resource "aws_security_group" "alb_security" { 
    name = "alb_security"
    description = "Allow HTTP/HTTPS Traffic Inbound" 
    vpc_id = data.aws_vpc.default.id

    ingress { # Only allowed HTTP since this is architecture, would prefer HTTPS
        description = "HTTP Inbound"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Sets Up Load Balancer
resource "aws_lb" "app_load_balancer" {
    name = "application-load-balancer"
    internal = false # Public Load Balancer
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_security.id]
    subnets = [data.aws_subnet.public_subnets[0].id, data.aws_subnet.public_subnets[1].id]
    enable_deletion_protection = false
}

# Load Balancer Target Group
resource "aws_lb_target_group" "app_targetgroup" {
    name = "application-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
      path = "/" # Endpoint
      interval = 30 # Time between Checks
      timeout = 5 # Time to wait for response
      healthy_threshold = 2 # 2 Checks before considered healthy
      unhealthy_threshold = 2
      matcher = "200" # Healthy HTTP Code
    }

}

# Listens for Port 80 Traffic from IGW (Internet Gateway)

resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.app_load_balancer.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app_targetgroup.arn # Target group to forward traffic to
    }
}

