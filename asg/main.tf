data "aws_subnet" "public_subnets" {
  count = 2 # 
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

# Fetches ALB Target Group
data "aws_lb_target_group" "app_targetgroup" {
    name = "application-target-group"  
}

# New EC2 Security Group
resource "aws_security_group" "ec2_security_group" {
    name        = "EC2 Security Group"
    description = "Allow access to EC2 instances"
    vpc_id      = data.aws_vpc.default.id

    ingress {
        from_port   = 80  # Allow HTTP traffic
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow all inbound traffic (adjust as needed)
    }

    ingress {
        from_port   = 22  # Allow SSH access (adjust as needed)
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Allow all inbound traffic (adjust as needed)
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
    }

    tags = {
        Name = "EC2 Security Group"
    }
}


# Launch template for ASG Instances Launched
resource "aws_launch_template" "web_instance_launch" {
    name = "web-instance-launch"
    image_id = "ami-0533f2ba8a1995cf9" # Amazon Linux 2 // Free Tier
    instance_type = "t2.micro"
    key_name      = "MyKeyPair"

    network_interfaces {
      security_groups = [aws_security_group.ec2_security_group.id]
      associate_public_ip_address = true
    }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_instance_asg" {
    launch_template {
      id = aws_launch_template.web_instance_launch.id
      version = "$Latest"
    }

    vpc_zone_identifier = [data.aws_subnet.public_subnets[0].id, data.aws_subnet.public_subnets[1].id]

    min_size = 2
    max_size = 4
    desired_capacity = 2

    target_group_arns = [data.aws_lb_target_group.app_targetgroup.arn]

    tag {
        key = "Name"
        value = "Web Instance ASG"
        propagate_at_launch = true
    }
    
}
