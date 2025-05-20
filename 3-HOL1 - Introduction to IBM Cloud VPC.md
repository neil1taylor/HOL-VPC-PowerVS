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
VPC | <TEAM_NAME>-management-vpc | Deployed via UI
VPC | <TEAM_NAME>-app1-vpc | Deployed via CLI
SSH Key | <TEAM_NAME>key1 | Deployed via UI
SSH Key | <TEAM_NAME>key2 | Deployed via UI
Private DNS Instance | <TEAM_NAME>dns | Deployed via UI
Private DNS Custom Resolvers | |
Load balancer | <TEAM_NAME>alb-public |
Floating IP | <TEAM_NAME>mgmt-fip |
Public Gateway | <TEAM_NAME>pgw-01-pgw | Attach to all VPC subnets
Subnets | <TEAM_NAME>vpn-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.0.0/24
Subnets | <TEAM_NAME>mgmt-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.1.0/24
Subnets | <TEAM_NAME>vpe-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.2.0/24
Subnets | <TEAM_NAME>app1-sn | Attach PGW, 10.<TEAM_ID_NUMBER>.4.0/24
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

## Create VPCs

We will learn how to create VPCs using the IBM Cloud UI and CLI.

By default, each zone of your VPC is assigned a default address prefix that specifies the address range in which subnets are created. As we want to define the IP ranges we will disable this behavior.

### Step 1: Create VPCs

The first VPC we will create using the UI.

1. Select the Navigation Menu Menu icon, then click VPC Infrastructure > VPCs.
2. Click Create.
3. In the Location section, provide the following information:

   * **Geography**: `North America`
   * **Region**: `us-south`
  
4. In the Details section, provide the following information:
   * **Name**: `<TEAM_NAME>-management-vpc`
   * **Resource Group**: `<TEAM_NAME>-management-rg`.
   * **Tags**: `env:mgmt`.
5. Uncheck the `Create a default prefix for each zone`.
6. Click Create.

### Step 2: 

1. Navigate to VPC.
2. Click on `<TEAM_NAME>-management-vpc`.
3. Click on Address Prefixes.
4. Clcik on Create:
5. In the details box?l
    * **IP Range**: `10.<TEAM_ID_NUMBER>.0.0/16`
    * **Location**: `us-south-1`

The second VPC we will create using the CLI.

1. In the terminal session type: `ibmcloud is vpc-create <TEAM_NAME>-app1-vpc --resource-group-name <TEAM_NAME>-app1-rg --region us-south`

## Create Subnets

Subnets are networks created within a VPC. Subnets are a fundamental mechanism within VPC used to allocate addresses to individual resources (such as Virtual server instances), and enable various controls to these resources through the use of network ACLs, routing tables, resource groups.

Subnets are bound to a single zone; however, they can reach all other subnets within a VPC, across a region. They are created from a larger address space within the VPC called an address prefix; and you can provision multiple subnets per address prefix.

We will learn how to create subnets using the IBM Cloud UI and CLI.

### Step 1: Create subnets using the UI

We will create two subnets using the UI.

1. Click **Infrastructure > Network > Subnets**.
2. Click Create.
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

Now we will use the IBM Cloud CLI

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

   * **Name**: Enter a unique name for the virtual network interface, such as my-virtual-network-interface.
   * **Resource group**: Select a resource group for the virtual network interface.
   * **Tags**: (optional) Add tags to help you organize and find your resources. You can add more tags later. For more information, see Working with tags.

In the Network configuration section, complete the following information:

Virtual private cloud: Select the VPC in which you want to create your virtual network interface. If you need to create a VPC, click Create VPC.
Subnet: Select a subnet in which to create the virtual network interface. If you need to create a subnet, click Create.
Allow IP spoofing: Select the switch to enable or disable IP spoofing.

Disabling IP spoofing allows traffic to pass through the network interface, instead of ending at the network interface.
IP spoofing supports only virtual server instances and bare metal servers. File shares are not supported.
Infrastructure NAT: Select the switch to enable or disable infrastructure NAT.

Note: Infrastructure NAT is enabled when IP spoofing is enabled.

Enabled includes one floating IP address, and supports virtual servers, bare metal servers, and file shares.
Disabled supports multiple floating IP addresses only on bare metal servers. Virtual servers and file shares as virtual network interface targets are not supported.

When disabled, the virtual server instance receives the traffic as it was sent by the peer, without NAT. The destination IP address is the floating IP address, and the bare metal server is responsible for performing the NAT.

Protocol state filtering mode: Select a radio button to set the mode:

Auto (default): Filtering is enabled or disabled based on the virtual network interface's target resource.

Bare metal server (Disabled)
Virtual server instance (Enabled)
File share mount (Enabled)
Enabled: Forces the TCP connections to align with the RFC793 standard and any packets to be allowed by corresponding security group rules and network ACLs.
Disabled: Permits packets to be allowed only by corresponding security group rules and network ACLs.
In the Primary IP section, make the following selections.

Reserving method: Select whether you want a primary IP address created for you, or if you want to specify one manually. If you specify your own, type an existing reserved IP address for your virtual network interface, or select one from the existing reserved IP list menu.
Auto release: Click the switch to enable or disable auto release for this virtual network interface.
In the Floating IPs section (optional), click Attach. In the side panel that appears, you can either select from the existing list of floating IP addresses, or select Reserve new Floating IP and complete the information that is requested.

Note: If a floating IP is attached, the virtual network interface will not be accepted as file share mount target. If infrastructure NAT is enabled, at most one floating IP can be attached.

In the Secondary IP section (optional), click Attach. Select a reserving method, and specify whether auto release is enabled.

Note: A virtual network interface with secondary IPs attached cannot be accepted as a file share mount target.

In the Security groups section, select at least one and at most five security groups to control traffic at the networking level. You can select security groups from the list, or create one by clicking Create. For more information about creating a security group, see Creating security groups.
Review the information in the Summary panel, and click Create virtual network interface.


