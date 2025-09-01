variable "environment" {
  description = "The environment to deploy to"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "alocasia-keypair"
  
}