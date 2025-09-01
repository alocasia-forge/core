output "vpc" {
  value = aws_vpc.this
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
  
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


output "keycloak" {
  value = {
    connect = "aws ssm start-session --target ${aws_instance.keycloak.id} --profile alocasia"
    forward = <<EOF
    aws ssm start-session --target ${aws_instance.keycloak.id} --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8080"],"localPortNumber":["8080"]}' --profile alocasia
    EOF
  }
}