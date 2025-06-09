# Hands-on Lab 1: Introduction to IBM Cloud VPC

What you will learn:

* Core concepts and architecture of IBM Cloud VPC.
* VPC components: subnets, security groups, ACLs, and virtual server instances.
* VPC management through UI, CLI, and API interfaces.
* Implementing private DNS.
* Configuring public gateways and floating IP addresses.
* Audit logging and security monitoring in VPC environments.

## Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Resource Groups | <TEAM_NAME>-services-rg | Deployed via UI
Resource Groups | <TEAM_NAME>-management-rg | Deployed via UI
SSH Key | <TEAM_NAME>-ssh-key-1 | Deployed via UI
SSH Key | <TEAM_NAME>-ssh-key-2 | Deployed via CLI
VPC | <TEAM_NAME>-management-vpc | Deployed via UI
Private DNS Instance | <TEAM_NAME>-dns-srv | Deployed via UI
Private DNS Custom Resolvers | |
Private DNS Zone | team<TEAM_NUMBER>.hol.cloud |
Floating IP | <TEAM_NAME>-mgmt-fip |
Public Gateway | <TEAM_NAME>-pgw-01-pgw | Attach to all VPC subnets
Security Group | <TEAM_NAME>-vpn-sg | 
Security Group | <TEAM_NAME>-mgmt-sg | 
Security Group | <TEAM_NAME>-vpe-sg | 
Security Group | <TEAM_NAME>-nfs-sg | 
ACL | <TEAM_NAME>-mgmt-acl |
Subnet | <TEAM_NAME>-vpn-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.0.0/24
Subnet | <TEAM_NAME>-mgmt-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.1.0/24
Subnet | <TEAM_NAME>-vpe-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.2.0/24
Reserved IP | <TEAM_NAME>-mgmt-01-rip | 10.<TEAM_ID_NUMBER>.1.4
Reserved IP | <TEAM_NAME>-mgmt-02-rip | 10.<TEAM_ID_NUMBER>.1.5
Virtual Network Interface | <TEAM_NAME>-mgmt-01-vni | Attach RIP
Virtual Network Interface | <TEAM_NAME>-mgmt-02-vni | Attach RIP
Virtual Server Instance | <TEAM_NAME>-mgmt-01-vsi | Ubuntu, attach FIP, attach userdata-mgmt-lin
Virtual Server Instance | <TEAM_NAME>-mgmt-02-vsi | Windows, userdata-mgmt-win

This document references:

- `<TEAM_NAME>` this is your team name e.g. `team-1`
- `<TEAM_ID_NUMBER>` this is your team number e.g. `1`

## Scenario

In this HOL we will:

* Create Resource Groups:
    * Step 1: Create Resource Groups using the UI
    * Step 2: Create Resource Groups using the CLI
* Create and import SSH Keys:
    * Step 1: Create an SSH Key pair
    * Step 2: Upload the SSH Public Key using the UI
    * Step 3: Upload the SSH Public Key using the CLI
* Create VPC:
    * Step 1: Create Management VPC
    * Step 2: Create VPC prefixes
* Create DNS Instance:
    * Step 1: Create a DNS Services instance
    * Step 2: Add a DNS zone
    * Step 3: Add a VPC as a permitted network to the DNS zone
    * Step 4: Add DNS resource A records
    * Step 5: Add DNS resource PTR records
* Create a public gateway:
     * Step 1: Create a Public Gateway
* Create Subnets:
    * Step 1: Create subnets using the UI
    * Step 2: Create subnets using the CLI
* Reserved IP addresses:
    * Step 1: Reserve subnet IP addresses using the UI
    * Step 2: Reserve subnet IP addresses using the UI
* Create Security Groups:
    * Step 1: Create a Security Group in the UI
    * Step 2: Create a Security Group in the CLI
    * Step 3: Create a Security Group Rules in the CLI
* Create ACL:
    * Step 1: Create an ACL
* Create DNS Custom Resolvers:
    * Step 1: Create DNS Custom Resolvers
    * Create Virtual Network Interfaces:
    * Step 1: Create a VNI in the UI
    * Step 2: Create other VNI in the UI
* Create Virtual Server Instances:
    * Step 1: Create a VSI in the UI
    * Step 2: Create a VSI in the CLI

## Create Resource Groups

We will learn how to create Resource Groups using the IBM Cloud UI and CLI.

### Step 1: Create Resource Groups using the UI

We will create 3 resource groups. Two using the UI and one with the CLI:

1. Using a browser navigate to https://cloud.ibm.com
2. Log in to IBM Cloud.
3. Go to **Manage / Account / Resource Groups**.
4. Click Create.
5. Name: `<TEAM_NAME>-services-rg`.
6. Click Create.

### Step 2: Create Resource Groups using the CLI

For the third one we will use the CLI:

1. Open a terminal session.
2. In the terminal session type: `ibmcloud login --sso`
3. Follow the prompts and log on.
4. In the terminal session type: `ibmcloud resource group-create <TEAM_NAME>-management-rg`
5. In the terminal session type: `ibmcloud resource groups`
6. Ensure you see the following: `<TEAM_NAME>-management-rg`, `<TEAM_NAME>-services-rg` and `Default`.

## Create and import SSH Keys

We will learn how to create an SSH key pair and import the public key to IBM Cloud

### Step 1: Create an SSH Key pair

On the first participant's laptop, if you are using Linux or MacOS, in a terminal session:

`ssh-keygen -b 4096 -t rsa -f ~/.ssh/hol-key -q -N ""`

If you are using Windows, in a PowerShell session:

`ssh-keygen -b 4096 -t rsa` and press enter to all prompts

On the second participant's laptop, follow step 1 above

### Step 2: Upload the SSH Public Key using the UI

On the first participants laptop, we will upload the first key to IBM Cloud using the UI.

1. In IBM Cloud console, go to **Navigation menu / Infrastructure VPC icon / Compute / SSH keys**.
2. Click **Create** and enter the following information:

   * **Geography**: `North America`
   * **Region**: `Dallas (us-south)`
   * **Name**: `<TEAM_NAME>-ssh-key-1`
   * **Resource group**: `<TEAM_NAME>-management-rg`
   * **Tags**: `env:mgmt`

3. Select **Provide existing public key**.
4. Click **Upload public key**.
5. Select the public key file and click **Open**. The file extension, `.pub`, typically indicates which file contains the public key.
6. Click **Create**.

### Step 3: Upload the SSH Public Key using the CLI

On the second participants laptop, we will upload the second key to IBM Cloud using the CLI.

If using Linux or MacOS:

```bash
ibmcloud is key-create \
<TEAM_NAME>-ssh-key-2 \
@~/.ssh/hol-key.pub \
--resource-group-name <TEAM_NAME>-management-rg
```

Or if using Windows:

```ps1
ibmcloud is key-create \
<TEAM_NAME>-ssh-key-2 \
@pub_key_path \
--resource-group-name <TEAM_NAME>-management-rg
```

## Create VPC

We will learn how to create VPCs using the IBM Cloud UI and CLI.

By default, each zone of your VPC is assigned a default address prefix that specifies the address range in which subnets are created. As we want to define the IP ranges we will **disable** this behavior.

### Step 1: Create Management VPC

The first VPC we will create using the UI.

1. Select the Navigation Menu Menu icon, then click **VPC Infrastructure / VPCs**.
2. Click **Create +**.
3. In the Location section, provide the following information:

   * **Geography**: `North America`
   * **Region**: `us-south`
  
4. In the Details section, provide the following information:
   
   * **Name**: `<TEAM_NAME>-management-vpc`
   * **Resource Group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt`.
  
5. Uncheck the **Create a default prefix for each zone**.
6. Click **Create**.

### Step 2: Create VPC prefixes

1. Navigate to **VPC**.
2. Click on `<TEAM_NAME>-management-vpc`.
3. Click on **Address Prefixes**.
4. Click on **Create +**:
5. In the details box:

    * **IP Range**: `10.<TEAM_ID_NUMBER>.0.0/22`
    * **Location**: `us-south-1`

In these hands on labs we are only using one Availability Zone (AZ), when designing your IP schema allow for three AZs.

### Step 3: Rename Default Security Group, ACL and Route Table

1. In the VPC you created click **Overview**.
2. Note the random names of the default Security Group, ACL and Route Table.
3. Click on the ACL name one and using **Actiuns / Rename**, rename to:`<TEAM_NAME>-management-vpc-default-acl`.
4. For the security group and route table, click on the name and use the pencil (edit) button to change the names to:

   * `<TEAM_NAME>-management-vpc-default-sg`
   * `<TEAM_NAME>-management-vpc-default-rt`

## Create DNS Instance

We will learn how to create a DNS instance. IBM Cloud DNS Services provide private DNS to Virtual Private Cloud (VPC) users. Private DNS zones are resolvable only on IBM Cloud, and only from explicitly permitted networks in an account.

### Step 1: Create a DNS Services instance

1. Open the IBM Cloud catalog page and in teh Search box type **DNS** and then select **DNS Services**.
2. In the **Create** tab:
 
   * **Service name**: `<TEAM_NAME>-dns-srv`
   * **Resource group**: `<TEAM_NAME>-services-rg`
   * **Tags**: `env:services`
 
3. Check the **I have read and agree to the following license agreements** box.
4. Click **Create**.

### Step 2: Add a DNS zone

1. The Zone page for the service instance should automatically be displayed.
2. Click the **Create zone** button on the DNS Zones page.
3. Enter the following:
 
   * **Name**: team<TEAM_NUMBER>.hol.cloud e.g. `team1.hol.cloud`

4. Click **Create zone**

### Step 3: Add a VPC as a permitted network to the DNS zone

1. Select the **Permitted networks** tab.
2. Click **Add network**.
3. Select:
 
   * **Region**: `Dallas`
   * **Network**: `<TEAM_NAME>-management-vpc`

4. Click **Add network**.

### Step 4: Add DNS resource A records

1. From the **DNS zones** table, click the zone name team<TEAM_NUMBER>.hol.cloud.
2. Click **Select record action / Add record** to display a panel where you create the record.
3. Select **type of record** `A`.
4. Enter:
 
   * **Name**: `<TEAM_NAME>-mgmt-01-vsi`
   * **IPv4 Address**: `10.<TEAM_NUMBER>.1.4`

5. Click **Save**
6. Repeat for:
 
   * **Name**: `<TEAM_NAME>-mgmt-02-vsi`
   * **IPv4 Address**: `10.<TEAM_NUMBER>.1.5`

### Step 5: Add DNS resource PTR records

1. Click **Add Record** to display a panel where you create the record.
2. Select **type of record** `PTR`.
3. Select **existing record**: `<TEAM_NAME>-mgmt-01-vsi`
4. Repeat for` <TEAM_NAME>-mgmt-02-vsi`

## Create a public gateway

A public gateway enables a subnet and all its attached virtual server instances to connect to the internet. By default, subnets do not have access to the public internet. After a subnet is attached to a public gateway, all instances in that subnet can connect to the internet.

We will learn how to create a public gateway using the IBM Cloud UI.

### Step 1: Create a Public Gateway

1. Click Infrastructure > Network > Public gateways.
2. Click Create.
3. In the Edit location, enter values for the following fields:

   * **Geography**: `North America`
   * **Region**: `us-south`
   * **Zone**: `us-south-1`

4. Enter values for the following fields under details:

   * Public gateway name - `<TEAM_NAME>-pgw-01-pgw`.
   * Resource group - `<TEAM_NAME>-Management`.
   * VPC - `<TEAM_NAME>-management-vpc`.
   * Tags - `env:mgmt`.

5. Click Create.

## Create Subnets

Subnets are networks created within a VPC. Subnets are a fundamental mechanism within VPC used to allocate addresses to individual resources (such as Virtual server instances), and enable various controls to these resources through the use of network ACLs, routing tables, resource groups.

Subnets are bound to a single zone; however, they can reach all other subnets within a VPC, across a region. They are created from a larger address space within the VPC called an address prefix; and you can provision multiple subnets per address prefix.

We will learn how to create subnets using the IBM Cloud UI and CLI.

### Step 1: Create subnets using the UI

We will create two subnets using the UI.

1. Click **Infrastructure / Network / Subnets**.
2. Click **Create +**.
3. In the Location section, provide the following information:

   * **Geography**: `North America`
   * **Region**: `us-south`

4. In the Details section, provide the following information:

   - **Name**: `<TEAM_NAME>-vpn-sn`.
   - **Resource group**: `<TEAM_NAME>-management-rg`.
   - **Tags**: `env:mgmt`.
   - **Virtual private cloud**: `<TEAM_NAME>-management-vpc`.
   - **IP range selection**: `10.<TEAM_ID_NUMBER>.0.0/24`.
   - **Routing table**: `<TEAM_NAME>-mgmt-rt`
   - **Subnet access control list**: `<TEAM_NAME>-mgmt-sg`
   - **Public gateway**: `Attached`.

5. Click **Create subnet** to create the subnet.

Follow the steps above using the following:

   - **Name**: `<TEAM_NAME>-mgmt-sn`
   - **Resource group**: `<TEAM_NAME>-management-rg`.
   - **Tags**: `env:mgmt`.
   - **Virtual private cloud**: `<TEAM_NAME>-management-vpc`.
   - **IP range selection**: `10.<TEAM_ID_NUMBER>.1.0/24`
   - **Public gateway**: `Attached`.

### Step 2: Create subnets using the CLI

Now we will use the IBM Cloud CLI.

1. In a terminal session:

```bash
ibmcloud is subnet-create \
<TEAM_NAME>-vpe-sn \
<TEAM_NAME>-management-vpc \
--zone us-south-1 \
--ipv4-cidr-block 10.<TEAM_ID_NUMBER>.2.0/24 \
--acl <TEAM_NAME>-management-vpc-default-acl \
--pgw <TEAM_NAME>-pgw-01-pgw \
--rt <TEAM_NAME>-management-vpc-default-rt \
--resource-group-name <TEAM_NAME>-management-rg
```

## Reserved IP addresses

The reserved IPs capability on VPC allows you to reserve IP addresses for use on your resources. You can specify a particular address or allow the system to select any available address. You can also make a new IP reservation with or without a target with which to bind the address.

### Step 1: Reserve subnet IP addresses using the UI

To create a unassociated reserved IP, follow these steps:

1. From the IBM Cloud menu, select **Infrastructure / Network / Subnets**.
2. Select the **subnet**: `<TEAM_NAME>-mgmt-sn`.
3. Click the **Reserved IPs** tab.
4. Click **Create +**.
5. Enter a **name** for your reserved IP: `<TEAM_NAME>-mgmt-01-rip`
6. Select the **address**: `.4`
7. Click **Reserve IP**.

### Step 2: Reserve subnet IP addresses using the UI

For the rest of the reserved IP addresses we will use the CLI:

```bash
ibmcloud is subnet-reserved-ip-create \
<TEAM_NAME>-mgmt-sn \
--vpc <TEAM_NAME>-management-vpc \
--name <TEAM_NAME>-mgmt-02-rip \
--address 10.<TEAM_ID_NUMBER>.1.5 \
--auto-delete false
```

## Create Security Groups

### Step 1: Create a Security Group in the UI

1. Click **Infrastructure / Network / Security groups**.
2. Click **Create** on the security groups list table.
3. Configure as follows:

   * **Geography**: `North America`.
   * **Region**: `us-south`
   * **Name**: `<TEAM_NAME>-mgmt-sg`.
   * **Resource group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt`

4. In **Inbound rules**, click **Create**:

   * **Protocol**: `TCP`
   * **Port min**: `22`
   * **Port max**: `22`
   * **Source type**: CIDR block `0.0.0.0/0`
   * **Destination type**: IP address `10.<TEAM_ID_NUMBER>.1.4`

5. Click **Create**.
6. Repeat with the following:

   * **Protocol**: `TCP`
   * **Port min**: `3389`
   * **Port max**: `3389`
   * **Source type**: CIDR block `10.<TEAM_ID_NUMBER>.0.0/24`
   * **Destination type**: IP address `10.<TEAM_ID_NUMBER>.1.5`

7. In **Outbound rules**, click **Create**:

   * **Protocol**: `ICMP-TCP-UDP`
   * **Port**: `Any`
   * **Source type**: `Any`
   * **Destination type**: `Any`

8. Click **Create**.
9. Click **Create Security group**

### Step 2: Create a Security Group in the CLI

1. Using a terminal session:
   
```bash
ibmcloud is security-group-create \
<TEAM_NAME>-vpn-sg \
<TEAM_NAME>-management-vpc \
--resource-group-name <TEAM_NAME>-management-rg
```

### Step 3: Create a Security Group Rules in the CLI

1. In a terminal session, add an inbound rule:

```bash
ibmcloud is security-group-rule-add \
<TEAM_NAME>-vpn-sg \
inbound \
udp \
--vpc <TEAM_NAME>-management-vpc \
--local 0.0.0.0/0 \
--remote 0.0.0.0/0 \
--port-min 443 \
--port-max 443
```

2. Add an outbound rule:

```bash
ibmcloud is security-group-rule-add \
<TEAM_NAME>-vpn-sg \
outbound \
all \
--remote 0.0.0.0/0
```

3. Repeat to create the security group and rules for the VPE security group:

   * **Security group name**: `<TEAM_NAME>-vpe-sg`
   * **Inbound rule**: 10.<TEAM_ID>.0.0/20, ALL, ANY, ANY
   * **Outbound rule**: 10.<TEAM_ID>.0.0/20, ALL, ANY, ANY

4. Repeat to create the security group and rules for a the NFS security group:

   * **Security group name**: `<TEAM_NAME>-nfs-sg`
   * **Inbound rule**: TCP 2049, any, any
   * **Outbound rule**: 10.<TEAM_ID>.0.0/20, ALL, ANY, ANY

5. In the UI check all security groups and their rules and correct as needed

## Create ACL

This section creates a network access control list with the following rules:

* Inbound Rules:
    * Protocol: All
    * Source: 0.0.0.0/0 (any source)
    * Action: Allow
* Outbound Rules:
    * Protocol: All
    * Destination: 0.0.0.0/0 (any destination)
    * Action: Allow

This configuration:

* Exposes all ports and protocols
* Allows traffic from any source IP
* Should only be used in development/testing environments
* Is not recommended for production workloads

For production environments, consider creating more restrictive rules that only allow the specific protocols, ports, and IP ranges your applications actually need.

### Step 1: Create an ACL

1. In a terminal session:

   ```bash
   # Create the ACL
   ibmcloud is network-acl-create \
   <TEAM_NAME>-mgmt-acl \
   --vpc <TEAM_NAME>-management-vpc \
   --resource-group-name <TEAM_NAME>-management-rg 

   # Add inbound rule to allow all traffic
   ibmcloud is network-acl-rule-add \
   <TEAM_NAME>-mgmt-acl \
   allow \
   inbound \
   all \
   0.0.0.0/0 \
   0.0.0.0/0 \
   --vpc <TEAM_NAME>-management-vpc \
   --name default-inbound-rule

   # Add outbound rule to allow all traffic  
   ibmcloud is network-acl-rule-add \
   <TEAM_NAME>-mgmt-acl \
   allow \
   outbound \
   all \
   0.0.0.0/0 \
   0.0.0.0/0 \
   --vpc <TEAM_NAME>-management-vpc \
   --name default-outbound-rule
   ```

2. Using the UI check everything is expected, if not fix via the UI.

## Create DNS Custom Resolvers

### Step1: Create DNS Custom Resolvers

1. In a terminal session:

   ```bash
   # Install the plugin
   ibmcloud plugin install dns

   # Target the resource group
   ibmcloud target -g <TEAM_NAME>-services-rg

   # Get the ID from the name
   INSTANCE_ID=$(ibmcloud dns instances --output json | jq -r '.[] | select(.name=="<TEAM_NAME>-dns-srv") | .id')
   echo $INSTANCE_ID
   ibmcloud dns instance-target $INSTANCE_ID

   # Get the subnet CRN
   SUBNET_CRN=$(ibmcloud is subnets --resource-group-name <TEAM_NAME>-management-rg --output json | jq -r '.[] | select(.name=="<TEAM_NAME>-vpe-sn") | .crn')
   echo $SUBNET_CRN

   # Create the first resolver
   ibmcloud dns custom-resolver-create \
   --name "<TEAM_NAME>-custom-resolver-1" \
   --description "First custom resolver in VPC subnet" \
   --location $SUBNET_CRN \
   --location $SUBNET_CRN

   # Get the resolver ID
   RESOLVER_ID=$(ibmcloud dns custom-resolvers --output json | jq -r '.[].id' )
   echo $RESOLVER_ID

   # Enable the resolver
   ibmcloud dns custom-resolver-update $RESOLVER_ID --enabled true

   # Get the IP addresses of the resolvers
   ibmcloud dns custom-resolver \
   $RESOLVER_ID \
   --output json | jq -r '.locations.[].dns_server_ip'
   ```

2. Record the IP addresses for use in creating a VPN.

## Create Virtual Network Interfaces

A virtual network interface (VNI) is a logical abstraction of a network interface in a subnet. It can be attached to a target resource, providing that resource with network connectivity. As a top-level resource with a CRN, a VNI's lifecycle is independent of the target resource it is attached to (unless auto_delete is set to true). In addition, it has its own set of IAM permissions. A VNI has the following properties that define networking policies:

* Primary IP and secondary IPs.
* Security groups.
* IP spoofing.
* Infrastructure NAT.
* Protocol state filtering.

### Step 1: Create a VNI in the UI

To create a virtual network interface in the console, follow these steps:

1. Click **Infrastructure > Network > Virtual network interfaces**.
2. On the Virtual network interfaces for VPC page, click **Create**.
3. In the Location section:

   * **Geography**: `North America`
   * **Region**: `us-south`
  
4. In the Details section:

   * **Name**: `<TEAM_NAME>-mgmt-01-vni`.
   * **Resource group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt`.

5. In the Network configuration section, complete the following information:

   * **Virtual private cloud**: `<TEAM_NAME>-management-vpc`.
   * **Subnet**: `<TEAM_NAME>-mgmt-sn`.
   * **Allow IP spoofing**: `Disabled`.
   * **Infrastructure NAT**: `Enabled`.
   * **Protocol state filtering mode**: `Auto`.

6. In the Primary IP section:
   
   * **Reserving method**: `Let me specify` and then select `<TEAM_NAME>-mgmt-01-rip`.
   * **Auto release**: Disabled.

7. In the Floating IPs section, click **Attach**. In the side panel, create a new floating IP with:

   * **Name**: `<TEAM_NAME>-mgmt-fip`.
   * **Resource group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt`

8.  In the Security groups section, select `<TEAM_NAME>-mgmt-sg`.
9.  Review the information in the Summary panel, and click **Create virtual network interface**.

### Step 2: Create VNI in the CLI

For the next VNI we will use the CLI:

1. Using the CLI:

```bash
rip_id=$(ibmcloud is subnet-reserved-ip team1-mgmt-sn team1-mgmt-02-rip --output json | jq -r '.id')
echo $rip_id

ibmcloud is virtual-network-interface-create \
--name <TEAM_NAME>-mgmt-02-vni \
--allow-ip-spoofing false \
--auto-delete false \
--enable-infrastructure-nat true \
--protocol-state-filtering-mode auto \
--rip $rip_id \
--sgs <TEAM_NAME>-mgmt-sg \
--resource-group-name <TEAM_NAME>-management-rg \
--vpc <TEAM_NAME>-management-vpc 
```

#### Notes

1. Disabling IP spoofing allows traffic to pass through the network interface, instead of ending at the network interface.
2. When Infrastructure NAT is disabled, the virtual server instance receives the traffic as it was sent by the peer, without NAT.
3. Protocol state filtering mode when enabled forces the TCP connections to align with the RFC793 standard and any packets to be allowed by corresponding security group rules and network ACLs. When disabled, permits packets to be allowed only by corresponding security group rules and network ACLs.


## Create Virtual Server Instances

### Step 1: Create a VSI in the UI

To create a virtual server instance in the console, follow these steps:

1. In the IBM Cloud console, navigate to **Compute > Virtual server instances**.
2. Click **Create** the enter the following information:

   * **Gepgraphy**: `North America`
   * **Region**: `us-south`
   * **Zone**: `us-south-1`
   * **Name**: `<TEAM_NAME>-mgmt-01-vsi`
   * **Resource group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt` and `backup:yes`

3. Click on **Change image**
4. Scroll down, select **ibm-ubuntu-24-04-2-minimal-amd64-1** and click **Save**.
5. Click on **Change profile**
6. Select **By Scenario** and then select **Web Development and Test**.
7. Click on **bx2-2x8** and then click **Save**.
8. In **SSH keys** select **<TEAM_NAME>-ssh-key-1** and **<TEAM_NAME>-ssh-key-2**.
9. In **VPC** select **<TEAM_NAME>-management-vpc**.
10. In **Network attachments with Virtual network interface**, delete the attachment.
11. Select **Actions / Attach existing**, then select `<TEAM_NAME>-mgmt-01-vni`. Then click **Next** and **Create**
12. In **Advanced options**, select **User data** and paste in the yaml from [mgmt-01-vsi.yaml](Scripts/HOL1/Linux/mgmt-01-vsi.yaml).
13. Click **Create virtual server**

### Step 2: Create a VSI in the CLI

Now we will create a VSI using the CLI.

1. Find the path of the `mgmt-02-vsi.ps1` file e.g. `/Users/neiltaylor/Documents/GitHub/HOL-VPC-PowerVS/Scripts/HOL1/Windows/mgmt-02-vsi.init`
2. In a terminal session:

```bash
ibmcloud is instance-create \
<TEAM_NAME>-mgmt-02-vsi \
<TEAM_NAME>-management-vpc \
us-south-1 \
bx2-2x8 \
<TEAM_NAME>-mgmt-sn \
--pnac-vni <TEAM_NAME>-mgmt-02-vni \
--image ibm-windows-server-2022-full-standard-amd64-25 \
--keys <TEAM_NAME>-ssh-key-1 \
--resource-group-name <TEAM_NAME>-management-rg \
--user-data @<FULL_PATH>/mgmt-02-vsi.init
```

2. Use the following to add a tag to the VSI:

```bash
ibmcloud resource tag-attach --resource-name <TEAM_NAME>-mgmt-02-vsi --tag-names env:mgmt,backup:yes
```

## Questions

Use [IBM Cloud VPC Documents](https://cloud.ibm.com/docs/vpc?topic=vpc-getting-started) to help you answer the following:

1. What is IBM Cloud Virtual Private Cloud (VPC)?
2. What are the essential steps to create and configure an IBM Cloud VPC and its attached resources?
3. Explain the concepts of Regions and Zones in the context of IBM Cloud VPC.
4. What are the characteristics of subnets in a VPC, and can they span multiple zones?
5. How do Security Groups and Network Access Control Lists (ACLs) help secure network traffic in a VPC, and how do they differ?
6. Which of the following cannot span multiple zones?
   a. A VPC. 
   b. A Region
   c. A Subnet. 
   d. A Public Gateway.
7. What are the different types of Virtual Servers available for IBM Cloud VPC?
8. What types of images are available for provisioning virtual servers in VPC?
9. What SSH key types are supported for connecting to virtual server instances in VPC, and are there any restrictions on their usage?
10. What are the limits on the number of network interfaces for IBM Cloud VPC virtual server instances, and how do they relate to the instance's vCPU count?
