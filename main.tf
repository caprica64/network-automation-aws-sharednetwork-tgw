### Transit infrastructure

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_organizations_organization" "org" {}

locals {
  name   = "Hub"
  region = var.region
}

################################################################################
# VPC section
################################################################################

#
## Main VPC
#
resource "aws_vpc" "transit" {
  cidr_block            = var.cidr_block
  instance_tenancy      = "default"
  
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
	#Name                = var.vpc_name
	Name                = "TransitVPC"
	Project             = "Azure-AWS"
	CostCenter          = "AoD"
  }
}

#
## Subnets
#
resource "aws_subnet" "PublicSubnet1a" {
  cidr_block = var.public_subnet_1a_cidr
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.transit.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
	Name = "Public Subnet AZ 1a"
  }
}

resource "aws_subnet" "PublicSubnet1c" {
  cidr_block = var.public_subnet_1c_cidr
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.transit.id
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
	Name = "Public Subnet AZ 1c"
  }
}

resource "aws_subnet" "PrivateSubnet1a" {
  cidr_block = var.private_subnet_1a_cidr
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.transit.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
	Name = "Private Subnet AZ 1a"
  }
}

resource "aws_subnet" "PrivateSubnet1c" {
  cidr_block = var.private_subnet_1c_cidr
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.transit.id
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
	Name = "Private Subnet AZ 1c"
  }
}
#
## Route tables - Public
#
resource "aws_route_table" "RouteTablePublic" {
  vpc_id = aws_vpc.transit.id
  depends_on = [ aws_internet_gateway.Igw ]

  tags = {
	Name = "Public Route Table"
  }

  # Internet
  route {
	cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.Igw.id
  }

  # Spoke 1
  route {
	cidr_block = var.spoke1_cidr
	transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
}

#
## Route tables associations - Public
#
resource "aws_route_table_association" "AssociationForRouteTablePublic1a" {
  subnet_id = aws_subnet.PublicSubnet1a.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

resource "aws_route_table_association" "AssociationForRouteTablePubli1c" {
  subnet_id = aws_subnet.PublicSubnet1c.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

#
## Route tables - Private
#
resource "aws_route_table" "RouteTablePrivate1a" {
  vpc_id = aws_vpc.transit.id
  depends_on = [ aws_nat_gateway.NatGw1a ]

  tags = {
	Name = "Private Route Table 1a"
  }

  # Internet
  route {
	cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.NatGw1a.id
  }
  
  # Spoke 1
  route {
  cidr_block = var.spoke1_cidr
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
}

resource "aws_route_table" "RouteTablePrivate1c" {
  vpc_id = aws_vpc.transit.id
  depends_on = [ aws_nat_gateway.NatGw1c ]

  tags = {
  Name = "Private Route Table 1c"
  }

  # Internet
  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NatGw1c.id
  }
  
  # Spoke 1
  route {
  cidr_block = var.spoke1_cidr
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
}

#
## Route tables associations - Private
#
resource "aws_route_table_association" "AssociationForRouteTablePrivate1a" {
  subnet_id = aws_subnet.PrivateSubnet1a.id
  route_table_id = aws_route_table.RouteTablePrivate1a.id
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate1c" {
  subnet_id = aws_subnet.PrivateSubnet1c.id
  route_table_id = aws_route_table.RouteTablePrivate1c.id
}

#
## Internet Gateway
#
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.transit.id
}
#
## Elastic IP and NAT Gateway for 1a
#
resource "aws_eip" "EipForNatGw1a" {
}

resource "aws_nat_gateway" "NatGw1a" {
  allocation_id = aws_eip.EipForNatGw1a.id
  subnet_id = aws_subnet.PublicSubnet1a.id

  tags = {
	Name = "NAT GW 1a"
	CostCenter          = "AoD"
  }
}

#
## Elastic IP and NAT Gateway for 1c
#
resource "aws_eip" "EipForNatGw1c" {
}

resource "aws_nat_gateway" "NatGw1c" {
  allocation_id = aws_eip.EipForNatGw1c.id
  subnet_id = aws_subnet.PublicSubnet1c.id

  tags = {
	Name = "NAT GW 1c"
	CostCenter          = "AoD"
  }
}

################################################################################
# Transit Gateway
################################################################################
resource "aws_ec2_transit_gateway" "tgw" {
  description = "Hub Transit Gateway"
  
  amazon_side_asn = 64512
  auto_accept_shared_attachments = "enable"
  dns_support = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  vpn_ecmp_support = "enable"
  
  tags = {
    Name        = "Central-TGW"
  	Project     = "Azure-AWS"
  	Environment = "Dev"
  	ManagedBy   = "terraform"
  	CostCenter          = "AoD"
  }
}

################################################################################
# Resource sharing
################################################################################
resource "aws_ram_resource_share" "tgw" {
  name = "central-tgw"

  tags = {
	Name = "Central-TGW-share"
	CostCenter          = "AoD"
  }
}

#
## Transit Gateway sharing to the Organization
#
resource "aws_ram_resource_association" "hub-tgw" {
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.tgw.id
}

resource "aws_ram_principal_association" "main-org" {
  #principal          = "arn:aws:organizations::482419818288:organization/o-q8mhn3b3j0"
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.tgw.id
}

################################################################################
# VPC Attachment section
################################################################################
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attach-public-subnets" {
  subnet_ids         = [aws_subnet.PrivateSubnet1a.id, aws_subnet.PrivateSubnet1c.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.transit.id
  
  appliance_mode_support = "disable"
  dns_support = "enable"
  #ipv6_support = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
	Name = "Local-subnets-attachment"
	CostCenter          = "AoD"
  }
}

################################################################################
# Transit Gateway routing table
################################################################################
# resource "aws_ec2_transit_gateway_route_table" "association_default_route_table" {
#   transit_gateway_id             = aws_ec2_transit_gateway.tgw.id
#   #transit_gateway_route_table_id = aws_subnet.RouteTablePrivate1a.id
#   #destination_cidr_block         = "0.0.0.0/0"
#   
#   tags = {
# 	  Name        = "Central-TGW-Route-Table"
# 		Project     = "Azure-AWS"
# 		Environment = "Dev"
# 		ManagedBy   = "terraform"
# 	}
# }
# 
resource "aws_ec2_transit_gateway_route" "Internet" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_vpc_attach-public-subnets.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}
