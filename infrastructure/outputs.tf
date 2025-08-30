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

output "ecr_repository" {
  value = aws_ecr_repository.this
}
