Resource Group: team-1--app1-rg
VPC: team-1-app1-vpc
Public Gateway: team-1-pgw-02-pgw
Security Group: team-1-app1-lb-sg
Security Group: team-1-app1-web-sg
Security Group: team-1-app1-app-sg
Security Group: team-1-app1-db-sg
ACL: team-1-app1-acl
Subnet: team-1-app1-sn. Attach team-1-pgw-02-pgw, 10.1.4.0/24
Reserved IP: team-1-web-01-rip. 10.1.4.4
Reserved IP: team-1-app-01-rip. 10.1.4.5
Reserved IP: team-1-db-01-rip. 10.1.4.6
Virtual Network Interface: team-1-web-01-vni Attach RIP team-1-web-01-rip
Virtual Network Interface: team-1-app-01-vni Attach RIP team-1-app-01-rip
Virtual Network Interface: team-1-db-01-vni Attach RIP team-1-db-01-rip
Virtual Server Instance: team-1-web-01-vsi Attach team-1-web-01-vni
Virtual Server Instance: team-1-app-01-vsi Attach team-1-app-01-vni
Virtual Server Instance: team-1-db-01-vsi Attach team-1-db-01-vni
