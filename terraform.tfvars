#Region
region = "us-west-2"

#VPC variables
vpc_name = "transit"
cidr_block = "10.0.0.0/16"

public_subnet_1a_cidr = "10.0.0.0/24"
public_subnet_1c_cidr = "10.0.1.0/24"

private_subnet_1a_cidr = "10.0.128.0/24"
private_subnet_1c_cidr = "10.0.129.0/24"

#Spoke network destination prefixes
spoke1_cidr = "10.1.0.0/16"

# On-premises Customer Gateway and VPN variables
cgw1a_ipv4 = "18.228.209.13"
cgw1b_ipv4 = "18.230.112.244"

bgp_asn = "65000"

ipsec_type_1a = "ipsec.1"
ipsec_type_1b = "ipsec.1"

cgw_device_name_1a = "Cisco 1000v 1a"
cgw_device_name_1b = "Cisco 1000v 1b"

tunnel1_inside_cidr_1a      = "169.254.1.4/30"
tunnel2_inside_cidr_1a      = "169.254.2.4/30"

tunnel1_preshared_key_1a    = "presharedkey1_1a"
tunnel2_preshared_key_1a    = "presharedkey2_1a"

tunnel1_inside_cidr_1b      = "169.254.5.4/30"
tunnel2_inside_cidr_1b      = "169.254.6.4/30"

tunnel1_preshared_key_1b    = "presharedkey1_1b"
tunnel2_preshared_key_1b    = "presharedkey2_1b"

