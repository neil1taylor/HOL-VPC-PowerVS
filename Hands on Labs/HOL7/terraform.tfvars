# terraform.tfvars - Input parameter values

# Region and Zone
region = "us-south"
zone   = "us-south-1"

# Prefix
prefix = ""

# Resource Group
resource_group_name = "app1-rg"

# VPC
vpc_name = "app1-vpc"

# Public Gateway
public_gateway_name = "pgw-02-pgw"

# Security Groups
lb_sg_name  = "app1-lb-sg"
web_sg_name = "app1-web-sg"
app_sg_name = "app1-app-sg"
db_sg_name  = "app1-db-sg"

# Port configurations
app_port = 8080
db_port  = 3306

# ACL
acl_name = "app1-acl"

# Subnets
web_subnet_name = "app1-web-sn"
web_subnet_cidr = "10.1.4.0/26"
app_subnet_name = "app1-app-sn"
app_subnet_cidr = "10.1.4.64/26"
db_subnet_name = "app1-db-sn"
db_subnet_cidr = "10.1.4.128/26"

# Reserved IPs
web_rip_name    = "web-01-rip"
web_rip_address = "10.1.4.4"
app_rip_name    = "app-01-rip"
app_rip_address = "10.1.4.5"
db_rip_name     = "db-01-rip"
db_rip_address  = "10.1.4.6"

# Virtual Network Interfaces
web_vni_name = "web-01-vni"
app_vni_name = "app-01-vni"
db_vni_name  = "db-01-vni"

# Image and Instance configuration
image_name       = "ibm-ubuntu-20-04-minimal-amd64-2"
ssh_key_name     = "my-ssh-key"  # Replace with your actual SSH key name
instance_profile = "cx2-2x4"

# VSI names
web_vsi_name = "web-01-vsi"
app_vsi_name = "app-01-vsi"
db_vsi_name  = "db-01-vsi"

# User data files
web_user_data_file = "userdata/web_user_data.sh"
app_user_data_file = "userdata/app_user_data.sh"
db_user_data_file  = "userdata/db_user_data.sh"

# Subnet default gateway
web_subnet_default_gw = "10.1.4.1"
app_subnet_default_gw = "10.1.4.65"
db_subnet_default_gw = "10.1.4.129"