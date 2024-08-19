# Create AWS VPC in us-east-1
# CIDR 10.0.0.0/16

resource "aws_vpc" "vpc-gabe-us-east-1" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "VPC: gabe-us-east-1"
    }
}