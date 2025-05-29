# variables.tf - Variable definitions

variable "region" {
  description = "IBM Cloud region where resources will be deployed"
  type        = string
}

variable "zone" {
  description = "Availability zone where resources will be deployed"
  type        = string
}

# Prefix
variable "prefix" {
  description = "The prefix useed in the name of all resources. Use your <TEAM_NAME> e.g. team-1"
  type        = string
}

# Resource group
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# VPC
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

# Public Gateway
variable "public_gateway_name" {
  description = "Name of the public gateway"
  type        = string
}

# Security Groups
variable "lb_sg_name" {
  description = "Name of the load balancer security group"
  type        = string
}

variable "web_sg_name" {
  description = "Name of the web tier security group"
  type        = string
}

variable "app_sg_name" {
  description = "Name of the application tier security group"
  type        = string
}

variable "db_sg_name" {
  description = "Name of the database tier security group"
  type        = string
}

# Port configurations
variable "app_port" {
  description = "Port for the application server"
  type        = number
}

variable "db_port" {
  description = "Port for the database server"
  type        = number
}

# ACL
variable "acl_name" {
  description = "Name of the network ACL"
  type        = string
}

# Subnets
variable "web_subnet_name" {
  description = "Name of the Web subnet"
  type        = string
}

variable "web_subnet_cidr" {
  description = "CIDR block for the web_subnet"
  type        = string
}

variable "app_subnet_name" {
  description = "Name of the Application subnet"
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR block for the Application subnet"
  type        = string
}

variable "db_subnet_name" {
  description = "Name of the Database subnet"
  type        = string
}

variable "db_subnet_cidr" {
  description = "CIDR block for the Database subnet"
  type        = string
}

# Reserved IPs
variable "web_rip_name" {
  description = "Name of the web server reserved IP"
  type        = string
}

variable "web_rip_address" {
  description = "IP address for the web server"
  type        = string
}

variable "app_rip_name" {
  description = "Name of the application server reserved IP"
  type        = string
}

variable "app_rip_address" {
  description = "IP address for the application server"
  type        = string
}

variable "db_rip_name" {
  description = "Name of the database server reserved IP"
  type        = string
}

variable "db_rip_address" {
  description = "IP address for the database server"
  type        = string
}

# Virtual Network Interfaces
variable "web_vni_name" {
  description = "Name of the web server network interface"
  type        = string
}

variable "app_vni_name" {
  description = "Name of the application server network interface"
  type        = string
}

variable "db_vni_name" {
  description = "Name of the database server network interface"
  type        = string
}

# Image and Instance configuration
variable "image_name" {
  description = "Name of the OS image to use for instances"
  type        = string
}

variable "ssh_key_name" {
  description = "Name of the SSH key in IBM Cloud"
  type        = string
}

variable "instance_profile" {
  description = "Profile type for the virtual server instances"
  type        = string
}

# User data files
variable "web_user_data_file" {
  description = "Path to the user data script for the web server"
  type        = string
}

variable "app_user_data_file" {
  description = "Path to the user data script for the application server"
  type        = string
}

variable "db_user_data_file" {
  description = "Path to the user data script for the database server"
  type        = string
}

# VSI names
variable "web_vsi_name" {
  description = "Name of the web server virtual server instance"
  type        = string
}

variable "app_vsi_name" {
  description = "Name of the application server virtual server instance"
  type        = string
}

variable "db_vsi_name" {
  description = "Name of the database server virtual server instance"
  type        = string
}

# Default Gateways
variable "web_subnet_default_gw" {
  description = "Default gateway if the web subnet"
  type        = string
}

variable "app_subnet_default_gw" {
  description = "Default gateway if the application subnet"
  type        = string
}

variable "db_subnet_default_gw" {
  description = "Default gateway if the database subnet"
  type        = string
}