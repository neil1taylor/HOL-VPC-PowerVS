# Hands-on Lab 1: Introduction to IBM Cloud VPC

What you will learn:

* Core concepts and architecture of IBM Cloud VPC.
* VPC components: subnets, security groups, ACLs, and virtual server instances.
* VPC management through UI, CLI, and API interfaces.
* Implementing VPC subnets, routing tables, and load balancers.
* Configuring public gateways and floating IP addresses.
* Audit logging and security monitoring in VPC environments.

## Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Resource Groups | <TEAM_NAME>-services-rg | Deployed via UI
Resource Groups | <TEAM_NAME>-management-rg | Deployed via UI
Resource Groups | <TEAM_NAME>-app1-rg | Deployed via CLI
API Key | <TEAM_NAME>-api-key-1 | 
SSH Key | <TEAM_NAME>-ssh-key-1 | Deployed via UI
SSH Key | <TEAM_NAME>-ssh-key-2 | Deployed via CLI
VPC | <TEAM_NAME>-management-vpc | Deployed via UI
VPC | <TEAM_NAME>-app1-vpc | Deployed via CLI
Private DNS Instance | <TEAM_NAME>dns | Deployed via UI
Private DNS Custom Resolvers | |
Load balancer | <TEAM_NAME>alb-public |
Floating IP | <TEAM_NAME>mgmt-fip |
Public Gateway | <TEAM_NAME>pgw-01-pgw | Attach to all VPC subnets
Security Group | <TEAM_NAME>vpn-sg | 
Security Group | <TEAM_NAME>mgmt-sg | 
Security Group | <TEAM_NAME>vpe-sg | 
Security Group | <TEAM_NAME>app1-lb-sg | 
Security Group | <TEAM_NAME>app1-web-sg | 
Security Group | <TEAM_NAME>app1-app-sg | 
Security Group | <TEAM_NAME>app1-db-sg | 
ACL | <TEAM_NAME>mgmt-acl |
ACL | <TEAM_NAME>app1-acl | 
Subnet | <TEAM_NAME>vpn-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.0.0/24
Subnet | <TEAM_NAME>mgmt-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.1.0/24
Subnet | <TEAM_NAME>vpe-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.2.0/24
Subnet | <TEAM_NAME>app1-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.4.0/24
Reserved IP | <TEAM_NAME>mgmt-01-rip | 10.<TEAM_ID_NUMBER>.1.4
Reserved IP | <TEAM_NAME>mgmt-02-rip | 10.<TEAM_ID_NUMBER>.1.5
Reserved IP | <TEAM_NAME>web-01-rip | 10.<TEAM_ID_NUMBER>.4.4
Reserved IP | <TEAM_NAME>app-01-rip | 10.<TEAM_ID_NUMBER>.4.5
Reserved IP | <TEAM_NAME>db-01-rip | 10.<TEAM_ID_NUMBER>.4.6
Virtual Network Interface | <TEAM_NAME>mgmt-01-vni | Attach RIP
Virtual Network Interface | <TEAM_NAME>mgmt-02-vni | Attach RIP
Virtual Network Interface | <TEAM_NAME>web-01-vni | Attach RIP
Virtual Network Interface | <TEAM_NAME>app-01-vni | Attach RIP
Virtual Network Interface | <TEAM_NAME>db-01-vni | Attach RIP
Virtual Server Instance | <TEAM_NAME>mgmt-01-vsi | Ubuntu, attach FIP, attach userdata-mgmt-lin
Virtual Server Instance | <TEAM_NAME>mgmt-02-vsi | Windows, userdata-mgmt-win
Virtual Server Instance | <TEAM_NAME>web-01-vsi | Ubuntu, attach userdata-web
Virtual Server Instance | <TEAM_NAME>app-01-vsi | Ubuntu, attach userdata-app
Virtual Server Instance | <TEAM_NAME>db-01-vsi | Ubuntu, attach userdata-db

This document references:

- `<TEAM_NAME>` this is your team name e.g. `team-1`
- `<TEAM_ID_NUMBER>` this is your team number e.g. `1`

## Create Resource Groups

We will learn how to create Resource Groups using the IBM Cloud UI and CLI.

### Step 1: Create Resource Groups

We will create 3 resource groups. Two using the UI and one with the CLI:

1. Using a browser navigate to https://cloud.ibm.com
2. Log in to IBM Cloud.
3. Go to Manage > Account > Resource Groups.
4. Click Create.
5. Name: `<TEAM_NAME>-services-rg`.
6. Click Create.
7. Repeat for `<TEAM_NAME>-management-rg`.

For the third one we will use the CLI:

1. Open a terminal session.
2. In the terminal session type: `ibmcloud login --sso`
3. Follow the prompts and log on.
4. In the terminal session type: `ibmcloud resource group-create <TEAM_NAME>-app1-rg`
5. In the terminal session type: `ibmcloud resource groups`

## Create and import SSH Keys

We will learn how to create an SSH key pair and import the public key to IBM Cloud

### Step 1: Create an SSH Key pair for participant 1

On the first participant's laptop, if you are using Linux or MacOS, in a terminal session:

`ssh-keygen -b 4096 -t rsa -f ~/.ssh/hol-key -q -N ""`

If you are using Windows, in a PowerShell session:

`ssh-keygen -b 4096 -t rsa -f C:\%USERPROFILE%\.ssh/hol-key -q -N '""'`

On the second participant's laptop, follow step 1 above

### Step 2: Upload the SSH Public Key using the UI

On the first participants laptop, we will upload the first key to IBM Cloud using the UI.

1. In IBM Cloud console, go to **Navigation menu > Infrastructure VPC icon > Compute > SSH keys**.
2. Click **Create** and enter the following information:

   * **Location**: us-south
   * **Name**: <TEAM_NAME>-ssh-key-2
   * **Resource group**: <TEAM_NAME>-management-rg
   * **Tags**: env:mgmt

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
@KEY_FILE ~/.ssh/hol-key.pub \
--resource-group-name <TEAM_NAME>-management-rg
```

Or if using Windows:

```cmd
ibmcloud is key-create \
<TEAM_NAME>-ssh-key-2 \
@KEY_FILE C:\%USERPROFILE%\.ssh/hol-key \
--resource-group-name <TEAM_NAME>-management-rg
```

## Create DNS Instance

## Create VPCs

We will learn how to create VPCs using the IBM Cloud UI and CLI.

By default, each zone of your VPC is assigned a default address prefix that specifies the address range in which subnets are created. As we want to define the IP ranges we will **disable** this behavior.

### Step 1: Create VPCs

The first VPC we will create using the UI.

1. Select the Navigation Menu Menu icon, then click **VPC Infrastructure > VPCs**.
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

### Step 2: 

1. Navigate to **VPC**.
2. Click on `<TEAM_NAME>-management-vpc`.
3. Click on **Address Prefixes**.
4. Click on **Create +**:
5. In the details box:

    * **IP Range**: `10.<TEAM_ID_NUMBER>.0.0/16`
    * **Location**: `us-south-1`

The second VPC we will create using the CLI.

1. In the terminal session type:

```bash
ibmcloud is vpc-create \
<TEAM_NAME>-app1-vpc \
--resource-group-name <TEAM_NAME>-app1-rg 
--region us-south
```

## Create Subnets

Subnets are networks created within a VPC. Subnets are a fundamental mechanism within VPC used to allocate addresses to individual resources (such as Virtual server instances), and enable various controls to these resources through the use of network ACLs, routing tables, resource groups.

Subnets are bound to a single zone; however, they can reach all other subnets within a VPC, across a region. They are created from a larger address space within the VPC called an address prefix; and you can provision multiple subnets per address prefix.

We will learn how to create subnets using the IBM Cloud UI and CLI.

### Step 1: Create subnets using the UI

We will create two subnets using the UI.

1. Click **Infrastructure > Network > Subnets**.
2. Click **Create +**.
3. In the Location section, provide the following information:

   * **Geography**: `North America`
   * **Region**: `us-south`

4. In the Details section, provide the following information:

   - **Name**: `<TEAM_NAME>vpn-sn`t.
   - **Resource group**: `<TEAM_NAME>-management-rg`.
   - **Tags**: `env:mgmt`.
   - **Virtual private cloud**: `<TEAM_NAME>-management-vpc`.
   - **IP range selection**: `10.<TEAM_ID_NUMBER>.0.0/24`.
   - **Routing table**: Select which routing table that you want the new subnet to use.
   - **Subnet access control list**: Select which access control list you want the new subnet to use.
   - **Public gateway**: Indicate whether you want the subnet to communicate with the public internet by toggling the switch to Attached. Attaching a public gateway creates a Floating IP and incurs a cost.

5. Click **Create subnet** to create the subnet.

Follow the steps above using the following:

   - **Name**: `<TEAM_NAME>mgmt-sn`
   - **Resource group**: `<TEAM_NAME>-management-rg`.
   - **Tags**: `env:mgmt`.
   - **Virtual private cloud**: `<TEAM_NAME>-management-vpc`.
   - **IP range selection**: `10.<TEAM_ID_NUMBER>.1.0/24`

### Step 2: Create subnets using the CLI

Now we will use the IBM Cloud CLI.

1. In a terminal session:

```bash
ibmcloud is subnet-create \
<TEAM_NAME>vpe-sn \
<TEAM_NAME>-management-vpc \
--zone us-south-1 \
--ipv4-cidr-block 10.<TEAM_ID_NUMBER>.2.0/24 \
--acl ACL \ <TBD>
--pgw PGW \ <TBD>
--rt RT \ <TBD>
--resource-group-name <TEAM_NAME>-management-rg
```

Follow the steps above using the following:

   - **Name**: `<TEAM_NAME>app1-sn`
   - **Resource group**: `<TEAM_NAME>-app1-rg `.
   - **Tags**: `env:app`.
   - **Virtual private cloud**: `<TEAM_NAME>-app1-vpc`.
   - **IP range selection**: `10.<TEAM_ID_NUMBER>.4.0/24`

## Create a public gateway

A public gateway enables a subnet and all its attached virtual server instances to connect to the internet. By default, subnets do not have access to the public internet. After a subnet is attached to a public gateway, all instances in that subnet can connect to the internet.

We will learn how to create a public gateway using the IBM Cloud UI.

### Step 1: Create a Public Gateway

1. Click Infrastructure > Network > Public gateways.
2. Click Create.
3. In the Edit location, enter values for the following fields:

   * **Geography**: `North America`
   * **Region**: `us-south`

4. Enter values for the following fields under details:

   * Public gateway name - `<TEAM_NAME>pgw-01-pgw`.
   * Resource group - `<TEAM_NAME>-Management`.
   * VPC - `<TEAM_NAME>-management-vpc`.
   * Tags - `env:mgmt`.

5. Click Create.

## Reserve IP addresses

The reserved IPs capability on VPC allows you to reserve IP addresses for use on your resources. You can specify a particular address or allow the system to select any available address. You can also make a new IP reservation with or without a target with which to bind the address.

### Step 1: Reserve subnet IP addresses using the UI

To create a unassociated reserved IP, follow these steps:

1. From the IBM Cloud menu, select **Infrastructure > Network > Subnets**.
2. Select the **subnet**: `<TEAM_NAME>mgmt-sn`.
3. Click the **Reserved IPs** tab.
4. Click **Create +**.
5. Enter a **name** for your reserved IP: `<TEAM_NAME>mgmt-01-rip`
6. Select the **address**: `.4`
7. Click **Reserve IP**.

Follow the steps above using the following:

* **subnet**: `<TEAM_NAME>mgmt-sn`.
* **name**: `<TEAM_NAME>mgmt-02-rip`.
* **address**: `.5`

### Step 2: Reserve subnet IP addresses using the UI

For the rest of the reserved IP addresses we will use the CLI:

```bash
ibmcloud is subnet-reserved-ip-create \
<TEAM_NAME>mgmt-sn \
--vpc <TEAM_NAME>-app1-vpc \
--name <TEAM_NAME>web-01-rip \
--address 10.<TEAM_ID_NUMBER>.4.4 \
--auto-delete false
```

Follow the steps above using the following:

* **name**: `<TEAM_NAME>web-01-rip`.
* **address**: `.5`

Follow the steps above using the following:

* **name**: `<TEAM_NAME>app-01-rip`.
* **address**: `.6`

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

   * **Name**: `<TEAM_NAME>mgmt-01-vni`.
   * **Resource group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt`.

5. In the Network configuration section, complete the following information:

   * **Virtual private cloud**: `<TEAM_NAME>-management-vpc`.
   * **Subnet**: `<TEAM_NAME>mgmt-sn`.
   * **Allow IP spoofing**: Disabled.
   * **Infrastructure NAT**: Enabled.
   * **Protocol state filtering mode**: Auto.

6. In the Security groups section, select `<TEAM_NAME>mgmt-sg`.
7. In the Primary IP section:
   
   * **Reserving method**: `<TEAM_NAME>mgmt-01-rip`.
   * **Auto release**: Disabled.

8. In the Floating IPs section, click **Attach**. In the side panel, select: `<TEAM_NAME>mgmt-fip`.
9. Review the information in the Summary panel, and click **Create virtual network interface**.

### Step 2: Create other VNI in the UI

For the next VNI we will use the CLI:

1. Using the CLI

```bash
ibmcloud is virtual-network-interface-create \
--name <TEAM_NAME>mgmt-02-vni \
--allow-ip-spoofing false \
--auto-delete false \
--enable-infrastructure-nat true \
--protocol-state-filtering-mode auto \
--rip-name <TEAM_NAME>mgmt-02-rip \
--subnet <TEAM_NAME>mgmt-sn \
--sgs <TEAM_NAME>mgmt-sg \
--resource-group-name <TEAM_NAME>-management-rg \
--vpc <TEAM_NAME>-management-vpc 
```

### Step 2: Create the other VNIs with a script

For the other VNIs we will a script:

#### Notes

1. Disabling IP spoofing allows traffic to pass through the network interface, instead of ending at the network interface.
2. When Infrastructure NAT is disabled, the virtual server instance receives the traffic as it was sent by the peer, without NAT.
3. Protocol state filtering mode when enabled forces the TCP connections to align with the RFC793 standard and any packets to be allowed by corresponding security group rules and network ACLs. When disabled, permits packets to be allowed only by corresponding security group rules and network ACLs.
