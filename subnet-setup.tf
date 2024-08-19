# Public Subnet Setup

resource "aws_subnet" "aws_gabe_public_subnets" {
    count = length(var.public_subnet_cidr) # Number of subnets to be created
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id # Reference to VPC
    cidr_block = element(var.public_subnet_cidr, count.index) # Iterates over public_subnet_cidr list based on Count Index
    availability_zone = element(var.us_availability_zone, count.index)

    tags = {
        Name = "Public-Subnet : Public Subnet ${count.index + 1}"
    }
}

# Private Subnet Setup
# Setup is the same as Public just using Different Variables

resource "aws_subnet" "aws_gabe_private_subnets" {
    count = length(var.private_subnet_cidr) 
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id 
    cidr_block = element(var.private_subnet_cidr, count.index) 
    availability_zone = element(var.us_availability_zone, count.index)

    tags = {
        Name = "Private-Subnet : Private Subnet ${count.index + 1}"
    }
}