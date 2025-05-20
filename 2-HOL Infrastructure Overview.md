# Hands on Lab Infrastructure Overview

This document describes the IBM Cloud infrastructure deployed in these Hands On Lab (HOL) sessions.

At the end of these HOL sessions you will have deployed the following:

- **Resource Groups**:
    - Services
    - Management
    - App1
- **API Key**
- **VPCs**:
    - Management
    - App1
- **IBM Cloud Services**:
    - Activity tracker
    - Activity tracker Event Routing
    - VPC Flow Log Collector
    - Key protect
    - Secrets Manager instance with private certificate
    - Object Storage
    - Cloud Logs
    - Monitoring
    - SCC Workload Protection
    - Private DNS:
        - Custom Resolvers.
- **VPC Infrastructure**:
    - SSH Key
    - Subnets:
        - VPN
        - Management
        - VPE
        - App1
    - Virtual Server Instance (VSI)
        - Mgmt Server 
        - Web Server
        - App Server
        - DB Server
    - Client to site VPN server
    - Application load balancer
    - Floating IP:
        - Mgmt
    - Reserved IPs:
        - Mgmt Server 
        - Web Server
        - App Server
        - DB Server
    - Public Gateway
- **PowerVS**:
    - SSH Key
    - Subnets:
        - Database
    - Virtual Server Instance (VSI)
        - DB Server

- **Transit Gateway**
    - Local transit gateway

## Hands-on Lab Synopses

The sections below give an overview of each of the HOLS

### Hands-on Lab 1: Introduction to IBM Cloud VPC (120 mins)

What you will learn:

* Core concepts and architecture of IBM Cloud VPC.
* VPC components: subnets, security groups, ACLs, and virtual server instances.
* VPC management through UI, CLI, and API interfaces.
* Implementing VPC subnets, routing tables, and load balancers.
* Configuring public gateways and floating IP addresses.
* Audit logging and security monitoring in VPC environments.

### Hands-on Lab 2: IBM Cloud VPC VPN (120 mins)

What you will learn:

* VPC VPN concepts, types, and use cases.
* Configure and deploy VPN gateways within IBM Cloud VPC.
* Establish site-to-site and client-to-site VPN connections
* Monitor and troubleshoot VPN connectivity
* Apply security best practices for VPN implementations.

### Hands-on Lab 3: Storage Solutions in IBM Cloud VPC (120 mins)

What you will learn:

* Block storage provisioning and management in VPC.
* File and object storage integration with VPC resources.
* Storage performance tiers and optimization strategies.
* Snapshot and backup implementation for VPC storage.
* VPC encryption options and key management.

### Hands-on Lab 4: Introduction to IBM PowerVS (120 mins)
What you will learn:

* PowerVS fundamentals and service architecture.
* Virtual service instance deployment on PowerVS.
* PowerVS storage volume management.
* PowerVS management using console, CLI, and API interfaces.

### Hands-on Lab 5: Networking Between VPC and PowerVS (60 mins)
What you will learn:

* Establishing connectivity between VPC and PowerVS environments.
* Transit Gateway implementation for multi-region connectivity.
* Troubleshooting connectivity issues across hybrid infrastructures.

### Hands-on Lab 6: Monitoring, Observability, and Logging Across VPC and PowerVS (120 mins)
What you will learn:

* Deploying and configuring IBM Cloud Monitoring with Sysdig.
* Setting up IBM Log Analysis and integrating with VPC/PowerVS workloads.
* Custom metrics collection from virtual server instances.
* Building dashboards, setting alerts, and automated incident response.
* Integrating third-party observability tools with IBM Cloud.

### Hands-on Lab 7: Automation and Infrastructure as Code (60 mins)
What you will learn:

* Terraform implementation for VPC and PowerVS provisioning
* Ansible automation for configuration management
* Creating reusable templates and modules
* CI/CD pipeline integration for infrastructure deployment
* Managing infrastructure drift and version control

### Hands-on Lab 8: Protecting Workloads with IBM Cloud Security and Compliance Center Workload Protection (90 mins)
What you will learn:

* Overview of IBM Cloud Security and Compliance Center Workload Protection.
* Installing and configuring Workload Protection agents for VPC and PowerVS instances.
* Policy creation: vulnerability management, compliance enforcement, and threat detection.
* Real-time security event monitoring and automated response workflows.

### Hands-on Lab 9: IBM Cloud Identity and Access Management (IAM) for VPC and PowerVS (120 mins)
What you will learn:

* Configure and manage IBM Cloud IAM access policies.
* Implement role-based access control for users and service accounts.
* Leveraging service IDs and API keys.
* Using trusted profiles and context based restrictions.
* Monitor and audit IAM activities using Cloud Activity Tracker.

### Hands-on Lab 10: IBM Cloud for SAP Specialty (300 mins)
What you will learn:

* SAP Architecture in IBM Cloud.
* Compute and Storage Options for SAP.
* Network / Security and Certifications for SAP.
* SAP HANA Tuning on PowerVS.
* SAP HANA Backup COS.

## Network Addressing

Each of the teams will get their own IP address range based on `10.<TEAM_ID>.0.0/20`. This range will be sub-netted to create the following /22 networks: 

* VPC-Management
* VPC-App1
* PowerVS-DB

### Teams

Team | Team Name | Team ID Number | Base Network CIDR
---|---|---|---
Team 1 | team-1 | 1 | 10.1.0.0/20
Team 2 | team-2 | 2 | 10.2.0.0/20
Team 3 | team-3 | 3 | 10.3.0.0/20
Team 4 | team-4 | 4 | 10.4.0.0/20
Team 5 | team-5 | 5 | 10.5.0.0/20
Team 6 | team-6 | 6 | 10.6.0.0/20
Team 7 | team-7 | 7 | 10.7.0.0/20
Team 8 | team-8 | 8 | 10.8.0.0/20
Team 9 | team-9 | 9 | 10.9.0.0/20
Team 10 | team-10 | 10 | 10.10.0.0/20
Team 11 | team-11 | 11 | 10.11.0.0/20
Team 12 | team-12 | 12 | 10.12.0.0/20
Team 13 | team-13 | 13 | 10.13.0.0/20
Team 14 | team-14 | 14 | 10.14.0.0/20
Team 15 | team-15 | 15 | 10.15.0.0/20
Team 16 | team-16 | 16 | 10.16.0.0/20
Team 17 | team-17 | 17 | 10.17.0.0/20
Team 18 | team-18 | 18 | 10.18.0.0/20
Team 19 | team-19 | 19 | 10.19.0.0/20
Team 20 | team-20 | 20 | 10.20.0.0/20

### Example
For example, for Team 1:

* **<TEAM_ID>**:         1
* **Base Network CIDR**: 10.1.0.0/20

Subnet Address | Range of Addresses | Usable IPs | Hosts | Note
---|---|---|---|---
10.1.0.0/22 | 10.1.0.0 - 10.1.3.255 | 10.1.0.1 - 10.1.3.254 | 1022 | VPC-Management
10.1.4.0/22 | 10.1.4.0 - 10.1.7.255 | 10.1.4.1 - 10.1.7.254 | 1022 | VPC-App1
10.1.8.0/22 | 10.1.8.0 - 10.1.11.255 | 10.1.8.1 - 10.1.11.254 | 1022 | PowerVS-DB
10.1.12.0/22 | 10.1.12.0 - 10.1.15.255 | 10.1.12.1 - 10.1.15.254 | 1022 | Spare

#### VPC-Management

**Network Address**: 10.1.0.0/22

Subnet Address | Range of Addresses | Usable IPs | Hosts | Note
---|---|---|---|---
10.1.0.0/24 | 10.1.0.0 - 10.1.0.255 | 10.1.0.1 - 10.1.0.254 | 254 | VPN
10.1.1.0/24 | 10.1.1.0 - 10.1.1.255 | 10.1.1.1 - 10.1.1.254 | 254 | Management
10.1.2.0/24 | 10.1.2.0 - 10.1.2.255 | 10.1.2.1 - 10.1.2.254 | 254 | VPE
10.1.3.0/24 | 10.1.3.0 - 10.1.3.255 | 10.1.3.1 - 10.1.3.254 | 254 | Spare

The reserved IP addresses for the subnet **Management** are as follows:

IP Address | Usage
---|---
10.1.1.4 | mgmt-01
10.1.1.5 | mgmt-02

The reserved IP addresses for the subnet **VPE** are as follows:

IP Address | Usage
---|---
10.1.2.4 | TBD
10.1.2.5 | TBD

#### VPC-App1

**Network Address**: 10.1.4.0/22

Subnet Address | Range of Addresses | Usable IPs | Hosts | Note
---|---|---|---|---
10.1.4.0/24 | 10.1.4.0 - 10.1.4.255 | 10.1.4.1 - 10.1.4.254 | 254 | App1
10.1.5.0/24 | 10.1.5.0 - 10.1.5.255 | 10.1.5.1 - 10.1.5.254 | 254 | Spare
10.1.6.0/24 | 10.1.6.0 - 10.1.6.255 | 10.1.6.1 - 10.1.6.254 | 254 | Spare
10.1.7.0/24 | 10.1.7.0 - 10.1.7.255 | 10.1.7.1 - 10.1.7.254 | 254 | Spare

The reserved IP addresses for the subnet **App1** are as follows:

IP Address | Usage
---|---
10.1.4.4 | Web-Server
10.1.4.5 | DB-Server (x86)

#### PowerVS-DB

**Network Address**: 10.1.8.0/22

Subnet Address | Range of Addresses | Usable IPs | Hosts | Note
---|---|---|---|---
10.1.8.0/24 | 10.1.8.0 - 10.1.8.255 | 10.1.8.1 - 10.1.8.254 | 254 | PowerVS DB
10.1.9.0/24 | 10.1.9.0 - 10.1.9.255 | 10.1.9.1 - 10.1.9.254 | 254 | Spare
10.1.10.0/24 | 10.1.10.0 - 10.1.10.255 | 10.1.10.1 - 10.1.10.254 | 254 | Spare
10.1.11.0/24 | 10.1.11.0 - 10.1.11.255 | 10.1.11.1 - 10.1.11.254 | 254 | Spare

The reserved IP addresses for the subnet **PowerVS DB** are as follows:

IP Address | Usage
---|---
10.1.8.5 | DB-Server (PowerVS)