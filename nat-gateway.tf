# Configure Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
    count = length(var.private_subnet_cidr)
    domain = "vpc"
}

# Configure a NAT Gateway for each Private Subnet
resource "aws_nat_gateway" "nat_gateway" {
    count = length(var.private_subnet_cidr)
    depends_on = [aws_eip.nat_eip] # Ensures NAT Gateways are only created with Elastic IP Attached
    allocation_id = aws_eip.nat_eip[count.index].id # Associates NAT Gateway with Elastic IP
    subnet_id = aws_subnet.aws_gabe_private_subnets[count.index].id # Places the NAT Gateway on Each Subnet
    tags = {
        Name = "Private NAT Gateway for VPC Project : ${count.index + 1}"
    }
}