data "aws_subnet" "private_subnets" {
  count = 2 
  filter {
    name   = "tag:Name"
    values = ["Private-Subnet : Private Subnet ${count.index + 1}"]
  }
}

data "aws_vpc" "default" {
    filter {
        name   = "tag:Name"
        values = ["VPC: Web Instance VPC"]
    }
}

# Gets the EC2 Security Group
data "aws_security_group" "ec2_security_group" {
    filter {
        name = "tag:Name"
        values = ["EC2 Security Group"]
    }
}

# RDS Security Group
resource "aws_security_group" "rds_security" {
    name = "rds_security"
    description = "Allow EC2 access to RDS"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 3306 # MySQL Port
        to_port = 3306
        protocol = "tcp"
        security_groups = [data.aws_security_group.ec2_security_group.id]
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

# Subnets to Place RDS Into
resource "aws_db_subnet_group" "rds_subnets_group" {
    name = "rds_subnet_group"
    subnet_ids = data.aws_subnet.private_subnets[*].id
}

# RDS 1
resource "aws_db_instance" "rds_instance_1" {
    identifier = "rds-instance-one" # Basic RDS Setup
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 10
    username = "adminuser"
    password = "user12345" # Dummy User/Pass, not used during Development
    db_name = "rds_1"
    vpc_security_group_ids = [aws_security_group.rds_security.id]
    db_subnet_group_name = aws_db_subnet_group.rds_subnets_group.name
    skip_final_snapshot = true

    tags = {
        Name = "RDS Instance 1"
    }
}

# RDS 2
resource "aws_db_instance" "rds_instance_2" {
    identifier = "rds-instance-two"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 10
    username = "adminuser"
    password = "user12345" # Dummy User/Pass, not used during Development
    db_name = "rds_2"
    vpc_security_group_ids = [aws_security_group.rds_security.id]
    db_subnet_group_name = aws_db_subnet_group.rds_subnets_group.name
    skip_final_snapshot = true

    tags = {
        Name = "RDS Instance 2"
    }
}

