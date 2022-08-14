################################################################################
# Transit Gateway VPN connections to on-premises
################################################################################
#
## Customer Gateway 1a and VPN
#
resource "aws_customer_gateway" "cgw1a" {
  bgp_asn                  = var.bgp_asn 
  ip_address               = var.cgw1a_ipv4 
  type                     = var.ipsec_type_1a
  device_name              = var.cgw_device_name_1a
  
  tags = {
	  Name                   = var.cgw_device_name_1a
	  CostCenter             = "AoD"
  }  
}

resource "aws_vpn_connection" "on-prem-1a" {
  customer_gateway_id      = aws_customer_gateway.cgw1a.id
  transit_gateway_id       = aws_ec2_transit_gateway.tgw.id
  type                     = aws_customer_gateway.cgw1a.type

  outside_ip_address_type  = "PublicIpv4"
  tunnel_inside_ip_version = "ipv4"

  tunnel1_inside_cidr      = var.tunnel1_inside_cidr_1a
  tunnel2_inside_cidr      = var.tunnel2_inside_cidr_1a

  tunnel1_preshared_key    = var.tunnel1_preshared_key_1a
  tunnel2_preshared_key    = var.tunnel2_preshared_key_1a
  
  tunnel1_ike_versions     = ["ikev2"]
  tunnel2_ike_versions     = ["ikev2"]
  
  tags = {
	  Name                   = "VPN to on-premises router 1a"
	  CostCenter             = "AoD"
  }   
}


#
## Customer Gateway 1b and VPN
#
resource "aws_customer_gateway" "cgw1b" {
  bgp_asn                  = var.bgp_asn
  ip_address               = var.cgw1b_ipv4
  type                     = var.ipsec_type_1b
  device_name              = var.cgw_device_name_1b  
  
  tags = {
	  Name                   = var.cgw_device_name_1b
	  CostCenter             = "AoD"
  }    
}

resource "aws_vpn_connection" "on-prem-1b" {
  customer_gateway_id      = aws_customer_gateway.cgw1b.id
  transit_gateway_id       = aws_ec2_transit_gateway.tgw.id
  type                     = aws_customer_gateway.cgw1b.type

  outside_ip_address_type  = "PublicIpv4"
  tunnel_inside_ip_version = "ipv4"

  tunnel1_inside_cidr      = var.tunnel1_inside_cidr_1b
  tunnel2_inside_cidr      = var.tunnel2_inside_cidr_1b

  tunnel1_preshared_key    = var.tunnel1_preshared_key_1b
  tunnel2_preshared_key    = var.tunnel2_preshared_key_1b

  tunnel1_ike_versions     = ["ikev2"]
  tunnel2_ike_versions     = ["ikev2"]  
  
  tags = {
	  Name                   = "VPN to on-premises router 1c"
	  CostCenter             = "AoD"
  }      
}

