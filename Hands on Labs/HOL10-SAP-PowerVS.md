# Hands-on Lab 10: Setting up SAP on IBM Power Virtual Servers

## Objectives:

* Process of provisioning an IBM Power Virtual Server instance for SAP workload, configuring its network, and performing initial setup steps for an SAP workload, demonstrating both CLI and direct API approaches.
* This lab focuses exclusively on Red Hat Enterprise Linux (RHEL).

## Prerequisites:
* An IBM Cloud Account with Power Virtual Server access.
* IBM Cloud CLI installed and configured / access to IBM Cloud console.
* An SSH key uploaded to your Power Virtual Server workspace.
* Familiarity with curl for making REST API calls.
* Basic understanding of JSON.
* jq installed (highly recommended for parsing JSON responses from API calls)

   `yum install jq (RHEL/CentOS) or brew install jq (macOS).`


## Resources that will be deployed in this HOL
In this HOL, you will deploy the following:

Resource Type |
--------------|
Importing Custom OS image as HANA / NW image
SAP PowerVS HANA instance sh2-4x256
SAP PowerVS Application server instance sr2-2x32
OS tuning for SAP using ansible roles
Cloud object storage instance plus bucket
HANA Backint agent

### Step 1: Importing Custom OS image for deploying SAP instance (Optional. Will be skipped in the lab)
**Using UI**
1. Navigate to Resource list from hamburger menu.
1. Click on the desired Power Virtual Server Workspace under the Compute list.
1. Click on Boot images on the left section.
1. Click on Import Boot image.
1. Fill in details and click import.
1. This job will be take 20-30 minutes or sometimes even more depending on the size of the image.

**Using CLI:**
```
# list the PowerVS workspaces
ibmcloud pi ws ls

# target the PowerVS workspace
ibmcloud pi ws tg <crn>

# Import the Custom image from the cloud object storage bucket
ibmcloud pi image import IMAGE_NAME [--bucket-access private] [--storage-tier STORAGE_TIER] [--os-type OSTYPE] [--import-details "LICENSE,PRODUCT,VENDOR"] [--user-tags USER_TAG1[,USER_TAGn]] --access-key KEY --secret-key KEY --image-file-name IMAGE_FILE_NAME --bucket BUCKET_NAME --region REGION_NAME

where
--import-details strings            Import details for SAP image. Must include a license, product and vendor.
                                          Valid license values: byol.
                                          Valid product values: Hana, Netweaver.
                                          Valid vendor values: SAP.
```

**Using terraform:**
```
resource "ibm_pi_image" "pi_custom_image1" {

  pi_image_name             = "custom-image-hana"
  pi_cloud_instance_id      = <workspace_guid>
  pi_image_bucket_name      = "my-cos-bucket-name"
  pi_image_bucket_access    = "private"
  pi_image_bucket_region    = "us-east"
  pi_image_bucket_file_name = "my-os-image-file.ova.gz"
  pi_image_storage_type     = "tier0", "tier1", "tier3", "tier5k"
  pi_image_access_key       = "my-cos-bucket-access-key"
  pi_image_secret_key       = "my-cos-bucket-secret-key"
  pi_image_import_details   = {
      license_type = "byol"
      product      = "Hana" or "Netweaver"
      vendor       = "SAP"
    }
}
```

**Using API:**
```
curl -X POST https://us-east.power-iaas.cloud.ibm.com/pcloud/v1/cloud-instances/$CLOUD_INSTANCE_ID/cos-images -H "Authorization: Bearer $TOKEN" -H "CRN: $CRN" -H "Content-Type: application/json"
  -d '{
        "imageName": "my-image-catalog-name",
        "region": "us-east",
        "imageFilename": "my-os-image-file.ova.gz",
        "bucketName": "my-cos-bucket-name",
        "accessKey": "my-cos-bucket-access-key",
        "secretKey": "my-cos-bucket-secret-key",
        "storageType": "tier3"
        "importDetails": {
        "licenseType": "byol"
        "product": "Hana"
        "vendor": "SAP"
    }
      }'
```

### Step 2: Creating SAP HANA Power Virtual Server Instance using certified profiles

[List of SAP HANA certified instances on IBM Power Virtual Server](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs)

**Using UI:**
1. Navigate to Resource list from hamburger menu.
1. Click on the desired Power Virtual Server Workspace under the Compute list.
1. Click on create instance
1. Fill in details
    * **ssh key**: Select from dropdown
    * **Operating System**: choose Linux HANA (IBM provided subscription)
    * **Machine Type**:  s1022
    * **Profile**: sh2-4x256
1. Volumes: 4 x 128 GB tier0 log, 4 x 670 GB tier3 data, 1 x 200 GB tier3 shared
1. Network: attach any one available in the workspace.
1. Click create.

**Using CLI:**
```
# list the PowerVS workspaces
ibmcloud pi ws ls

# target the PowerVS workspace
ibmcloud pi ws tg <crn>

# list available sap profiles (includes both HANA and Application profiles)
ibmcloud pi instance sap list

# list available subnets
ibmcloud pi subnet list

# list available images
ibmcloud pi image ls

# list stock catalog images with sap images
ibmcloud pi image lc --sap

# create SAP HANA instance
ibmcloud pi instance sap create <name> --key-name <key_name> --image <IMAGE_id> --profile-id <PROFILE_ID> --subnets "" --volumes ""
```

**Using Terraform:**
```
resource "ibm_pi_instance" "hana_instance" {
  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = var.hana_instance_name
  pi_ssh_public_key_name     = var.ssh_public_key_name
  pi_image_id                = var.image_id
  pi_sap_profile_id          = var.hana_instance_profile_id
  dynamic "pi_network" {
    for_each = var.pi_networks
    content {
      network_id = pi_network.value.id
      ip_address = pi_network.value.ip != null && pi_network.value.ip != "" ? pi_network.value.ip : null
    }
  }
}
```

**Using API:**
```
curl  -X POST \
  'https://us-east.power-iaas.cloud.ibm.com/pcloud/v1/cloud-instances/{guid}/sap' \
  --header 'Accept: */*' \
  --header 'Authorization: Bearer xxx' \
  --header 'CRN: {crn}' \
  --header 'Content-Type: application/json' \
  --data-raw '{
  "imageID": "{image_id}",
  "name": "sap-hana-vm",
  "networks": [
    {
      "networkID": "{network_id}"
    }
  ],
  "profileID": "sr2-4x256",
  "sshKeyName": "key_name",
  "storageType": "tier0",
  "volumeIDs": []
}'
```


### Step 3: Creating SAP Application Power Virtual Server Instance using certified profiles

[List of SAP Application Server certified instances on IBM Power Virtual Server](https://cloud.ibm.com/docs/sap?topic=sap-nw-iaas-offerings-profiles-power-vs)

The SAP Application Server profiles are not available over UI. However we can create similar one.
**Using UI:**
1. Navigate to Resource list from hamburger menu.
1. Click on the desired Power Virtual Server Workspace under the Compute list.
1. Click on create instance
1. Fill in details
    * **ssh key**: Select from dropdown
    * **Operating System**: choose Linux NetWeaver (IBM provided subscription)
    * **Machine Type**:  s1022
    * **core type**: dedicated
    * **Cores**: 2
    * **Memory**: 32
1. Volumes: 1 x 50 GB tier3 usrsap,
1. Network: attach any one available in the workspace.
1. Click create.

Terraform, API and CLI are same as HANA instance deployment.


### Step4: Filesystem creation and Tuning OS for SAP

Login using ssh private key to the SAP Power instance. `ssh root@private_ip`

Filesystem creation:
1. We stripe over 4 volumes using stripe size 64KB for log and data
```
Scan for new disks
/usr/bin/rescan-scsi-bus.sh -a -c -v

export pv_size=670G
export lv_name=datalv
export vg_name=datavg
export mount=/hana/data
devices=$(multipath -ll | grep -B 1 $pv_size | grep dm- | awk '{print "/dev/"$2}' | tr '\n' ' ')
vgcreate ${vg_name} ${devices}
lvcreate -i4 -I64 -l100%VG -n ${lv_name} ${vg_name}
mkfs.xfs /dev/mapper/${vg_name}-${lv_name} -K
mkdir -p ${mount}
mount /dev/mapper/$vg_name-$lv_name ${mount}
echo "/dev/mapper/$vg_name-$lv_name ${mount} xfs defaults,nofail 1 2 " >> /etc/fstab

export pv_size=128G
export lv_name=loglv
export vg_name=logvg
export mount=/hana/log
devices=$(multipath -ll | grep -B 1 $pv_size | grep dm- | awk '{print "/dev/"$2}' | tr '\n' ' ')
vgcreate ${vg_name} ${devices}
lvcreate -i4 -I64 -l100%VG -n ${lv_name} ${vg_name}
mkfs.xfs /dev/mapper/${vg_name}-${lv_name} -K
mkdir -p ${mount}
mount /dev/mapper/$vg_name-$lv_name ${mount}
echo "/dev/mapper/$vg_name-$lv_name ${mount} xfs defaults,nofail 1 2 " >> /etc/fstab

export pv_size=200G
export lv_name=sharedlv
export vg_name=sharedvg
export mount=/hana/shared
devices=$(multipath -ll | grep -B 1 $pv_size | grep dm- | awk '{print "/dev/"$2}' | tr '\n' ' ')
vgcreate ${vg_name} ${devices}
lvcreate -i1 -I64 -l100%VG -n ${lv_name} ${vg_name}
mkfs.xfs /dev/mapper/${vg_name}-${lv_name} -K
mkdir -p ${mount}
mount /dev/mapper/$vg_name-$lv_name ${mount}
echo "/dev/mapper/$vg_name-$lv_name ${mount} xfs defaults,nofail 1 2 " >> /etc/fstab

df -h
```


**Tuning OS for SAP HANA:**

RHEL System Roles for SAP are a collection of Ansible roles that help you configure a RHEL system for installing SAP HANA or SAP NetWeaver.
Ansible roles for SAP configuration are distributed and updated directly by Red Hat, so the task performed and parameters required might vary depending on the version of the `rhel-system-roles-sap` package.
The RHEL image that is provided by IBM includes the Ansible execution engine, SAP-related system roles, and the Ansible execution files.

For more information, see [following Red Hat article](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux_for_sap_solutions/8/html-single/red_hat_enterprise_linux_system_roles_for_sap/index)

|New role name             |
|--------------------------|
|sap_general_preconfigure  |
|sap_netweaver_preconfigure|
|sap_hana_preconfigure     |


The RHEL system roles for setting up SAP application are available in the root directory.

Use the following command to prepare the operating system for an SAP HANA workload.

```sh
ansible-playbook -i /root/inventory /root/sap-hana.yml
```

Use the following command to prepare the operating system for an SAP NetWeaver workload.

```sh
ansible-playbook -i /root/inventory /root/sap-netweaver.yml
```

For more information about customizing the operating system, see the following documentation.
* [SAP Note 2772999 "Red Hat Enterprise Linux 8.x: Installation and Configuration"](https://me.sap.com/notes/2772999)
* [SAP Note 2777782 "SAP HANA DB: Recommended OS Settings for RHEL8"](https://me.sap.com/notes/2777782)
* [SAP Note 2382421 "Optimizing the Network Configuration on HANA- and OS-Level"](https://me.sap.com/notes/2382421)
* [Red Hat Enterprise Linux System Roles for SAP](https://access.redhat.com/sites/default/files/attachments/rhel_system_roles_for_sap_1.pdf)

**Checking the NUMA layout**

Check that the CPU and memory placement is optimized for SAP HANA by running the `chk_numa_lpm.py` script.
The `chk_numa_lpm.py` script performs the following actions.

* Checks the nonuniform memory access (NUMA) layout according to SAP HANA rules.
   The script verifies that there are no cores without memory and that the memory distribution between the cores doesn't exceed a margin of 50%.
   In the first case, the script generates an error; in the second case, the script generates a warning.
* Checks if a Live Partition Mobility (LPM) operation has been performed.
   After LPM, the NUMA layout might be different from the configuration at boot time.
   The script searches the system log for the last LPM operation.
   A warning is generated if there has been an LPM operation since the last system boot.

1. Check the information in [SAP Note 2923962](https://me.sap.com/notes/2923962).
1. Download the `chk_numa_lpm.py` script that is attached to this SAP Note and copy it to your instance.
1. Set executable permissions for the script:
    ```sh
    chmod +x ./chk_numa_lpm.py
    ```
1. Run the script:
    ```sh
    ./chk_numa_lpm.py
    ```


**HCMT benchmark for DISK IO, NETWORK IO:**

HCMT tool is designed to measure and evaluate the performance of hardware and cloud infrastructure for running SAP HANA.

It provides insights into the capabilities and limitations of the underlying infrastructure and helps organizations make informed decisions when selecting hardware or cloud providers for their SAP HANA deployments.

**Outcome:** Ensure the filesystem throughput and network throughput meets the target KPIs.

```
mkdir /root/hcmt; cd /software/HCMT
./SAPCAR_1311-70001810.EXE -xvf HCMT_084_0-80003262.SAR -R /root/hcmt
cd /root/hcmt/setup/
./hcmtsetup                                     # installation of benchmark
setup/hcmt -v -p config/full_executionplan.json # to execute the tests using a config
```

### Step 5: HANA Backup to Cloud Object storage bucket using BACKINT agent

**Create IBM Cloud Object Storage Instance**
1. Click ☰ infrastructure > Storage > Object Storage.
1. Create an instance
    - **Plan**: Standarad
    - **Service Name**: my-cos-instance
    - **Resource group**: Pick any
1. Click Create.


**Create IBM Cloud Object Storage Bucket**
Inside the above created COS Instance lets proceed to create a bucket

1. Click Buckets > Create Bucket> Custom Bucket
1. Bucket Name: my-sample-bucket
    - **Location**: same as your PowerVS Instance Datacenter Location
    - **Storage Class:** Smart Tier
    - **Object Versioning**: Enabled
1. Click Create.

**Creating API key with limited permissions only**

Lets create custom role with following permissions to backup and restore HANA DB to COS.
1. Navigate: Manage > Access (IAM) > Roles
1. Create new role
    - **Name**: HanaBackup
    - **ID**: HanaBackup
    - **Service**: Cloud Object Storage
    - Select the below 15 roles and click create

|**Action**|
| - |
| cloud-object-storage.bucket.head |
| cloud-object-storage.bucket.get_lifecycle |
| cloud-object-storage.bucket.get |
| cloud-object-storage.object.put |
| cloud-object-storage.object.post_complete_upload |
| cloud-object-storage.object.post_initiate_upload |
| cloud-object-storage.object.put_part |
| cloud-object-storage.object.put_object_lock_retention |
| cloud-object-storage.object.head |
| cloud-object-storage.object.get |
| cloud-object-storage.bucket.get_versioning |
| cloud-object-storage.object.put_object_lock_legal_hold |
| cloud-object-storage.object.head_version |
| cloud-object-storage.bucket.get_versions |
| cloud-object-storage.object.get_version |

**Service ID creation**

Create a Service ID having the custom role access as above and limiting the access to a specific bucket. A Service ID API key will be generated which can then be used to interact with the Cloud Object storage bucket.

1. Navigate: Manage > Access (IAM) > Service IDs
1. Create, give a name and click create
1. Next under access policies click Assign access
1. **Service:** Cloud object storage > Next
1. Under Resources -> **choose Specific Resources**
1. Add the below conditions( Restricting access to a specific bucket only) where:
   1. Service Instance: Cloud Object Storage Instance (The one created few steps above)
   2. Resource Type: bucket (should always be "bucket"). This is not the name of the bucket.
   3. Resource ID: name of the bucket.
1. **Roles and action:** Under Custom access choose the custom role created in step above.
1. **Conditions**: skip
1. Click Add
1. Click Assign
1. Now switch to the API keys tab inside the service ID and create an API Key.
1. Save this key for backup operations.
