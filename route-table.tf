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