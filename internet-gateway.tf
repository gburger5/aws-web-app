# Internet Gateway Setup
resource "aws_internet_gateway" "public_internet_gateway" {
    vpc_id = aws_vpc.vpc-gabe-us-east-1.id
    tags = {
        Name = "Internet Gateway for VPC Project"
    }
}