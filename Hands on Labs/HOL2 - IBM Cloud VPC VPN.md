# Hands-on Lab 2: IBM Cloud VPC VPN

What you will learn:

* VPC VPN concepts, types, and use cases.
* Configure and deploy VPN gateways within IBM Cloud VPC.
* Establish site-to-site and client-to-site VPN connections
* Monitor and troubleshoot VPN connectivity
* Apply security best practices for VPN implementations.

## Prerequisites

- IBM Cloud account with appropriate permissions
- IBM Cloud CLI installed and configured
- OpenVPN Client installed see [Install a VPN client](https://cloud.ibm.com/docs/vpc?topic=vpc-setting-up-vpn-client#install-vpn-client)

## Overview

IBM Cloud has two VPN services:

* Site-to-site gateways - Connect remote sites to IBM Cloud through a VPN gateway on an IBM Cloud VPC. Route-based or policy-based mode IPsec site-to-site tunnels.
* Client-to-site servers - Allows users to connect to IBM Cloud resources through secure, encrypted connections via an OpenVPN client to connect to VPN servers on your IBM Cloud VPC via an TLS 1.2/1.3-based secure, encrypted 

The setup includes:

- IBM Cloud Secrets Manager instance for certificate management
- VPC with subnets and security groups
- Client-to-Site VPN server
- Certificate authority (CA) and client certificates
- VPN client configuration


### Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Secrets Manager Instance | <TEAM_NAME>-secrets-mgr-svc
Secrets Manager Key |  <TEAM_NAME>-secrets-manager-key
Client to Server VPN | <TEAM_NAME>-client-server-vpn
Site to Site VPN | <TEAM_NAME>-site-to-site-vpn

This document references:

- `<TEAM_NAME>` this is your team name e.g. `team-1`
- `<TEAM_ID_NUMBER>` this is your team number e.g. `1`

### Steps

* Secrets Manager:
    * Step 1: Creating a Secrets Manager instance in the UI
    * Step 2: Create a Secrets Manager key
    * Step 3: Create Root Certificate Authority (CA)
    * Step 4: Create a Secrets Group
    * Step 5: Create an Intermediate CA
    * Step 6: Create Certificate Templates
    * Step 7: Generate Server Certificate
    * Step 8: Generate Client Certificates
* VPC client-to-site VPN:
    * Step 1: Create client-to-site VPN
    * Step 2: Configure VPN Server Routes
    * Step 3: Connect to the VPC via the VPN
    * Step 4: Get the Windows password
    * Step 5: Connect to the Windows Management Server

Then we will look at the site-to-site VPN type:

* VPC Site-to-site VPN
    * Step 1: Create IKE Policy
    * Step 2: Create IPSec Policy
    * Step 3: Create VPN Gateway in your VPC
    * Step 4: Configure Routing
    * Step 5: Verify and Test Connection

## Secrets Manager

This section in the hands on lab, walks you through setting up IBM Cloud Secrets Manager to manage certificates for a VPC Client-to-Site VPN connection.

Provisioning Secrets Manager in your IBM Cloud account can take 5 - 15 minutes to complete as the service creates a single tenant, dedicated instance.

### Step 1: Creating a Secrets Manager instance in the UI

1. In the console, navigate to the **Catalog**.
2. In the Search, type **Secrets Manager** and then select the tile.
3. In the Create tab:

    * **Region**: us-south
    * **Pricing Plan**: Standard 
    * **Name**: <TEAM_NAME>-secrets-mgr-svc
    * **Resource group**: <TEAM_NAME>-services-rg
    * **Tags**: env:mgmt
    * public-and-private.

4. Click **Create**.
5. Wait until the service is created, this can take 5 - 15 minutes

### Step 2: Create a Secrets Manager key

1. Go to **Resource List → Services → Secrets Manager**.
2. Click on <TEAM_NAME>-secrets-mgr-svc.
3. Note the instance ID and endpoint URL.

4. In a terminal session enter the following commands to create service credentials:

   ```bash
   # Create service credentials
   ibmcloud resource service-key-create \
   <TEAM_NAME>-secrets-manager-key \
   Manager \
   --instance-name <TEAM_NAME>-secrets-mgr-svc.
   
   # Get the API key from the service credentials
   ibmcloud resource service-key secrets-manager-key
   ```

### Step 3: Create Root Certificate Authority (CA)

1. Navigate to your Secrets Manager instance.
2. Go to **Engines → Private Certificate Authority**.
3. Click **Create** to create a new CA.
4. Configure CA settings:
   
    * **Name**: `vpn-root-ca`
    * **Common Name**: `VPN Root CA`
    * **Organization**: `demo`
    * **Country**: `US`
    * **Key Algorithm**: `RSA 4096`
    * **TT**: `8760h` (1 year)

### Step 4: Create a Secrets Group

1. Via API/CLI we will create a group to contain the certificates. In a terminal session:
   ```bash
   # Set environment variables
   export SECRETS_MANAGER_URL="https://<TEAM_NAME>-secrets-mgr-svc.us-south.secrets-manager.appdomain.cloud"
   export IAM_TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r '.iam_token')
   
   # Create root a group
   curl -X POST \
     "${SECRETS_MANAGER_URL}/v2/secret_groups" \
     -H "Authorization: ${IAM_TOKEN}" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "vpn-certificates",
       "description": "VPN certificate management"
     }'
   ```

### Step 5: Create an Intermediate CA

1. Create Intermediate CA via the API/CLI:

    ```bash
    # Create intermediate CA configuration
    curl -X POST \
    "${SECRETS_MANAGER_URL}/v2/engines/private_cert/config/ca" \
    -H "Authorization: ${IAM_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
        "config_type": "private_cert_configuration_intermediate_ca",
        "name": "vpn-intermediate-ca",
        "common_name": "VPN Intermediate CA",
        "issuer": "vpn-root-ca",
        "signing_method": "internal",
        "ou": ["Demo"],
        "organization": ["Demo Org"],
        "country": ["US"],
        "locality": ["Dallas"],
        "province": ["Texas"],
        "key_type": "rsa",
        "key_bits": 4096,
        "max_ttl": "8760h",
        "ttl": "8760h"
    }'
    ```

### Step 6: Create Certificate Templates

1. To create the server template, in a terminal session:

   ```bash
   curl -X POST \
     "${SECRETS_MANAGER_URL}/v2/engines/private_cert/config/template" \
     -H "Authorization: ${IAM_TOKEN}" \
     -H "Content-Type: application/json" \
     -d '{
       "config_type": "private_cert_configuration_template",
       "name": "vpn-server-template",
       "certificate_authority": "vpn-intermediate-ca",
       "allow_any_name": true,
       "allow_subdomains": true,
       "allowed_domains": ["*.vpn.local", "vpn.local"],
       "allow_ip_sans": true,
       "key_type": "rsa",
       "key_bits": 4096,
       "max_ttl": "2160h",
       "ttl": "2160h",
       "server_flag": true,
       "client_flag": false,
       "key_usage": ["digital_signature", "key_encipherment"],
       "ext_key_usage": ["server_auth"]
     }'
   ```

2. To create the client template, in a terminal session:

   ```bash
   curl -X POST \
     "${SECRETS_MANAGER_URL}/v2/engines/private_cert/config/template" \
     -H "Authorization: ${IAM_TOKEN}" \
     -H "Content-Type: application/json" \
     -d '{
       "config_type": "private_cert_configuration_template",
       "name": "vpn-client-template",
       "certificate_authority": "vpn-intermediate-ca",
       "allow_any_name": true,
       "key_type": "rsa",
       "key_bits": 4096,
       "max_ttl": "720h",
       "ttl": "720h",
       "server_flag": false,
       "client_flag": true,
       "key_usage": ["digital_signature"],
       "ext_key_usage": ["client_auth"]
     }'
   ```

### Step 7: Generate Server Certificate

1. To generate a server certificate using the template created earlier:

    ```bash
    # Generate server certificate
    curl -X POST \
    "${SECRETS_MANAGER_URL}/v2/secrets" \
    -H "Authorization: ${IAM_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
        "secret_type": "private_cert",
        "name": "vpn-server-cert",
        "description": "VPN Server Certificate",
        "secret_group_id": "default",
        "labels": ["vpn", "server"],
        "certificate_template": "vpn-server-template",
        "common_name": "vpn.example.com",
        "alt_names": ["vpn.local"],
        "ip_sans": ["10.<TEAM_ID_NUMBER>.0.0/24"],
        "ttl": "2160h"
    }'
    ```

### Step 8: Generate Client Certificates

1. To create a client certificate using the client template:

    ```bash
    # Generate client certificate for user1
    curl -X POST \
    "${SECRETS_MANAGER_URL}/v2/secrets" \
    -H "Authorization: ${IAM_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
        "secret_type": "private_cert",
        "name": "vpn-client-user1",
        "description": "VPN Client Certificate for User1",
        "secret_group_id": "default",
        "labels": ["vpn", "client", "user1"],
        "certificate_template": "vpn-client-template",
        "common_name": "user1@demo.test",
        "ttl": "720h"
    }'
    ```

## VPC client-to-site VPN

The steps are as follows:

* Step 1: Create client-to-site VPN
* Step 2: Configure VPN Server Routes
* Step 3: Connect to the VPC via the VPN
* Step 4: Get the Windows password
* Step 5: Connect to the Windows Management Server

### Step 1: Create client-to-site VPN

To create a client-to-site VPN server in the console:

1. Click **Infrastructure > Network > VPNs**.
2. Click **Create** in the upper right of the page.
3. In the VPN type section, click **Client-to-site servers**
4. In the **Details** section, specify the following information:

    * **VPN server name**: <TEAM_NAME>-client-server-vpn.
    * **Resource group**: <TEAM_NAME>-management-rg.
    * **Tags**: `env:mgmt`
    * **Virtual private cloud**: <TEAM_NAME>-management-vpc
    * **Client IPv4 address pool**: `172.16.0.0/22`.

5. In the **Subnets** section:

    * **Select a VPN server mode**: Stand-alone mode.
    * **Subnets**: <TEAM_NAME>vpn-sn.

6. In the **Authentication** section, select:

    * **Server secrets manager**: <TEAM_NAME>-secrets-mgr-svc
    * **Server certificate**: `vpn-server-cert`

7. In the **Client authentication modes** section, select:

   * **Client secrets manager**: <TEAM_NAME>-secrets-mgr-svc
   * **Client certificate**: `vpn-client-cert`

8. In the **VPN security groups** section select <TEAM_NAME>-vpn-sg

9. In the Additional configuration section, specify the following information:

    * **DNS server IP address**: .
    * **Transport protocol**: UDP, 443.
    * **Tunnel mode**: Split tunnel.

10. Click **Create VPN Server**.

### Step 2: Configure VPN Server Routes

1. In a terminal session:

    ```bash
    # Get VPN server ID
    VPN_SERVER_ID=$(ibmcloud is vpn-servers --output json | jq -r '.[] | select(.name=="<TEAM_NAME>-client-server-vpn") | .id')

    # Add route for VPC subnet
    ibmcloud is vpn-server-route-create $VPN_SERVER_ID \
    --destination "10.<TEAM_NUMBER>.0.0/20" \
    --action translate
    ```

### Step 3: Connect to the VPC via the VPN

After you create the VPN server using the newly created certificate, you can set up and configure your clients' VPN environment to connect to the VPN server.

1. Open the details page of the VPN server and click the **Clients** tab.
2. Select the client certificate and then download the client profile.
3. Open the OpenVPN client UI and import the .ovpn profile file by clicking the Plus icon on the lower right of the window.
4. Click Browse to select and import the .ovpn file (client profile).
5. To connect, click Connect.

### Step 4: Get the Windows password

1. In a terminal session:

    ```bash
    # Get the VSI instance ID
    WIN_VSI_INSTANCE_ID=$(ibmcloud is instance <TEAM_NAME>-mgmt-02-vsi --output json | jq '-r .id')

    # Get the password
    ibmcloud is instance-initialization-values \
    $WIN_VSI_INSTANCE_ID \
    --private-key @~/.ssh/hol-key

### Step 5: Connect to the Windows Management Server

1. Use RDP to the connect to the Windows server using the FQDN <TEAM_NAME>-mgmt-02-vsi.team<TEAM_NUMBER>.hol.cloud. 
2. The credentials for the VSI are:

    * **Username**: Administrator
    * **Password**: The password noted above

## VPC Site-to-site VPN

This guide walks through connecting two IBM Cloud VPCs using a site-to-site VPN connection, enabling secure communication between resources in different VPCs. You will work with a neighboring team to connect your VPCs. It is important that there are no overlapping subnet CIDR blocks used in both VPCs which is why te IP addressing scheme has been designed around 10.<TEAM_NUMBER>.x.x.

The steps are as follows:

* Step 1: Create IKE Policy
* Step 2: Create IPSec Policy
* Step 3: Create VPN Gateway in your VPC
* Step 4: Configure Routing
* Step 5: Verify and Test Connection

### Step 1: Create IKE Policy

1. Navigate to **VPC Infrastructure > VPNs** in IBM Cloud console.
2. In the **Site-to-site gateway** tab, in the **VPN Gateways** tab click **IKE policies**.
3. Click **Create IKE policy**.
4. Configure as follows:

    - **Name**: <TEAM_NAME>-ike-policy
    - **Authentication Algorithm**: `SHA-256`
    - **Encryption Algorithm**: `AES-256`
    - **DH Group**: `Group 14`
    - **IKE Version**: `IKEv2`
    - **Key Lifetime**: `28800 seconds`

5. Click **Create**.


### Step 2: Create IPSec Policy

1. Navigate to **VPC Infrastructure > VPNs** in IBM Cloud console.
2. In the **Site-to-site gateway** tab, in the **VPN Gateways** tab click **IPSec policies**.
3. Click **Create IPSec policy**.
4. Configure as follows:

    - **Name**: <TEAM_NAME>-ipsec-policy
    - **Authentication Algorithm**: `SHA-256`
    - **Encryption Algorithm**: `AES-256 `
    - **Perfect Forward Secrecy**: `Group 14`
    - **Key Lifetime**: `3600 seconds`

### Step 3: Create VPN Gateway in your VPC

1. Navigate to **VPC Infrastructure > VPNs** in IBM Cloud console
2. In the **Site-to-site gateway** tab, in the **VPN Gateways** tab click **Create**.
3. Configure the Gateway parameters:

    - **Geography**: North America
    - **Region**: us-south
    - **VPN gateway name**: <TEAM_NAME>-site-to-site-vpn
    - **Resource Group**: <TEAM_NAME>-services-rg
    - **Tags**: `env:mgmt`
    - **VPC**: <TEAM_NAME>-management-vpc
    - **Subnet**: <TEAM_NAME>-vpn-sn
    - **Mode**: `Route-based`
    
4. Continue with the VPN connection for VPC parameters:

    - **VPN connection name**: <TEAM_NAME>-to-<OTHER_TEAM_NAME>
    - **Peer gateway address**: `5.5.5.5` # A dummy IP address for now
    - **Preshared key**: Agree a complex key between the two teams

5. Click **Create VPN gateway**.
6. The VPN gateway will be created but will have no connection (down state) due to the dummy IP address. Work with your neighbor team and swap addresses.

### Step 4: Configure Routing

1. Navigate to **VPC Infrastructure > Routing tables**
2. Select the route table for the <TEAM_NAME>-management-vpc VPC. 
3. Add routes for remote VPC subnets pointing to the local VPN gateway.
4. Review Security Groups and NACLs to allow communication.

### Step 5: Verify and Test Connection

1. Check VPN connection status in both gateways
2. Use ping between the managements ervers to verify that packets traverse across the VPN

## Additional Information

This section provides additional information that may be useful in the future, It is not part of the hands on lab

### Retrieve Certificates from Secrets Manager

```bash
# Function to get certificate from Secrets Manager
get_certificate() {
  local cert_name=$1
  curl -s -X GET \
    "${SECRETS_MANAGER_URL}/v2/secrets/name/${cert_name}" \
    -H "Authorization: ${IAM_TOKEN}" \
    -H "Accept: application/json"
}

# Get server certificate
SERVER_CERT=$(get_certificate "vpn-server-cert")
echo "$SERVER_CERT" | jq -r '.certificate' > server.crt
echo "$SERVER_CERT" | jq -r '.private_key' > server.key

# Get CA certificate
CA_CERT=$(curl -s -X GET \
  "${SECRETS_MANAGER_URL}/v2/engines/private_cert/certificate_authorities/vpn-intermediate-ca/certificate" \
  -H "Authorization: ${IAM_TOKEN}")
echo "$CA_CERT" | jq -r '.certificate' > ca.crt
```

### Create VPN Server

```bash
# Create VPN server
ibmcloud is vpn-server-create \
  --name my-vpn-server \
  --subnet $SUBNET_ID \
  --security-group $SG_ID \
  --certificate-crn "crn:v1:bluemix:public:secrets-manager:us-south:a/<account-id>:<instance-id>::secret<server-cert-id>" \
  --client-certificate-crn "crn:v1:bluemix:public:secrets-manager:us-south:a/<account-id>:<instance-id>::secret<ca-cert-id>" \
  --client-ip-pool "172.16.0.0/22" \
  --protocol udp \
  --port 1194
```


### Generate Client Configuration

1. **Retrieve client certificate:**
   ```bash
   # Get client certificate
   CLIENT_CERT=$(get_certificate "vpn-client-user1")
   echo "$CLIENT_CERT" | jq -r '.certificate' > client.crt
   echo "$CLIENT_CERT" | jq -r '.private_key' > client.key
   ```

2. **Create OpenVPN client configuration:**
   ```bash
   # Get VPN server details
   VPN_SERVER_HOSTNAME=$(ibmcloud is vpn-server $VPN_SERVER_ID --output json | jq -r '.hostname')
   
   # Create client.ovpn file
   cat > client.ovpn << EOF
   client
   dev tun
   proto udp
   remote $VPN_SERVER_HOSTNAME 1194
   resolv-retry infinite
   nobind
   persist-key
   persist-tun
   ca ca.crt
   cert client.crt
   key client.key
   verb 3
   cipher AES-256-GCM
   auth SHA256
   key-direction 1
   remote-cert-tls server
   EOF
   ```

### Certificate Automation Script

Create a script to automate certificate renewal:

```bash
#!/bin/bash
# vpn-cert-renewal.sh

SECRETS_MANAGER_URL="https://<instance-id>.<region>.secrets-manager.appdomain.cloud"
IAM_TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r '.iam_token')

renew_certificate() {
  local cert_name=$1
  local template=$2
  local common_name=$3
  
  echo "Renewing certificate: $cert_name"
  
  # Delete old certificate
  curl -X DELETE \
    "${SECRETS_MANAGER_URL}/v2/secrets/name/${cert_name}" \
    -H "Authorization: ${IAM_TOKEN}"
  
  # Create new certificate
  curl -X POST \
    "${SECRETS_MANAGER_URL}/v2/secrets" \
    -H "Authorization: ${IAM_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"secret_type\": \"private_cert\",
      \"name\": \"${cert_name}\",
      \"certificate_template\": \"${template}\",
      \"common_name\": \"${common_name}\",
      \"ttl\": \"720h\"
    }"
}

# Check certificate expiration and renew if needed
check_and_renew() {
  local cert_name=$1
  local template=$2
  local common_name=$3
  
  cert_info=$(curl -s -X GET \
    "${SECRETS_MANAGER_URL}/v2/secrets/name/${cert_name}" \
    -H "Authorization: ${IAM_TOKEN}")
  
  expiry=$(echo "$cert_info" | jq -r '.expiration_date')
  current_time=$(date +%s)
  expiry_time=$(date -d "$expiry" +%s)
  days_until_expiry=$(( (expiry_time - current_time) / 86400 ))
  
  if [ $days_until_expiry -lt 30 ]; then
    echo "Certificate $cert_name expires in $days_until_expiry days. Renewing..."
    renew_certificate "$cert_name" "$template" "$common_name"
  else
    echo "Certificate $cert_name is valid for $days_until_expiry more days"
  fi
}

# Check all certificates
check_and_renew "vpn-server-cert" "vpn-server-template" "vpn.example.com"
check_and_renew "vpn-client-user1" "vpn-client-template" "user1@example.com"
```

### Configure Additional Security

1. **Enable certificate revocation:**
   ```bash
   # Create CRL configuration
   curl -X POST \
     "${SECRETS_MANAGER_URL}/v2/engines/private_cert/config/crl" \
     -H "Authorization: ${IAM_TOKEN}" \
     -H "Content-Type: application/json" \
     -d '{
       "config_type": "private_cert_configuration_crl",
       "name": "vpn-crl-config",
       "crl_expiry": "72h",
       "crl_auto_rebuild": true,
       "crl_auto_rebuild_grace_period": "12h"
     }'
   ```

2. **Set up certificate monitoring:**
   - Configure IBM Cloud Monitoring for certificate expiration alerts
   - Set up automated renewal workflows
   - Implement certificate rotation procedures

3. **Network security:**
   - Restrict VPN server access to specific IP ranges
   - Implement proper firewall rules
   - Enable VPC flow logs for monitoring

### Test VPN Connection

1. **Install OpenVPN client on test machine**
2. **Copy certificate files and client.ovpn configuration**
3. **Connect to VPN:**
   ```bash
   sudo openvpn --config client.ovpn
   ```

4. **Verify connectivity:**
   ```bash
   # Test internal VPC connectivity
   ping 10.240.0.1
   
   # Test DNS resolution
   nslookup internal.vpc.resource
   ```

### Monitor and Maintain

1. **Set up monitoring dashboards**
2. **Configure log forwarding**
3. **Implement automated health checks**
4. **Create backup and disaster recovery procedures**

### Troubleshooting Common Issues

#### Certificate Issues
- **Certificate not found:** Verify certificate names and Secrets Manager permissions
- **Authentication failures:** Check certificate validity and CA chain
- **Permission denied:** Ensure proper IAM roles and policies

#### VPN Connection Issues
- **Connection timeout:** Check security group rules and firewall settings
- **Authentication failure:** Verify client certificates and server configuration
- **Route issues:** Confirm VPN server routes and subnet configurations

#### Secrets Manager Issues
- **API authentication:** Verify IAM tokens and service credentials
- **Certificate generation:** Check template configurations and CA status
- **Access permissions:** Ensure proper resource group and IAM policies
