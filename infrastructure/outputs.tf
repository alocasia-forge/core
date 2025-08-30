output "vpc" {
  value = aws_vpc.this
}

output "public_subnets" {
  value = aws_subnet.public[*]
}

output "private_subnets" {
  value = aws_subnet.private[*]
}

output "data_subnets" {
  value = aws_subnet.data[*]
}