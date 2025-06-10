# Hands-on Lab 5: Networking Between VPC and PowerVS (60 mins)

What you will learn:

* Establishing connectivity between VPC and PowerVS environments.
* Transit Gateway implementation for multi-region connectivity.
* Troubleshooting connectivity issues across hybrid infrastructures.

## Prerequisites

## Overview

With IBM Cloud Transit Gateway, you can create single or multiple transit gateways to inter-connect IBM Cloud infrastructure environments. IBM Cloud Transit Gateway is a fully redundant, fault-tolerant service with no single point of failure within IBM Cloud Multi-Zone Regions (MZR). Transit Gateway is a regional service that employs routers located in each Availability Zone.

Local routing - provides connectivity to all accessible resources within the same MZR
Global routing  - provides connectivity to all accessible resources between MZR

You can connect a VPC, Direct Link, or classic infrastructure to multiple local gateways and a single global gateway.

### Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Transit Gateway | <TEAM_NAME>-tgw-01 |

This document references:

- `<TEAM_NAME>` this is your team name e.g. `team-1`
- `<TEAM_ID_NUMBER>` this is your team number e.g. `1`

## Steps

* Step 1: Create a transit gateway
* Step 2: Create a connection to the PowerVS Workspace
* Step 3: Create a connection to the Management VPC
* Step 4: Verify
* Step 5: Troubleshooting

### Step 1: Create a transit gateway

1. To use the IBM Cloud CLI to install a transit gateway with the following

```bash
# Install the plugin
ibmcloud plugin install tg

# Get the resource group ID
resource_group_id=$(ibmcloud resource group <TEAM_NAME>-services-rg --output JSON | jq -r '.[].id')

# Create a local transit gateway
ibmcloud tg gateway-create \
--name <TEAM_NAME>-tgw-01 \
--location us-south \
--routing local \
--resource-group-id $resource_group_id
```

### Step 2: Create a connection to the PowerVS Workspace

1. Use the instructions at [Adding a connection](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-adding-connections&interface=ui) to connect the PowerVS workspace. Use the connection name `<TEAM_NAME>-powervs-wksp`.

### Step 3: Create a connection to the Management VPC

1. Use the instructions at [Adding a connection](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-adding-connections&interface=ui) to connect the PowerVS workspace. Use the connection name `<TEAM_NAME>-management-vpc`.

### Step 4: Verify

1. Follow the instructions at [Generating a route report](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-route-reports&interface=ui) to generate a route report.
2. Check that all the subnets are listed for each of the connections.
3. From the management VSIs, use Ping to test connection to all the servers
4. To test SSH use the bastion as a jump-host:

    ```bash
    [Your Local Machine]
        |
        | SSH to
        v
    [ Bastion Host ]  ---> SSH to  --->  [ Internal Server ]
    ```
by using `ssh -i ~/.ssh/hol-key -J root@<FLOATING_IP_FOR_mgmt-01-vsi> root@10.<TEAM_ID>.8.2`.

5. Once connected to the PowerVSI issue the command `ip route`.
6. Ping the management host; `ping <TEAM_NAME>-mgmt-01-vsi.<TEAM_NAME>.hol.cloud`.
7. Ping externally; `ping google.com`. Why does the name resolve? Why does the ping fail?
8. Review the routes, and end the SSH session by typing `exit`.
9. Try connecting directly via the VPN using the FQDN of the PowerVSI server.

### Step 5: Troubleshooting

If you cannot ping or SSH, then using the UI or CLI check the following:

* Security Groups.
* ACLs.
* VPN routes.
* VPC routes.
* TGW routes.
* VSI firewalls.
