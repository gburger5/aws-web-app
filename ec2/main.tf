provider "aws" {
    region = "us-east-1"
}


data "aws_subnet" "public_subnet1" { # Takes in Subnet Data to place EC2
    filter {
        name = "tag:Name"
        values = ["Public-Subnet : Public Subnet 1"]
    }
}

data "aws_subnet" "public_subnet2" {
    filter {
        name = "tag:Name"
        values = ["Public-Subnet : Public Subnet 2"]
    }
}

# Deploys 2 EC2 Instances 1 in each Subnet
resource "aws_instance" "web_instance_1" {
    ami           = "ami-0533f2ba8a1995cf9" # Amazon Linux 2 // Free Tier
    instance_type = "t2.micro"
    key_name      = "MyKeyPair"
    subnet_id = data.aws_subnet.public_subnet1.id
    vpc_security_group_ids = [aws_security_group.ec2_security.id]
}

resource "aws_instance" "web_instance_2" {
    ami           = "ami-0533f2ba8a1995cf9"
    instance_type = "t2.micro"
    key_name      = "MyKeyPair"
    subnet_id = data.aws_subnet.public_subnet2.id
    vpc_security_group_ids = [aws_security_group.ec2_security.id]
}