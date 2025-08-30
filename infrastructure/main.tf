locals {
  default_tags = {
    "alocasia:environment" = var.environment
    "alocasia:services"    = "core"
  }
  name_prefix = "alocasia-core-${var.environment}"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${local.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${local.name_prefix}-igw" }
}

resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)
  tags                    = { Name = "${local.name_prefix}-public-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 3)
  availability_zone = element(var.azs, count.index)
  tags              = { Name = "${local.name_prefix}-private-${count.index}" }
}

resource "aws_subnet" "data" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 6)
  availability_zone = element(var.azs, count.index)
  tags              = { Name = "${local.name_prefix}-data-${count.index}" }
}

resource "aws_ecr_repository" "this" {
  name                 = "${local.name_prefix}-repository"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}
