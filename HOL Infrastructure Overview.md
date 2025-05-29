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
    - SSH Keys:
        - Attendee 1
        - Attendee 2
    - Security Groups:
        - VPN
        - Management
        - Load balancer
        - Web
        - App
        - DB
    - Access Control Lists (ACL):
        - Management
        - App1
    - Subnets:
        - VPN
        - Management
        - VPE
        - App1
    - Virtual Network Interface (VNI)
        - Mgmt Server 
        - Web Server
        - App Server
        - DB Server
    - Virtual Server Instance (VSI)
        - Mgmt Server 
        - Web Server
        - App Server
        - DB Server
    - Client to site VPN server
    - Site to site VPN gateway
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
10.1.4.0/26 | 10.1.4.0 - 10.1.4.63 | 10.1.4.1 - 10.1.4.62 | 62 | App1-Web
10.1.4.64/26 | 10.1.4.64 - 10.1.4.127 | 10.1.4.65 - 10.1.4.126 | 62 | App1-App
10.1.4.128/26 | 10.1.4.128 - 10.1.4.191 | 10.1.4.129 - 10.1.4.190 | 62 | App1-DB
10.1.4.192/26 | 10.1.4.192 - 10.1.4.255 | 10.1.4.193 - 10.1.4.254 | 62 | App1-Spare
10.1.5.0/24 | 10.1.5.0 - 10.1.5.255 | 10.1.5.1 - 10.1.5.254 | 254 | Spare
10.1.6.0/24 | 10.1.6.0 - 10.1.6.255 | 10.1.6.1 - 10.1.6.254 | 254 | Spare
10.1.7.0/24 | 10.1.7.0 - 10.1.7.255 | 10.1.7.1 - 10.1.7.254 | 254 | Spare

The reserved IP addresses for the subnets assigned to **App1** are as follows:

IP Address | Usage
---|---
10.1.4.4 | Web-Server
10.1.4.69 | App-Server
10.1.4.133 | DB-Server (x86)

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