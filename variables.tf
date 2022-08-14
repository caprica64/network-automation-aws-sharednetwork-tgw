#Region
variable "region" {}

#VPC variables
variable "vpc_name" {}
variable "cidr_block" {}
variable "public_subnet_1a_cidr" {}
variable "public_subnet_1c_cidr" {}
variable "private_subnet_1a_cidr" {}
variable "private_subnet_1c_cidr" {}


#Spoke 1 destination CIDR block
variable "spoke1_cidr" {}

#On-premises Customer Gateway and VPN
variable "cgw1a_ipv4" {}
variable "cgw1b_ipv4" {}
variable "bgp_asn" {}
variable "ipsec_type_1a" {}
variable "ipsec_type_1b" {}
variable "cgw_device_name_1a" {}
variable "cgw_device_name_1b" {}

variable "tunnel1_inside_cidr_1a" {}
variable "tunnel2_inside_cidr_1a" {}
variable "tunnel1_preshared_key_1a" {}
variable "tunnel2_preshared_key_1a" {}

variable "tunnel1_inside_cidr_1b" {}
variable "tunnel2_inside_cidr_1b" {}
variable "tunnel1_preshared_key_1b" {}
variable "tunnel2_preshared_key_1b" {}
