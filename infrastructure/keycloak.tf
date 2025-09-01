resource "aws_instance" "keycloak" {
  ami                         = "ami-09b024e886d7bbe74"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.keycloak.id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  iam_instance_profile        = "ssm-ec2-role"
  tags = { Name = "${local.name_prefix}-keycloak" }
}

resource "aws_security_group" "keycloak" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for Keycloak server"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ module.alb.security_group_id ]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_route53_zone" "this" {
  name         = "matih.eu"
  private_zone = false
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = module.alb.target_groups["tg"].arn
  target_id        = aws_instance.keycloak.id
  port             = 80
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name = "sso.matih.eu"
  zone_id     = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.sso.matih.eu"
  ]

  wait_for_validation = true

  tags = {
    Name = "sso.matih.eu"
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name                       = "${local.name_prefix}-alb"
  vpc_id                     = aws_vpc.this.id
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = false

  route53_records = {
    gitlab = {
      zone_id                   = data.aws_route53_zone.this.zone_id
      name                      = "sso.matih.eu"
      type                      = "A"
      subject_alternative_names = ["*.sso.matih.eu"]
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.zone_id
        evaluate_target_health = true
      }
    }
  }

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn

      forward = {
        target_group_key = "tg"
      }
    }
  }

  target_groups = {
    tg = {
      name_prefix       = "sso"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/realms/master"
        matcher             = "200"
        port                = "80"
        protocol            = "HTTP"
      }
    }
  }
}
