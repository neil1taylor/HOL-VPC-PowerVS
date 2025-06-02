# HOL7 - Automation and Infrastructure as Code

## Overview

This Hands on Lab, uses a Terraform script for provisioning infrastructure in IBM Cloud. It provisions:

* VPC with three subnets (web, app, database tiers)
* Custom Route Tables for app and database tiers
* Security Groups with tier-appropriate rules
* Virtual Server Instances with role-specific configurations
* Public Gateway and Floating IP for web access

The custom routing logic is as follows:

* App Tier Routes: Can access database and web tiers, has internet access
* Database Tier Routes: Can respond to app tier, internet access blocked
* Web Tier: Uses default routing (can access app tier)

The userdata scripts:

* User-data scripts that install and configure services on each tier
* Built-in connectivity testing scripts on each server
* Web interface showing routing status
* API endpoints for programmatic testing


## Architecture

```
Internet
    |
[Public Gateway]
    |
┌─────────────────────────────────────────────────────────┐
│                          VPC                            │
│                                                         │
│  Web Subnet                   App Subnet                │
│  ┌─────────────────────┐      ┌──────────────────────┐  │
│  │   Web Server        │      │   App Server         │  │
│  │   - Nginx           │ ───→ │   - Node.js          │  │
│  │   - Public IP       │      │   - Custom Routes    │  │
│  │   - Default Routes  │      │   - Route Table A    │  │
│  └─────────────────────┘      └──────────────────────┘  │
│                                           │             │
│                                           ▼             │
│                               DB Subnet                 │
│                               ┌──────────────────────┐  │
│                               │   Database Server    │  │
│                               │   - MySQL            │  │
│                               │   - Internet Blocked │  │
│                               │   - Route Table B    │  │
│                               └──────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Custom Routing

By default, all subnets in a VPC can communicate freely with each other. Traffic follows the VPC's default route table with basic internet and inter-subnet routing. The default routing table provides no granular control over traffic paths or access restrictions. Security relies heavily on security groups and network access control lists, which operate at different network layers

In our scenario, without custom routes:

Traffic Flow | Allowed/Blocked | Notes
---|---|---
App → Database | Allowed ✓ |
Web → Database | Allowed ✗ | SECURITY RISK
Internet → Database | Blocked by default ✓ |

In our scenario, with custom routes:
Traffic Flow | Allowed/Blocked | Notes
---|---|---
App → Database | Explicitly allowed ✓ | 
Web → Database | Explicitly denied ✓ | 
Database → Internet | Explicitly blocked ✓ | 

Why this matters:

* **Principle of Least Privilege**: Database should only be accessible from application tier
* **Defense in Depth**: Multiple security layers beyond just security groups
* **Compliance**: Many regulations (PCI DSS, HIPAA, SOX) require network segmentation
* **Blast Radius Reduction**: If web tier is compromised, database remains isolated

Why not just use security groups:

| Control Method | Layer | Granularity | Use Case |
|----------------|-------|-------------|----------|
| Security Groups | Instance/Interface | Port/Protocol | Application-level access |
| Route Tables | Subnet/Network | Destination-based | Network-level traffic flow |
| NACLs | Subnet | Stateless rules | Subnet boundary protection |

Using this combined approach:

1. Route Tables: Control WHERE traffic can go
2. Security Groups: Control WHAT traffic is allowed
3. NACLs: Provide backup subnet-level protection

Custom route tables aren't just about routing - they're about implementing a **software-defined network architecture** that gives you precise control over security, performance, compliance, and operational requirements that can't be achieved with default VPC routing alone.


## Simple three-tier application

This HOL deploys a simple three-tier application that is deployed via cloud-init scripts on IBM Cloud VPC. This approach allows an automated deployment when the Virtual Server Instances are instantiated. The three-tier application has the following tiers:

1. **Web Tier (Frontend)**:
   - Nginx web server hosting a responsive HTML/JavaScript frontend
   - Automatic health checks for all three tiers
   - Simple UI for testing database operations

2. **Application Tier (Backend)**:
   - Node.js Express server providing RESTful API endpoints
   - Health check endpoints for both app and database connectivity
   - API endpoints for creating and retrieving test records

3. **Database Tier**:
   - PostgreSQL database configured for remote access
   - Sample table structure for testing

See [] for further her details

## Resources created in the HOL

The script includes all the following resources:

1. **Resource Group**: `team-1--app1-rg`
2. **VPC**: `team-1-app1-vpc`
3. **Public Gateway**: `team-1-pgw-02-pgw`
4. **Security Groups**:
   - `team-1-app1-lb-sg`
   - `team-1-app1-web-sg`
   - `team-1-app1-app-sg`
   - `team-1-app1-db-sg`
5. **ACL**: `team-1-app1-acl`
6. **Subnet**: 
   - `team-1-app1-web-sn` with CIDR `10.1.4.0/26` and attached public gateway
   - `team-1-app1-app-sn` with CIDR `10.1.4.64/26` and attached public gateway
   - `team-1-app1-db--sn` with CIDR `10.1.4.128/26` and attached public gateway
7. **Reserved IPs**:
   - `team-1-vnf-01-rip` (10.1.4.4)
   - `team-1-web-01-rip` (10.1.4.5)
   - `team-1-app-01-rip` (10.1.4.69)
   - `team-1-db-01-rip` (10.1.4.133)
8. **Virtual Network Interfaces** attached to their respective reserved IPs:
   - `team-1-vnf-01-vni`
   - `team-1-web-01-vni`
   - `team-1-app-01-vni`
   - `team-1-db-01-vni`
9.  **Virtual Server Instances** with appropriate userdata scripts:
   - `team-1-vnf-01-vsi` (bastion host and NAT router)
   - `team-1-web-01-vsi` (web server with Nginx)
   - `team-1-app-01-vsi` (application server with Java)
   - `team-1-db-01-vsi` (database server with MySQL)

## Terraform

The terraform scripts provisions all the required resources and provisions the Virtual Server instances with cloud-init userdata scripts that will automatically install and configure the appropriate software for each server type when they're provisioned. The Terraform configuration is in the following files:

1. **main.tf** - Contains all the resource definitions, referencing variables in variables.tf
2. **variables.tf** - Declares all the variables used in the configuration
3. **terraform.tfvars** - Contains all the parameter values for the variables
4. **User Data** - This directory contains the e userdata scripts for the VSIs:
   * vnf_user_data.yaml: Cloud-init configuration for virtual network functions (VNF) VSI
   * web_user_data.yaml: Cloud-init configuration for web tier VSI
   * app_user_data.yaml: Cloud-init configuration for application tier VSI
   * db_user_data.yaml: Cloud-init configuration for database tier VSI
5. **Scripts** - This directory contains the scripts that installs and configures the software in each tier th:
   * web-tier.sh: The main script for setting up the web tier
   * app-tier.sh: The main script for setting up the application tier
   * db-tier.sh: The main script for setting up the database tier

The directory structure is described below:

```
simple-three-tier-app/
└── terraform
│  ├── main.tf                 # Main Terraform configuration
│  ├── variables.tf            # Variable declarations
│  ├── terraform.tfvars        # Variable values
│  └── userdata/
│  │   ├── web_user_data.sh    # User data script for web server
│  │   ├── app_user_data.sh    # User data script for app server
│  │   └── db_user_data.sh     # User data script for database server
│  └── scripts/
│      ├── web-tier-init.sh    # Configures the web server
│      ├── app-tier-init.sh    # Configures the app server
│      └── db-tier-init.sh     # Configures the database server
└── ansible/
    ├── configure_app.yaml
    └── configure_web.yaml
```

The high level instructions are as follows:

- Step 1: Create a workspace in IBM Schematics
- Step 2: Configure the variables
- Step 3: Generate and apply the plan
- Step 4: Access Your Resources:
   - After deploying all three tiers, you'll need to update the configuration with the correct IP addresses:
      1. SSH into the web tier VSI and run `sudo /opt/deployment/scripts/update-backend-url.sh <app-tier-private-ip>`
      2. SSH into the application tier VSI and run:
         * `sudo /opt/deployment/scripts/update-db-url.sh <db-tier-private-ip>`
         * `sudo systemctl restart app-server`

### Step 1: Create a Workspace in IBM Schematics

1. Log in to the IBM Cloud console.
2. Navigate to **Menu** -> **Platform Automation** -> **Schematics** -> **Terraform**.
3. Click **Create workspace**.
4. In the **Specify template** section:
   * **GitHub, GitLab or Bitbucket**: `https://github.com/neil1taylor/simple-three-tier-app.git`
   * **Folder**: `terraform`
5. Click **Next**.
6. In the **workspace details** section:
   - **Workspave name**:  `<TEAM_ID>-app1`
   - **Tags**: `env:app1`
   - **Resource group**: `<TEAM_NAME>-management-rg`. This is the resource group where you want to create the workspace
   - **Location**: `Dallas`
   - **Description**: `HOL`
7. Click **Next**.
8. Click **Create**.

### Step 2: Configure Variables

1. After creating the workspace, navigate to the **Variables** tab.
2. Schematics will automatically import variables from your `variables.tf` file.
3. Verify the variable values.
4. Ensure you change the `team_number` to match your <TEAM_NUMBER>

### Step 3: Generate and Apply the Plan

1. Navigate to the **Generate plan** button.
2. Click it to create a Terraform execution plan.
3. Review the plan to ensure everything looks correct.
4. If satisfied, click **Apply plan** to provision the infrastructure.
5. Monitor the progress of the operation in the Activity section.

### Step 4: Create a connection to the App1 VPC

1. Use the instructions at [Adding a connection](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-adding-connections&interface=cli) to connect the <TEAM_NAME>-app1-vpc VPC. Use the connection name `app1-vpc`.

### Step 5: Access Your Resources

1. Once the deployment is complete, navigate to the **Resources** tab to see the provisioned infrastructure.
2. You can also go to the IBM Cloud dashboard to view and manage your newly created resources.

ADD ANSIBLE HERE





## Additional Information

### Important Considerations for IBM Schematics

1. **File Access**: IBM Schematics executes in a containerized environment which may have limitations accessing files. Ensure the user data scripts are properly referenced.
2. **Resource Naming**: Make sure the resource names comply with IBM Cloud naming conventions.
3. **API Key**: IBM Schematics will use your IBM Cloud API key automatically, so you don't need to include it in your configuration.
4. **State Management**: Schematics manages the Terraform state for you, so you don't need to configure remote state storage.
5. **Script Files**: When using `file()` function in Terraform, ensure the paths are relative to the root of your project directory.
6. **Resource Cleanup**: To delete all resources, use the **Destroy resources** action in the Schematics workspace.

### Troubleshooting

- **Missing Scripts**: If you get errors about missing user data files, check the file paths in `terraform.tfvars` and verify the scripts are in the correct location.
- **SSH Key Issues**: If VM creation fails due to SSH key errors, ensure your key exists in IBM Cloud and the name matches exactly in `terraform.tfvars`.
- **Permission Errors**: If you encounter permission issues, verify your IBM Cloud user has the necessary IAM permissions to create all resources.
- **Network Conflicts**: If there are CIDR or IP conflicts, adjust the values in `terraform.tfvars` accordingly.
- **Quota Limits**: Ensure your account has sufficient quota to create all the specified resources.
