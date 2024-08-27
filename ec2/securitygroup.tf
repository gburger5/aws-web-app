data "aws_vpc" "default" {
    filter {
        name   = "tag:Name"
        values = ["VPC: gabe-us-east-1"]
    }
} # Takes in VPC to set group


resource "aws_security_group" "ec2_security" {
    name = "ec2_security"
    description = "Allow SSH, HTTP, HTTPS inbound traffic"
    vpc_id = data.aws_vpc.default.id

    # Inbound Rules
    ingress{
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

     ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Outbound Rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ec2_security"
    }
}