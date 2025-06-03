# Hands-on Lab 3: Storage Solutions in IBM Cloud VPC

What you will learn:

* Block storage provisioning and management in VPC.
* File and object storage integration with VPC resources.
* Storage performance tiers and optimization strategies.
* Snapshot and backup implementation for VPC storage.
* VPC encryption options and key management.

## Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Key Protect | <TEAM_NAME>-kms-svc |
Root key | <TEAM_NAME>-root-key |
Block Storage Volume | <TEAM_NAME>-data-disk-01
NFS Share  | <TEAM_NAME>-nfs-01
Mount Target | <TEAM_NAME>-nfs-mnt-01
Virtual Network Interface | <TEAM_NAME>-nfs-mnt-01-vni
Object Storage instance | <TEAM_NAME>-object-svc 
Object Storage Bucket | <TEAM_NAME>-bucket-01 

## Scenario

In this HOL we will:

* Create a Key Protect instance to manage crytpo keys that we will use to encrypt the storage we will provision:
    * Step 1: Create a Key Protect service instance
    * Step 2: Generate a customer root key (CRK) for encryption
    * Step 3: Configure IAM service-to-service authorization between VPC Infrastructure and Key Protect
* Create block storage data disk and add it to the Windows management server:
    * Step 1: Create a new block storage volume with customer-managed encryption using your Key Protect key
    * Step 2: Attach the block storage volume to the Windows VSI
    * Step 3: Configure Storage in Windows OS
* Create an NFS share and access it from the Linux management server.
    * Step 1: Establishing service-to-service authorizations for File Storage for VPC
    * Step 2: Creating the NFS Share
    * Step 3: Configuring Ubuntu VSI for NFS
* Create a Cloud Object Storage (COS) instance and bucket.
    * Step 1: Creating a service instance
    * Step 2: Create a new bucket and associate the key with it
    * Step 3: Create Service credentials with HMAC
    * Step 4: Using the rclone client
* Take a backup of the Windows and Linux servers.

## Key Protect

### Step1: Create a Key Protect service instance

1. Follow the instructions at [Creating an instance](https://cloud.ibm.com/docs/key-protect?topic=key-protect-provision) to create a Key Protect instance with the following parameters, using the UI or CLI:

    * **Location**: us-south
    * **Plan**: standard
    * **Service name**: <TEAM_NAME>-kms-svc
    * **Resource group**: <TEAM_NAME>-services-rg
    * **Tags**: `env:mgmt`
    * **Allowed network policy**: Private

### Step 2: Generate a customer root key (CRK) for encryption

1. Follow the instructions at [Creating root keys](https://cloud.ibm.com/docs/key-protect?topic=key-protect-create-root-keys&interface=ui) to create a root key with the following parameters using the UI:

    * **Type**:  Root key
    * **Key name**: <TEAM_NAME>-root-key

### Step 3: Configure IAM service-to-service authorization between VPC Infrastructure and Key Protect

1. Follow the instructions at [Establishing service-to-service authorizations for Block Storage for VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-block-s2s-auth&interface=ui). You only need to follow **Creating service-to-service authorization for customer-managed encryption in the console** or **Creating service-to-service authorization for customer-managed encryption from the CLI**

## Create block storage data disk and add it to the Windows management server

### Step 1: Create a new block storage volume with customer-managed encryption using your Key Protect key 

1. Follow the instructions at [Creating Block Storage volumes with customer-managed encryption](https://cloud.ibm.com/docs/vpc?topic=vpc-block-storage-vpc-encryption&interface=ui) with the following parameters, using the UI or CLI. Only follow the instructions in the section **Creating data volumes with customer-managed encryption in the console** or **Creating data volumes with customer-managed encryption from the CLI**

    * **Geography**: North America
    * **Region**: us-south
    * **Zone**: us-south-1
    * **Resource group**: <TEAM_NAME>-management-rg
    * **Tags**: env:mgmt, backup:yes
    * **Attach to existing server**: <TEAM_NAME>-mgmt-02-vsi
    * **IOPS Tiers**: 3 IOPS/GB
    * **Storage size (GB)**: 100
    * **Encryption at rest**: Key protect
    * **Data encryption instance**: <TEAM_NAME>-kms-svc
    * **Data encryption key**: <TEAM_NAME>-root-key 

### Step2: Attach Block Storage to Windows VSI

1. Connect the encrypted volume to your Windows instance by following the instructions at [Attaching a Block Storage for VPC volume](https://cloud.ibm.com/docs/vpc?topic=vpc-attaching-block-storage). 

### Step 3: Configure Storage in Windows OS

Next we need to format and mount the new disk within the Windows operating system. This involves:

* Connect to Windows VSI via RDP.
* Use Windows Disk Management to initialize the new disk
* Create partitions and format with desired file system
* Assign drive letter and configure as needed

1. Follow the instructions at [Setting up your Block Storage for VPC data volume for use (Windows)](https://cloud.ibm.com/docs/vpc?topic=vpc-start-using-your-block-storage-data-volume-win)

## Create an NFS share and access it from the Linux management server

### Step 1: Establishing service-to-service authorizations for File Storage for VPC

Follow the instructions at [Establishing service-to-service authorizations for File Storage for VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-file-s2s-auth&interface=ui). Only follow **Creating authorization for customer-managed encryption in the console** or **Creating authorization for customer-managed encryption from the CLI**

### Step 2: Creating the NFS Share

1. Follow the instructions at [Creating File Shares](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create) using the following parameters:

   * **Geography**: `North America`
   * **Region**: `us-south`
   * **Zone**: `us-south-1`
   * **Name**: <TEAM_NAME>-nfs-01
   * **Tags**: `env:mgmt`
   * **Resource group**: <TEAM_NAME>-management-rg
   * **Profile**: `dp2`
   * **Size**: `20`
   * **IOPS**: `100`
   * **Mount target access mode**: `Security Group`
   * **Allowed transit encryption modes**: `none`
   * **Mount target name**: <TEAM_NAME>-nfs-mnt-01
   * **VPC**: <TEAM_NAME>-management-vpc 
   * **Virtual network interface name**: <TEAM_NAME>-nfs-mnt-01-vni
   * **Subnet**: <TEAM_NAME>-mgmt-sn
   * **Security groups**: <TEAM_NAME>-nfs-sg
   * **Encryption at rest**: Key protect
   * **Data encryption instance**: <TEAM_NAME>-kms-svc
   * **Data encryption key**: <TEAM_NAME>-root-key 

### Step 3: Configuring Ubuntu VSI for NFS

1. Follow the instructions at [Mounting file shares on Ubuntu](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-mount-ubuntu&interface=ui)

## Create an Cloud Object Storage bucket and access it from the Linux management server

### Step 1: Creating a service instance

1. Navigate to the catalog, by clicking **Catalog** in the top navigation bar.
2. In the left menu, click the **Storage** category. Click the **Object Storage** tile.
3. On the order page:
   
   * **Plan**: Standard
   * **Service name**: <TEAM_NAME>-object-svc 
   * **Resource group**: <TEAM_NAME>-services-rg 
   * **Tags**: `env:mgmt`

4. Click **Create**.

### Step 2: Create a new bucket and associate the key with it

1. Click your Storage instance.
2. Click Create bucket.
3. Click Create in the Create a Custom Bucket pane.
4. Enter a unique bucket name: <TEAM_NAME>-bucket-01
5. Select Resiliency>Regional.
6. Select a Location: `us-south`
7. Select a Storage Class: `Smart`
8. Enable Service integrations>Encryption>Key management.
9. Click Key Protect>Use existing instance.
10. Select the Search by instance tab in the Key Protect integration side panel.
11. Select the Key Protect instance from the menu: <TEAM_NAME>-kms-svc
12. Select the Key name: <TEAM_NAME>-root-key
13. Click the Associate key button.
14. Click the Create bucket button. A popup message displays that a bucket was created successfully.
15. Confirm by clicking the Configuration tab.

### Step 3: Create Service credentials with HMAC

Follow the instructions at [Service credentials](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials)

You will need the `access_key_id` and `secret_access_key` in the next steps.

### Step 4: Using the rclone client

Follow the Linux instructions at [Using rclone](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-rclone) to:

* Install rclone, [Linux installation from pre-compiled binary](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-rclone#rclone-linux-binary)
* [Configure access to IBM COS](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-rclone#rclone-config)
* Create a test file with `fallocate -l 5G test_file.txt`
* Use the command at [Copy a file from local to remote](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-rclone#rclone-reference-copy-local) to copy the test file to the bucket. <TEAM_NAME>-bucket-01

## Take a backup of the Windows and Linux servers

Backups are in effect, automated snapshots with a retention date. Backup policies contain user tags for target resources that associate the policy with block storage volumes, file shares, or virtual server instances with the same user tag. To create backups, at least one user tag that is applied to a resource must match the tag in the backup policy.


### Step 1: Creating a backup policies and plan

1. Use the instructions [Creating backup policies and plans](https://cloud.ibm.com/docs/vpc?topic=vpc-create-backup-policy-and-plan&interface=ui) to create a policy and plan. Use the standard for naming and:

   * Target resource type: `Instance block volumes`
   * Tags for target resources: `backup:yes`
   * In the Plan, set the retention days to `1`

## Bonus

If you have time:

1. Read [About virtual private endpoint gateways](https://cloud.ibm.com/docs/vpc?topic=vpc-about-vpe)
2. Follow the instructions [Creating an endpoint gateway](https://cloud.ibm.com/docs/vpc?topic=vpc-ordering-endpoint-gateway&interface=ui) to create a VPE for Cloud Object Storage. This will include:
    * Creating a reserved IP.
    * A security group with an inbound rule that allows TCP 443

## Questions




## Additiuonal Information

### Network Security
- Ensure security groups allow only necessary NFS traffic
- Restrict access to specific subnets or IP ranges
- Consider using VPN or Direct Link for sensitive data

### Access Control
- Implement proper file permissions on mounted shares
- Use IBM Cloud Identity and Access Management (IAM) for resource access
- Consider enabling encryption in transit

### Troubleshooting Common Issues

#### Mount Failures
- Verify security group rules allow NFS traffic
- Check network connectivity between VSI and mount target
- Ensure mount target is in same VPC as VSI
- Verify NFS client is installed on Ubuntu

#### Performance Issues
- Check file share IOPS limits
- Consider adjusting mount options (rsize, wsize)
- Monitor file share utilization in IBM Cloud Console

#### Connection Timeouts
- Increase timeout values in mount options
- Check for network latency issues
- Verify mount target health status