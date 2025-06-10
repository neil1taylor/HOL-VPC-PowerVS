# Hands-on Lab 4: Introduction to IBM PowerVS (60 mins)

What you will learn:

* PowerVS fundamentals and service architecture.
* Virtual service instance deployment on PowerVS.
* PowerVS storage volume management.
* PowerVS management using console, CLI, and API interfaces.

## Overview

PowerVS workspaces are region-specific containers for all your Power Virtual Server resources. In this Hands on Lab (HOL) we will create a PowerVS virtual server instance, on a private network, protected by a network security group. The VSI will be connected to a public network initially so that it can install a postgres database via cloud-init.

## Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Power Workspace | <TEAM_NAME>-powervs-wksp
Private Subnet | <TEAM_NAME>-power-db-sn
PowerVS VSI | <TEAM_NAME>db-powervs-vsi

This document references:

- `<TEAM_NAME>` this is your team name e.g. `team-1`
- `<TEAM_ID_NUMBER>` this is your team number e.g. `1`

## Scenario

In this HOL we will:

* Deploy PowerVS resources:
    * Step 1: Create PowerVS Workspace
    * Step 2: Verify SSH Key
    * Step 3: Set Up Networks
    * Step 4: Deploy Virtual Server Instance (VSI)
    * Step 5: Configure Network Security groups

## Deploy PowerVS resources

### Step 1: Create PowerVS Workspace

1. Create a PowerVS workspace that will contain all your Power Virtual Server resources. Follow the instructions at[Creating a Power Virtual Server workspace](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-creating-power-virtual-server#creating-service) using the following parameters:

   - **Location type**: `IBM datacenter`
   - **Location**: Dallas (us-south)
   - **Workspace name**: <TEAM_NAME>-powervs-wksp
   - **Resource group**: <TEAM_NAME>-management-rg
   - **User tags**: `env:mgmt`

### Step 2: Verify SSH Key

1. From the newly created workspace, navigate to **SSH Keys** and ensure yor SSH keys are listed. If not then paste your public key into the text box that you created in HOL1

### Step 3: Set Up Networks

1. Follow the instructions at [Configuring a private network subnet](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-configuring-subnet) to create a private subnet using the following parameters:
   
   - **Network name**: <TEAM_NAME>-power-db-sn
   - **CIDR**: 10.<TEAM_NUMBER>.8.0/24
   - **Gateway**: 10.<TEAM_NUMBER>.8.1
   - **DNS servers**: Use one of the IP addresses from your private DNS custom resolvers
   - **MTU**: 9000

2. To verify use the following commands:

```bash
# Install the plugin
ibmcloud plugin install pi -f

# Get the ID of the workspace we created
workspaceID=`ibmcloud pi workspace ls 2>&1 | grep <TEAM_NAME>-powervs-wksp | awk '{print $NF}'`

# Target the workspace
ibmcloud pi workspace target $workspaceID

# Get the ID of the subnet
subnetID=$(ibmcloud pi subnet list --json | jq -r ' .networks.[] | select(.name=="<TEAM_Name>-power-db-sn") | .networkID')

# Get info on the subnet
ibmcloud pi subnet get $subnetID
```

### Step 4: Deploy Virtual Server Instance (VSI)

1. Follow the documentation at [Creating a Power Systems Virtual Server](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-creating-power-virtual-server) with the following parameters: 

   - **Instance name**: `<TEAM_NAME>-db-powervs-vsi`
   - **User tags**: `env:app1`
   - **Virtual server pinning**: `none`
   - **SSH key**: `<TEAM_NAME>-ssh-key-1`
   - **Operating system**: `IBM provides subscription - Linux`
   - **Image**: `RHEL9-SP4`
   - **Tier**: `Tier 3`
   - **Machine Type**: `s922`
   - **Core type**: `Shared uncapped`
   - **Profile**: `System configuration`
   - **Cores**: `0.25`
   - **Memory**: `2`
   - **Public networks**: `Disable`
   - **Network**: `<TEAM_NAME>-power-db-sn`
   - **IP Address**: `10.<TEAM_ID>.8.2`

2. To verify use the following commands:
 
```bash
# Get instance ID
instanceID=$(ibmcloud pi instance list --json | jq -r '.pvmInstances.[] | select(.name=="<TEAM_NAME>-db-powervs-vsi") | .id')
ibmcloud pi instance get $instanceID
```

### Step 5: Configure Network Security groups

Network Security groups enablement and configuration takes a little while, please be patient at each step and ensure the step completes before moving on to the next.

1. Follow the instructions at [Enabling or disabling NSG in a workspace](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-nsg#enable-disable-nsg)
2. Follow the instructions at [Network security groups](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-nsg) to enable Network Security groups using the following parameters:

    - **Network address groups**:
      - **Name**: `mgmt-servers`
      - **CIDR**: `10.<TEAM_NUMBER>.1.0/24`
      - **Name**: `vpn-subnet`
      - **CIDR**: `10.<TEAM_NUMBER>.0.0/24`
      - **Name**: `vpe-subnet`
      - **CIDR**: `10.<TEAM_NUMBER>.2.0/24`
      - **Name**: `app1-app-sn`
      - **CIDR**: `10.<TEAM_NUMBER>.4.64/26`
    - **Network security groups**:
      - **Name**: `allow-nsg` 
      - **Inbound rules**:
        - **Any**:
          - **Action**: `Allow`
          - **Protocol**: `Any`
          - **Remote**:` mgmt-servers`
        - **TCP**:
          - **Action**: `Allow`
          - **Protocol**: `Any`
          - **Remote**: `app1-app-sn`
          - **Destination port range**: `5432-5432`
      - **Members**: `<TEAM_NAME>db-powervs-vsi`

## Questions

1. What is IBM Power Virtual Server in an IBM data centre?
   A. A physical server deployed in minutes.
   B. A virtual server (LPAR) offering flexible, secure, and scalable compute capacity for Power enterprise workloads.
   C. A cloud-native application platform.
   D. A service exclusively for SAP HANA workloads.
2. What is the primary function of Network Security Groups (NSGs) in an IBM Power Virtual Server workspace within an IBM data centre?
3. What is the default high availability solution supported by Power Virtual Server in IBM data centres?
4. Does IBM provide maintenance for the AIX, IBM i, or Linux operating systems running on Power Virtual Server in IBM data centres? If not, whose responsibility, is it?
5. Which IBM Cloud service can be integrated with Power Virtual Server to centrally manage an organization's security, risk, and compliance with regulatory standards and industry benchmarks?
    A. IBM Cloud Object Storage
    B. IBM Cloud Monitoring
    C. IBM Cloud Security and Compliance Center Workload Protection
    D. IBM Cloud IAM
6. What is a Power Edge Router (PER) in the context of Power Virtual Server in IBM data centres, and what are two key benefits of using a PER-enabled workspace?
7. Detail the various storage tiers available in IBM Power Virtual Server and their corresponding IOPS performance. What crucial consideration should be made when selecting a storage tier for production workloads?
8. Describe the architectural role and key benefits of Shared Processor Pools (SPPs) in Power Virtual Server.
9. How is virtual LAN (VLAN) isolation enforced between different tenants within the IBM Power Virtual Server infrastructure in IBM data centres?
10. How can a public network be added or removed from a Power Virtual Server instance in an IBM data centre, and what are the implications of toggling its status?
