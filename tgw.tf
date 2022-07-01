terraform {
  required_providers {
	aws = {
	  source = "hashicorp/aws"
	  version = "4.20.1"
	}
  }
}

provider "aws" {
  # Configuration options
  region = "eu-west-1"
}

locals {
  region = "eu-west-1"
  #region = var.region
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = "my-tgw"
  description = "My TGW shared with several other AWS accounts"

  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
	vpc = {
	  vpc_id       = module.vpc.vpc_id
	  subnet_ids   = module.vpc.public_subnets
	  dns_support  = true
	  ipv6_support = false

	  tgw_routes = [
		{
		  destination_cidr_block = "30.0.0.0/16"
		},
		{
		  blackhole = true
		  destination_cidr_block = "40.0.0.0/20"
		}
	  ]
	}
  }

  ram_allow_external_principals = true
  #ram_principals = [307990089504]
  ram_principals = ["arn:aws:organizations::482419818288:organization/o-q8mhn3b3j0"]

  tags = {
	Project = "Azure-AWS"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tgw-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.16.0/24", "10.0.17.0/24", "10.0.18.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
	Terraform = "true"
	Environment = "dev"
	Project = "Azure-AWS"
  }
}


# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 3.0"
# 
#   name = "my-vpc"
# 
#   cidr = "10.10.0.0/16"
# 
#   azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
#   private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
# 
#   enable_ipv6                                    = true
#   private_subnet_assign_ipv6_address_on_creation = true
#   private_subnet_ipv6_prefixes                   = [0, 1, 2]
# }