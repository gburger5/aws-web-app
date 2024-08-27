# Create AWS VPC in us-east-1
# CIDR 10.0.0.0/16

resource "aws_vpc" "vpc-gabe-us-east-1" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "VPC: gabe-us-east-1"
    }
}

# Public Subnet Setup

resource "aws_subnet" "aws_gabe_public_subnets" {
    count = length(var.public_subnet_cidr) # Number of subnets to be created
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id # Reference to VPC
    cidr_block = element(var.public_subnet_cidr, count.index) # Iterates over public_subnet_cidr list based on Count Index
    availability_zone = element(var.us_availability_zone, count.index)
    map_public_ip_on_launch = true # For SSH into EC2
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

# Internet Gateway 

resource "aws_internet_gateway" "public_internet_gateway" {
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id
    tags = {
        Name = "Internet Gateway for VPC Project"
    }
}

# Configure Elastic IP for NAT Gateway

resource "aws_eip" "nat_eip" {
    count = length(var.private_subnet_cidr)
    domain = "vpc"
}

# # Configure a NAT Gateway for each Private Subnet

resource "aws_nat_gateway" "nat_gateway" {
    count = length(var.private_subnet_cidr)
    depends_on = [aws_eip.nat_eip] # Ensures NAT Gateways are only created with Elastic IP Attached
    allocation_id = aws_eip.nat_eip[count.index].id # Associates NAT Gateway with Elastic IP
    subnet_id = aws_subnet.aws_gabe_private_subnets[count.index].id # Places the NAT Gateway on Each Subnet
    tags = {
        Name = "Private NAT Gateway for VPC Project : ${count.index + 1}"
    }
}

# Using Internet Gateway for Public Routing

resource "aws_route_table" "gabe_public_route_table" {
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id

    route { 
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.public_internet_gateway.id
    }
    
    tags = {
        Name = "Route Table Public : For VPC Project"
    }
}

# Using NAT Gateway for Private Routing

resource "aws_route_table" "gabe_private_route_table" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id
    depends_on = [aws_nat_gateway.nat_gateway]

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
    }

    tags = {
        Name = "Route Table Private : For VPC Project"
    }
}

# Public Route Table Association

resource "aws_route_table_association" "public_subnet_association" {
    count = length(var.public_subnet_cidr)
    depends_on = [aws_subnet.aws_gabe_public_subnets, aws_route_table.gabe_public_route_table]
    subnet_id = element(aws_subnet.aws_gabe_public_subnets[*].id, count.index)
    route_table_id = aws_route_table.gabe_public_route_table.id
}

# Private Route Table Association

resource "aws_route_table_association" "private_subnet_association" {
    count = length(var.private_subnet_cidr)
    depends_on = [aws_subnet.aws_gabe_private_subnets, aws_route_table.gabe_private_route_table]
    subnet_id = element(aws_subnet.aws_gabe_private_subnets[*].id, count.index)
    route_table_id = aws_route_table.gabe_private_route_table[count.index].id
}


