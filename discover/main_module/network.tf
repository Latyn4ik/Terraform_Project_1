module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "main-vpc"
  cidr                 = var.private_cidr_blocks
  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  azs                  = ["us-east-1a", "us-east-1b"]
  private_subnets      = var.private_subnet_cidr_blocks
  public_subnets       = var.public_subnet_cidr_blocks
}

resource "aws_security_group" "main" {
  name        = "main_security_group"
  description = "Main security group"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
