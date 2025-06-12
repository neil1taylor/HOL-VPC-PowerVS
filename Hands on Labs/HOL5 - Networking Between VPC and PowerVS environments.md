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
* Step 6: Configure Proxy for Internet Access

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
6. Ping the management host; `ping <TEAM_NAME>-mgmt-01-vsi.<TEAM_NAME>.hol.cloud`. Why does this fail? Is the name resolution response allowed through the the PowerVS Network Security Group? DNS uses UDP port 53, and the custom resolvers are on the VPE subnet. Add a rule to allow UDP source port 53 to all destination ports in the NSG that has the PowerVS VSI as a member.
7. Ping externally; `ping google.com`. Why does the name resolve but the ping fail? Is it because the PowerVS VSI has no access to the Internet?
8. Review the routes, and end the SSH session by typing `exit`.
9. Try connecting directly via the VPN using the FQDN of the PowerVSI server.

**NOTE** If you have problems connecting to the PowerVS VSI via the bastion try the following:

`ssh -A -o ServerAliveInterval=60 -o ServerAliveCountMax=600 -o ProxyCommand="ssh -W %h:%p root@<FLOATING_IP_FOR_mgmt-01-vsi> -i ~/.ssh/hol-key" root@10.<TEAM_ID>.8.2 -i ~/.ssh/hol-key`

The final target of the command `root@10.<TEAM_ID>.8.2`

* `-A` (Agent Forwarding) - Forwards your local SSH agent to the remote server, allowing you to use your local SSH keys on the remote machine without copying them there.
* `-o ServerAliveInterval=60` - Sends a keep-alive message every 60 seconds to prevent the connection from timing out
* `-o ServerAliveCountMax=600` - Allows up to 600 unanswered keep-alive messages before disconnecting (that's 10 hours of potential downtime)
* `ProxyCommand="ssh -W %h:%p root@<FLOATING_IP_FOR_mgmt-01-vsi> -i ~/.ssh/hol-key"` - This creates a tunnel through an intermediate server. First connects to `root@<FLOATING_IP_FOR_mgmt-01-vsi>` (the jump host with a public IP). `-W %h:%p tells the jump host to forward the connection to the final destination (%h = hostname, %p = port)`

### Step 5: Troubleshooting

If you cannot ping or SSH, then using the UI or CLI check the following:

* Security Groups.
* ACLs.
* VPN routes.
* VPC routes.
* TGW routes.
* VSI firewalls.

## Step 6: Configure Proxy for Internet Access

You will have noticed that the PowerVS does not have access to the Internet. We will rectify this by using a proxy server:

1. Install Squid on `<TEAM_NAME>-mgmt-01-vsi` using `apt install squid -y`.
2. Use the command `curl -I -x localhost:3128 https://google.com` to see that the configuration is correct. You should see `HTTP/1.1 200 Connection established`.
3. In the VPC security group attached to `<TEAM_NAME>-mgmt-01-vsi`, allow inbound TCP port 3128 to `10.<TEAM_ID>.1.4` from CIDR `10.<TEAM_ID>.8.0/24`.
4. By default, only the localhost can access the proxy so use the following commands to allow the predefined `localnet acl` access control. The `localnet acl` includes `10.0.0.0/8`:

   ```bash
   echo "http_access allow localnet" > /etc/squid/conf.d/team-1.conf
   systemctl restart squid
   ```

5. In the PowerVS network security group where the `<TEAM_NAME>-db-powervs-vsi` is a member, allow inbound source TCP port 3128 to destination ports `1 - 65535`.
6. On `<TEAM_NAME>-db-powervs-vsi` create a file that contains exports that sets the proxies:

      1. Open a terminal, use vi to modify the file `~/.bash_profile`, replacing <proxy_ip_address> and <proxy_port> with the actual values of your proxy server: 

      ```bash
      export http_proxy=http://10.<TEAM_ID>.1.4:3128
      export https_proxy=http://10.<TEAM_ID>.1.4:3128
      export HTTP_PROXY=http://10.<TEAM_ID>.1.4:3128
      export HTTPS_PROXY=http://10.<TEAM_ID>.1.4:3128
      export no_proxy=161.0.0.0/0,10.0.0.0/8
      ```

      For information:

      * http_proxy and HTTP_PROXY: These are for HTTP traffic (port 80). 
      * https_proxy and HTTPS_PROXY: These are for HTTPS traffic (port 443). 
      * no_proxy: This specifies networks or hosts that should bypass the proxy.
      * To ensure these environment variables are available after a reboot, we add them to a file ~/.bash_profile.

7. Type `source ~/.bash_profile`. 
8. Test the Proxy with `curl -I https://www.google.com`. If the proxy is configured correctly, you should see the HTTP headers from Google and `HTTP/1.1 200 Connection established`
