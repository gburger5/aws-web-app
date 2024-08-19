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