# main.tf - Resource definitions

# IBM Cloud Provider Configuration
terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.49.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "ibm" {
  region = var.region
}

# Create Resource Group
resource "ibm_resource_group" "app1_rg" {
  name = "${var.prefix}-${var.resource_group_name}"
}

# Create VPC
resource "ibm_is_vpc" "app1_vpc" {
  name           = "${var.prefix}-${var.vpc_name}"
  resource_group = ibm_resource_group.app1_rg.id
}

# Create Public Gateway
resource "ibm_is_public_gateway" "pgw_02_pgw" {
  name           = "${var.prefix}-${var.public_gateway_name}"
  vpc            = ibm_is_vpc.app1_vpc.id
  resource_group = ibm_resource_group.app1_rg.id
  zone           = var.zone
}

# Create Security Groups
resource "ibm_is_security_group" "app1_lb_sg" {
  name           = "${var.prefix}-${var.lb_sg_name}"
  vpc            = ibm_is_vpc.app1_vpc.id
  resource_group = ibm_resource_group.app1_rg.id
}

resource "ibm_is_security_group" "app1_web_sg" {
  name           = "${var.prefix}-${var.web_sg_name}"
  vpc            = ibm_is_vpc.app1_vpc.id
  resource_group = ibm_resource_group.app1_rg.id
}

resource "ibm_is_security_group" "app1_app_sg" {
  name           = "${var.prefix}-${var.app_sg_name}"
  vpc            = ibm_is_vpc.app1_vpc.id
  resource_group = ibm_resource_group.app1_rg.id
}

resource "ibm_is_security_group" "app1_db_sg" {
  name           = "${var.prefix}-${var.db_sg_name}"
  vpc            = ibm_is_vpc.app1_vpc.id
  resource_group = ibm_resource_group.app1_rg.id
}

# Add security group rules
# Web server security group rules
resource "ibm_is_security_group_rule" "web_sg_inbound_http" {
  group     = ibm_is_security_group.app1_web_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "web_sg_inbound_https" {
  group     = ibm_is_security_group.app1_web_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "web_sg_inbound_ssh" {
  group     = ibm_is_security_group.app1_web_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# App server security group rules
resource "ibm_is_security_group_rule" "app_sg_inbound_app" {
  group     = ibm_is_security_group.app1_app_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app1_web_sg.id.id
  
  tcp {
    port_min = var.app_port
    port_max = var.app_port
  }
}

resource "ibm_is_security_group_rule" "app_sg_inbound_ssh" {
  group     = ibm_is_security_group.app1_app_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# DB server security group rules
resource "ibm_is_security_group_rule" "db_sg_inbound_db" {
  group     = ibm_is_security_group.app1_db_sg.id
  direction = "inbound"
  remote    = ibm_is_security_group.app1_app_sg.id.id
  
  tcp {
    port_min = var.db_port
    port_max = var.db_port
  }
}

resource "ibm_is_security_group_rule" "db_sg_inbound_ssh" {
  group     = ibm_is_security_group.app1_db_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Create Network ACL
resource "ibm_is_network_acl" "app1_acl" {
  name           = "${var.prefix}-${var.acl_name}"
  vpc            = ibm_is_vpc.app1_vpc.id
  resource_group = ibm_resource_group.app1_rg.id
  
  # Allow all outbound traffic
  rules {
    name        = "allow-all-outbound"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    direction   = "outbound"
  }
  
  # Allow all inbound traffic
  rules {
    name        = "allow-all-inbound"
    action      = "allow"
    source      = "0.0.0.0/0"
    destination = "0.0.0.0/0"
    direction   = "inbound"
  }
}

# Create Web Subnet
resource "ibm_is_subnet" "app1-web_sn" {
  name            = "${var.prefix}-${var.web_subnet_name}"
  vpc             = ibm_is_vpc.app1_vpc.id
  zone            = var.zone
  ipv4_cidr_block = var.web_subnet_cidr
  network_acl     = ibm_is_network_acl.app1_acl.id
  public_gateway  = ibm_is_public_gateway.pgw_02_pgw.id
  resource_group  = ibm_resource_group.app1_rg.id
}

# Create App Subnet
resource "ibm_is_subnet" "app1-app_sn" {
  name            = "${var.prefix}-${var.app_subnet_name}"
  vpc             = ibm_is_vpc.app1_vpc.id
  zone            = var.zone
  ipv4_cidr_block = var.app_subnet_cidr
  network_acl     = ibm_is_network_acl.app1_acl.id
  public_gateway  = ibm_is_public_gateway.pgw_02_pgw.id
  resource_group  = ibm_resource_group.app1_rg.id
}

# Create DB Subnet
resource "ibm_is_subnet" "app1-db_sn" {
  name            = "${var.prefix}-${var.db_subnet_name}"
  vpc             = ibm_is_vpc.app1_vpc.id
  zone            = var.zone
  ipv4_cidr_block = var.db_subnet_cidr
  network_acl     = ibm_is_network_acl.app1_acl.id
  public_gateway  = ibm_is_public_gateway.pgw_02_pgw.id
}

# Custom Route Tables
resource "ibm_is_vpc_routing_table" "app_route_table" {
  vpc                           = ibm_is_vpc.app1_vpc
  name                          = "app1-app-routes"
  route_direct_link_ingress     = false
  route_internet_ingress        = false
  route_transit_gateway_ingress = false
  route_vpc_zone_ingress        = false
  tags                          = ["terraform", "demo", "app-tier"]
}

resource "ibm_is_vpc_routing_table" "db_route_table" {
  vpc                           = ibm_is_vpc.app1_vpc
  name                          = "app1-db-routes"
  route_direct_link_ingress     = false
  route_internet_ingress        = false
  route_transit_gateway_ingress = false
  route_vpc_zone_ingress        = false
  tags                          = ["terraform", "demo", "db-tier"]
}

# Custom Routes
# Allow app subnet to communicate with database subnet
resource "ibm_is_vpc_routing_table_route" "app_to_db_route" {
  vpc           = ibm_is_vpc.app1_vpc
  routing_table = ibm_is_vpc_routing_table.app_route_table.routing_table
  destination   = ibm_is_subnet.db_subnet.ipv4_cidr_block
  action        = "deliver"
  name          = "allow-app-to-db"
  next_hop      = var.app_subnet_default_gw  # Gateway IP of app subnet
}

# Allow database subnet to respond to app subnet
resource "ibm_is_vpc_routing_table_route" "db_to_app_route" {
  vpc           = ibm_is_vpc.app1_vpc
  routing_table = ibm_is_vpc_routing_table.db_route_table.routing_table
  destination   = ibm_is_subnet.app_subnet.ipv4_cidr_block
  action        = "deliver"
  name          = "allow-db-to-app"
  next_hop      = var.db_subnet_default_gw   # Gateway IP of db subnet
}

# Block internet access from database subnet
resource "ibm_is_vpc_routing_table_route" "db_block_internet" {
  vpc           = ibm_is_vpc.app1_vpc
  routing_table = ibm_is_vpc_routing_table.db_route_table.routing_table
  destination   = "0.0.0.0/0"
  action        = "drop"
  name          = "block-internet-access"
}

# Allow app subnet to access web subnet
resource "ibm_is_vpc_routing_table_route" "app_to_web_route" {
  vpc           = ibm_is_vpc.app1_vpc
  routing_table = ibm_is_vpc_routing_table.app_route_table.routing_table
  destination   = ibm_is_subnet.web_subnet.ipv4_cidr_block
  action        = "deliver"
  name          = "allow-app-to-web"
  next_hop      = var.app_subnet_default_gw  # Gateway IP of app subnet
}

# Route table associations
resource "ibm_is_subnet_routing_table_attachment" "app_subnet_routing" {
  subnet        = ibm_is_subnet.app_subnet.id
  routing_table = ibm_is_vpc_routing_table.app_route_table.routing_table
}

resource "ibm_is_subnet_routing_table_attachment" "db_subnet_routing" {
  subnet        = ibm_is_subnet.db_subnet.id
  routing_table = ibm_is_vpc_routing_table.db_route_table.routing_table
}

# Create Reserved IPs
resource "ibm_is_subnet_reserved_ip" "web_01_rip" {
  subnet  = ibm_is_subnet.app1_web_sn.id
  name    = "${var.prefix}-${var.web_rip_name}"
  address = var.web_rip_address
}

resource "ibm_is_subnet_reserved_ip" "app_01_rip" {
  subnet  = ibm_is_subnet.app1_app_sn.id
  name    = "${var.prefix}-${var.app_rip_name}"
  address = var.app_rip_address
}

resource "ibm_is_subnet_reserved_ip" "db_01_rip" {
  subnet  = ibm_is_subnet.app1_db_sn.id
  name    = "${var.prefix}-${var.db_rip_name}"
  address = var.db_rip_address
}

# Create Virtual Network Interfaces
resource "ibm_is_network_interface" "web_01_vni" {
  name            = "${var.prefix}-${var.web_vni_name}"
  subnet          = ibm_is_subnet.app1_web_sn.id
  security_groups = [ibm_is_security_group.app1_web_sg.id]
  primary_ip {
    reserved_ip = ibm_is_subnet_reserved_ip.web_01_rip.id
  }
}

resource "ibm_is_network_interface" "app_01_vni" {
  name            = "${var.prefix}-${var.app_vni_name}"
  subnet          = ibm_is_subnet.app1_sn_app.id
  security_groups = [ibm_is_security_group.app1_app_sg.id]
  primary_ip {
    reserved_ip = ibm_is_subnet_reserved_ip.app_01_rip.id
  }
}

resource "ibm_is_network_interface" "db_01_vni" {
  name            = "${var.prefix}-${var.db_vni_name}"
  subnet          = ibm_is_subnet.app1_db_sn.id
  security_groups = [ibm_is_security_group.app1_db_sg.id]
  primary_ip {
    reserved_ip = ibm_is_subnet_reserved_ip.db_01_rip.id
  }
}

# Look up the image
data "ibm_is_image" "ubuntu" {
  name = var.image_name
}

# Get SSH Key
data "ibm_is_ssh_key" "ssh_key" {
  name = "${var.prefix}-${var.ssh_key_name}"
}

# Create Virtual Server Instances
resource "ibm_is_instance" "web_01_vsi" {
  name           = "${var.prefix}-${var.web_vsi_name}"
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.instance_profile
  vpc            = ibm_is_vpc.app1_vpc.id
  zone           = var.zone
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  resource_group = ibm_resource_group.app1_rg.id
  user_data      = file(var.web_user_data_file)
  
  primary_network_interface {
    id = ibm_is_network_interface.web_01_vni.id
  }
}

resource "ibm_is_instance" "app_01_vsi" {
  name           = "${var.prefix}-${var.app_vsi_name}"
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.instance_profile
  vpc            = ibm_is_vpc.app1_vpc.id
  zone           = var.zone
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  resource_group = ibm_resource_group.app1_rg.id
  user_data      = file(var.app_user_data_file)
  
  primary_network_interface {
    id = ibm_is_network_interface.app_01_vni.id
  }
}

resource "ibm_is_instance" "db_01_vsi" {
  name           = "${var.prefix}-${var.db_vsi_name}"
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.instance_profile
  vpc            = ibm_is_vpc.app1_vpc.id
  zone           = var.zone
  keys           = [data.ibm_is_ssh_key.ssh_key.id]
  resource_group = ibm_resource_group.app1_rg.id
  user_data      = file(var.db_user_data_file)
  
  primary_network_interface {
    id = ibm_is_network_interface.db_01_vni.id
  }
}

# Output information
output "vpc_id" {
  value = ibm_is_vpc.app1_vpc.id
}

output "web_server_ip" {
  value = ibm_is_subnet_reserved_ip.web_01_rip.address
}

output "app_server_ip" {
  value = ibm_is_subnet_reserved_ip.app_01_rip.address
}

output "db_server_ip" {
  value = ibm_is_subnet_reserved_ip.db_01_rip.address
}