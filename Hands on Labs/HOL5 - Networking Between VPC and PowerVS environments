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

Step 1: Create a transit gateway

### Step 1: Create a transit gateway

1. To use the IBM Cloud CLI to install a transit gateway with the following

```bash
# Install the plugin
ibmcloud plugin install tg

# Get the resource group ID
resource_group_id=$(ibmcloud resource group <TEAM_NAME>-services-rg --output JSON | jq -r '.id' )

# Create a local transit gateway
ibmcloud tg gateway-create \
--name <TEAM_NAME>-tgw-01 \
--location us-south \
--routing local \
--resource-group-id $resource_group_id
```

### Step 2: Create a connection to the PowerVS Workspace

1. Use the instructions at [Adding a connection](https://cloud.ibm.com/docs/transit-gateway?topic=transit-gateway-adding-connections&interface=ui) to connect the PowerVS workspace. Use the connection name `powervs-workspace`.

### Step 3: Create a connection to the Management VPC

For this connection we will use the API, but foirst we need an API key.

1. Follow the instructions at [Creating an API key in the console](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key)
2. Run the following command to store the API key for your account in an environment variable `apikey="<YOUR_API_KEY>"`. If using Windows `$apikey = "<YOUR_API_KEY>"`
3. Run the following command to get and parse an IAM token by using the JSON processing utility jq:

```bash
iam_token=`curl -k -s -X POST \
--header "Content-Type: application/x-www-form-urlencoded" \
--header "Accept: application/json" \
--data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
--data-urlencode "apikey=$apikey" \
"https://iam.cloud.ibm.com/identity/token"  | jq -r '.access_token'`
```

or if using Windows:

```ps1
$response = Invoke-RestMethod -Method Post -Uri "https://iam.cloud.ibm.com/identity/token" `
    -Headers @{
        "Content-Type" = "application/x-www-form-urlencoded"
        "Accept" = "application/json"
    } `
    -Body @{
        "grant_type" = "urn:ibm:params:oauth:grant-type:apikey"
        "apikey"     = $apikey
    }

$iam_token = "$($response.access_token)"
```

4. Run the following command to add a connection to the transit gateway:

```bash
# Set the variables
tgw_api_endpoint="https://transit.cloud.ibm.com/v1"
api_version=$(date +%F)
tgw_name="<TEAM_NAME>-tgw-01"
vpc_name="<TEAM_NAME>-management-vpc"
region="us-south"
connection_name="management-vpc"

# Get the gateway ID for the TGW we created
gateway_id=$(curl -s -X GET \
--location \
--header "Authorization: Bearer $iam_token" \
--header "Accept: application/json" \
"$tgw_api_endpoint/transit_gateways?version=$api_version" | jq -r --arg name "$tgw_name" '.transit_gateways[] | select(.name==$name) | .id')

# Get the CRN of the Management VPC
vpc_crn=$(curl -s -X GET "https://$region.iaas.cloud.ibm.com/v1/vpcs?version=$api_version&generation=2" \
-H "Authorization: $iam_token" \
-H "Accept: application/json" \
| jq -r --arg name "$vpc_name" '.vpcs[] | select(.name == $name) | .crn')

# Create the connection to the Management VPC
curl -X POST \
--location \
--header "Authorization: Bearer $iam_token " \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data @- <<EOF
{
  "name": "$connection_name",
  "network_type": "vpc",
  "network_id": "$vpc_crn",
  "base_connection": true,
  "location": "$region"
}
EOF
"$tgw_api_endpoint/transit_gateways/$gateway_id/connections?version=$api_version"
```

or in Windows:

```ps1
# Set the variables
$api_version = (Get-Date -Format "yyyy-MM-dd")
$tgw_api_endpoint = "https://transit.cloud.ibm.com/v1"
$tgw_name = "<TEAM_NAME>-tgw-01"
$vpc_name = "<TEAM_NAME>-management-vpc"
$region = "us-south"
$connection_name = "management-vpc"

# Get the Transit Gateway ID
$tgw_response = Invoke-RestMethod -Method Get -Uri "$tgw_api_endpoint/transit_gateways?version=$api_version" `
    -Headers @{
        "Authorization" = $iam_token
        "Accept" = "application/json"
    }

$gateway_id = ($tgw_response.transit_gateways | Where-Object { $_.name -eq $tgw_name }).id
Write-Host "TGW ID: $gateway_id"

# Get the CRN of the VPC
$vpc_response = Invoke-RestMethod -Method Get -Uri "https://$region.iaas.cloud.ibm.com/v1/vpcs?version=$api_version&generation=2" `
    -Headers @{
        "Authorization" = $iam_token
        "Accept" = "application/json"
    }

$vpc_crn = ($vpc_response.vpcs | Where-Object { $_.name -eq $vpc_name }).crn
Write-Host "VPC CRN: $vpc_crn"

# Create the TGW connection
$connection_body = @{
    name            = $connection_name
    network_type    = "vpc"
    network_id      = $vpc_crn
    base_connection = $true
    location        = $region
} | ConvertTo-Json -Depth 3

$create_response = Invoke-RestMethod -Method Post -Uri "$tgw_api_endpoint/transit_gateways/$gateway_id/connections?version=$api_version" `
    -Headers @{
        "Authorization" = $iam_token
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    } `
    -Body $connection_body

Write-Host "TGW Connection Created:"
$create_response | Format-List
```

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

by using `ssh -i ~/.ssh/hol-key -J root@<TEAM_NAME>-mgmt-01-vsi.team<TEAM_NUMBER>.hol.cloud` root@db-powervs.team<TEAM_NUMBER>.hol.cloud`
`

### Step 6: Troubleshooting

If you cannot ping or SSH, then using the UI or CLI check the following:

* Security Groups.
* ACls.
* VPN routes.
* VPC routes.
* TGW routes.
* VSI firewalls.
