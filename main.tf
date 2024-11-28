# VPC Configuration
resource "aws_vpc" "web_instance_vpc" {
    cidr_block = var.vpc_cidr
    
    tags = {
        Name = "VPC: Web Instance VPC"
    }
}

# Public Subnet Setup
resource "aws_subnet" "public_subnets" {
    count = length(var.public_subnet_cidr) # Number of subnets to be created
    vpc_id = aws_vpc.web_instance_vpc.id
    cidr_block = element(var.public_subnet_cidr, count.index)
    availability_zone = element(var.us_availability_zone, count.index)
    map_public_ip_on_launch = true
    
    tags = {
        Name = "Public-Subnet : Public Subnet ${count.index + 1}"
    }
}

# Private Subnet Setup for DBs
resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnet_cidr) 
    vpc_id = aws_vpc.web_instance_vpc.id
    cidr_block = element(var.private_subnet_cidr, count.index)
    availability_zone = element(var.us_availability_zone, count.index)
    
    tags = {
        Name = "Private-Subnet : Private Subnet ${count.index + 1}"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "public_internet_gateway" {
    vpc_id = aws_vpc.web_instance_vpc.id
    
    tags = {
        Name = "Web Instance Internet Gateway"
    }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.web_instance_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.public_internet_gateway.id
    }
    
    tags = {
        Name = "Route Table Public"
    }
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.web_instance_vpc.id
    
    tags = {
        Name = "Route Table Private"
    }
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_association" {
    count = length(var.public_subnet_cidr)
    subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
    count = length(var.private_subnet_cidr)
    subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
    route_table_id = aws_route_table.private_route_table.id
}

# Application Load Balancer Security Group
resource "aws_security_group" "alb_security" {
    name = "alb_security"
    description = "Allow HTTP/HTTPS Traffic Inbound"
    vpc_id = aws_vpc.web_instance_vpc.id

    ingress {
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

# EC2 Security Group
resource "aws_security_group" "ec2_security_group" {
    name        = "EC2 Security Group"
    description = "Allow access to EC2 instances"
    vpc_id      = aws_vpc.web_instance_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_security.id]  # Only allow traffic from ALB
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]  # Restrict for Prod
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "EC2 Security Group"
    }
}

# RDS Security Group
resource "aws_security_group" "rds_security" {
    name = "rds_security"
    description = "Allow EC2 access to RDS"
    vpc_id = aws_vpc.web_instance_vpc.id

    ingress {
        from_port = 3306 # MySQL Port
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.ec2_security_group.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"] # Allow all outbound
    }

    tags = {
        Name = "RDS Security Group"
    }
}

# Application Load Balancer
resource "aws_lb" "app_load_balancer" {
    name = "application-load-balancer"
    internal = false # Public Load Balancer
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_security.id]
    subnets = aws_subnet.public_subnets[*].id
    enable_deletion_protection = false
}

# Load Balancer Target Group
resource "aws_lb_target_group" "app_targetgroup" {
    name = "application-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.web_instance_vpc.id

    health_check {
        path = "/"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
        matcher = "200"
    }
}

# Load Balancer Listener, Listens for Port 80 Traffic from IGW (Internet Gateway)
resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.app_load_balancer.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.app_targetgroup.arn
    }
}

# Launch Template
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

    vpc_zone_identifier = aws_subnet.public_subnets[*].id
    target_group_arns = [aws_lb_target_group.app_targetgroup.arn]

    min_size = 2
    max_size = 4
    desired_capacity = 2

    tag {
        key = "Name"
        value = "Web Instance ASG"
        propagate_at_launch = true
    }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnets_group" {
    name = "rds_subnet_group"
    subnet_ids = aws_subnet.private_subnets[*].id  
}

# RDS Instances
resource "aws_db_instance" "rds_instance_1" {
    identifier = "rds-instance-one"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 10
    username = "adminuser"
    password = "user12345"
    db_name = "rds_1"
    vpc_security_group_ids = [aws_security_group.rds_security.id]
    db_subnet_group_name = aws_db_subnet_group.rds_subnets_group.name
    skip_final_snapshot = true
    multi_az = false  

    tags = {
        Name = "RDS Instance 1"
    }
}

resource "aws_db_instance" "rds_instance_2" {
    identifier = "rds-instance-two"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 10
    username = "adminuser"
    password = "user12345"
    db_name = "rds_2"
    vpc_security_group_ids = [aws_security_group.rds_security.id]
    db_subnet_group_name = aws_db_subnet_group.rds_subnets_group.name
    skip_final_snapshot = true
    multi_az = false  

    tags = {
        Name = "RDS Instance 2"
    }
}