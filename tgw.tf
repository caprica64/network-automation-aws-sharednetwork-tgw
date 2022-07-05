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
  name   = "Shared-TGW"
  region = "eu-west-1"
  #region = var.region
}

module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 2.0"

  name        = local.name
  description = "TGW shared with several other AWS accounts"

  enable_auto_accept_shared_attachments = true
  
  amazon_side_asn = 64512

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
  #ram_principals = [307990089504] << Kept as an example
  ram_principals = ["arn:aws:organizations::482419818288:organization/o-q8mhn3b3j0"]

  tags = {
	Project = "Azure-AWS"
  }
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "hub-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.16.0/24", "10.0.17.0/24", "10.0.18.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = false

  customer_gateways = {
	  IP1 = {
		bgp_asn     = 65112
		ip_address  = "1.2.3.4"
		device_name = "some_name"
	  },
	  IP2 = {
		bgp_asn    = 65112
		ip_address = "5.6.7.8"
	  }
	}

  manage_default_network_acl = true
	  default_network_acl_tags   = { Name = "${local.name}-default" }
	  
	  manage_default_route_table = true
	  default_route_table_tags   = { Name = "${local.name}-default" }
	  
	  manage_default_security_group = true
	  default_security_group_tags   = { Name = "${local.name}-default" }

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
	Terraform = "true"
	Environment = "dev"
	Project = "Azure-AWS"
  }
}

################################################################################
# Security Groups
################################################################################
#
## Test
#
resource "aws_security_group" "allow_testing_connectivity" {
  name        = "Allow_ec2_tests"
  description = "Allow EC2 instances to test connectivity"
  vpc_id      = module.vpc.vpc_id
  
  tags = {
	  Name        = "Test-SG"
	  Role        = "public"
	  Project     = "Azure-AWS"
	  Environment = "Dev"
	  ManagedBy   = "terraform"
	}
}

resource "aws_security_group_rule" "ssh_in" {
  type               = "ingress"
  from_port          = 22
  to_port            = 22
  protocol           = "tcp"
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = aws_security_group.allow_testing_connectivity.id
  #name               = "SSH inbound"
  description        = "Allow inbound SSH access the EC2 instances"
}

resource "aws_security_group_rule" "icmp_in" {
  type               = "ingress"
  from_port          = 0
  to_port            = 0
  protocol           = "1"
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = aws_security_group.allow_testing_connectivity.id
  #name               = "ICMP inbound"
  description        = "Allow inbound ICMP to the EC2 instances"
}

resource "aws_security_group_rule" "all_out" {
  type               = "egress"
  from_port          = 0
  to_port            = 0
  protocol           = "-1"
  cidr_blocks        = ["0.0.0.0/0"]
  security_group_id  = aws_security_group.allow_testing_connectivity.id
}
