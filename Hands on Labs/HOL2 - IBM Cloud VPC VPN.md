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

## Resources that will be deployed in this HOL

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

## Scenario

In this HOL we will:

* Secrets Manager:
    * Step 1: Creating a Secrets Manager instance in the UI
    * Step 2: Create a Secrets Group
    * Step 3: Create Root Certificate Authority (CA)
    * Step 4: Create an Intermediate CA
    * Step 5: Create Certificate Templates
    * Step 6: Generate Server Certificate
    * Step 7: Generate Client Certificates
* Service to service authorization:
    * Step 1: Create service to service authorization
* VPC client-to-site VPN:
    * Step 1: Create client-to-site VPN
    * Step 2: Configure VPN Server Routes
    * Step 3: Connect to the VPC via the VPN
    * Step 4: Get the Windows password
    * Step 5: Connect to the Management Servers

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

The steps are as follows:

* Step 1: Creating a Secrets Manager instance in the UI
* Step 2: Create a Secrets Group
* Step 3: Create Root Certificate Authority (CA)
* Step 4: Create an Intermediate CA
* Step 5: Create Certificate Templates
* Step 6: Generate Server Certificate
* Step 7: Generate Client Certificates

### Step 1: Creating a Secrets Manager instance in the UI

1. In the console, navigate to the **Catalog**.
2. In the Search, type **Secrets Manager** and then select the tile.
3. In the Create tab:

    * **Region**: `Dallas (us-south)`
    * **Pricing Plan**: `Free`
    * **Name**: `<TEAM_NAME>-secrets-mgr-svc`
    * **Resource group**: `<TEAM_NAME>-services-rg`
    * **Tags**: `env:mgmt`
    * **Endpoints**: `Public and private`

4. Agree to the terms and click **Create**.
5. Wait until the service is created, this can take 5 - 15 minutes

### Step 2: Create a Secrets Group

We will create a group to contain the certificates.

1. Using the IBM Cloud portal, navigate to the Secrets Manager you have just created.
2. Select **Secret groups** from the menu.
3. Click **Create**.
4. Enter `vpn-certificates` for the **Name**.
5. Click **Create** at the bottom of the screen.
   
For information only, the following CLI would create the group

```bash
# Set environment variables
GUID=$(ibmcloud resource service-instance <TEAM_NAME>-secrets-mgr-svc --output json | jq -r '.[].guid')
export SECRETS_MANAGER_URL="https://$GUID.us-south.secrets-manager.appdomain.cloud"
export SECRET_GROUP_ID=`ibmcloud secrets-manager secret-group-create --name vpn-certificates --description "VPN certificate management" --service-url ${SECRETS_MANAGER_URL} --output json | jq -r '.id'`; echo $SECRET_GROUP_ID
```

### Step 3: Create Root Certificate Authority (CA)

1. Navigate to your Secrets Manager instance.
2. Go to **Secrets engines > Private Certificates**.
3. Click **Create certificate authority** to create a new CA.
4. In the dialogue boxes use the following settings, the at the end click **Create**:
   
    * **Name**: `vpn-root-ca`
    * **Encode URL**: `Enabled`
    * **Common Name**: `root.vpn.priv`
    * **Organization**: `demo`
    * **Country**: `US`
    * **Key management service**: `Secrets Manager`
    * **Key Algorithm**: `RSA 4096`
    * **Valid for**: `8760h` (1 year)

For information only the CLI command would be similar to the following:

```bash
ibmcloud secrets-manager configuration-create \
--configuration-prototype='{"config_type": "private_cert_configuration_root_ca", "name": "vpn-root-ca", "max_ttl": "87600h", "crl_expiry": "72h", "crl_disable": false, "crl_distribution_points_encoded": true, "issuing_certificates_urls_encoded": true, "common_name": "root.vpn.priv", "ttl": "87600h", "format": "pem", "private_key_format": "der", "key_type": "rsa", "key_bits": 4096, "max_path_length": -1, "exclude_cn_from_sans": false}'
```

### Step 4: Create an Intermediate CA

1. Via the CLI we will create an Intermediate CA

```bash
# Set the URL
GUID=$(ibmcloud resource service-instance <TEAM_NAME>-secrets-mgr-svc --output json | jq -r '.[].guid')
export SECRETS_MANAGER_URL="https://$GUID.us-south.secrets-manager.appdomain.cloud"
ibmcloud secrets-manager config set service-url $SECRETS_MANAGER_URL

# Create the intermediate CA
ibmcloud secrets-manager configuration-create \
--configuration-prototype='{"config_type": "private_cert_configuration_intermediate_ca", "name": "vpn-intermediate-ca", "max_ttl": "87600h", "crl_expiry": "72h", "crl_disable": false, "crl_distribution_points_encoded": true, "issuing_certificates_urls_encoded": true, "common_name": "intermediate.vpn.priv", "ttl": "87600h", "format": "pem", "private_key_format": "der", "key_type": "rsa", "key_bits": 4096, "max_path_length": -1, "exclude_cn_from_sans": false, "signing_method": "internal", "issuer": "vpn-root-ca"}'

# Sign the intermediate CA
ibmcloud secrets-manager configuration-action-create \
--name vpn-root-ca \
--config-action-action-type private_cert_configuration_action_sign_intermediate \
--config-action-intermediate-certificate-authority vpn-intermediate-ca
```
  
### Step 5: Create Certificate Templates

Using the UI we will create a server template

1. In the IBM Cloud Portal, navigate to the intermediate CA just created.
2. Click the **Add template** link, and complete the form using the following:

    * **Name**: `vpn-server-template`
    * **TTL**: `26280h`
    * **Key type**: `RSA 4096`
    * **Secret group**: `vpn-certificates`
    * **Allow bare domains**: `Enabled`
    * **Allow subdomains**: `Enabled`
    * **Allow any common name (CN)**: `Enabled`
    * **Allow only valid hostnames**: `Enabled`
    * **Use certificate for server**: `Yes`

3. Click **Add**.

For information only, the following CLI command would create the server template:

```bash
ibmcloud secrets-manager configuration-create \
--name vpn-server-template \
--config-type private_cert_configuration_template \
--private-cert-server-flag true \
--private-cert-client-flag false \
--private-cert-ca-name vpn-intermediate-ca \
--private-cert-max-ttl 26280h \
--private-cert-ttl 26280h \
--private-cert-private-key-type rsa \
--private-cert-private-key-bits 4096 \
--private-cert-allow-bare-domains true \
--private-cert-allow-subdomains true \
--private-cert-allow-glob-domains true\
--private-cert-allow-wildcard true \
--private-cert-allow-any-name true \
--private-cert-enforce-hostname false \
--private-cert-allow-ip-sans true \
--private-cert-allowed-uri-sans true \
--private-cert-allowed-secret-groups $SECRET_GROUP_ID
```

1. To create the client template, in a terminal session:

```bash
ibmcloud secrets-manager configuration-create \
--name vpn-client-template \
--config-type private_cert_configuration_template \
--private-cert-server-flag false \
--private-cert-client-flag true \
--private-cert-ca-name vpn-intermediate-ca \
--private-cert-max-ttl 26280h \
--private-cert-ttl 26280h \
--private-cert-private-key-type rsa \
--private-cert-private-key-bits 4096 \
--private-cert-allow-bare-domains true \
--private-cert-allow-subdomains true \
--private-cert-allow-glob-domains true\
--private-cert-allow-wildcard true \
--private-cert-allow-any-name true \
--private-cert-enforce-hostname false \
--private-cert-allow-ip-sans true \
--private-cert-allowed-uri-sans true \
--private-cert-allowed-secret-groups $SECRET_GROUP_ID
```

### Step 6: Generate Server Certificate

1. In the IBM Cloud Portal, navigate to **Secrets**.
2. Click the **Add** button.
3. Select the **Private certificates** tile.
4. Click Next.
5. In th dialog boxes use the following:

    * **Name**: `vpn-server-cert`
    * **Certificate authority**: `vpn-intermediat-ca`
    * **Template**: `vpn-server-template`
    * **Certificate common name**: `*.vpn.local`
    * **Secret group**: `vpn-certificates`

6. Click Next to see a review of the certificate, then click Add to create the certificate.

For information only, the following CLI command creates a server certification:

```bash
ibmcloud secrets-manager secret-create \
--secret-name vpn-server-cert \
--secret-type private_cert \
--secret-group-id $SECRET_GROUP_ID \
--private-cert-template-name vpn-server-template \
--certificate-common-name *.vpn.local
```

### Step 7: Generate Client Certificates

1. To create a client certificate using the client template:

```bash
ibmcloud secrets-manager secret-create \
--secret-name vpn-client-user1 \
--secret-type private_cert \
--secret-group-id $SECRET_GROUP_ID \
--private-cert-template-name vpn-client-template \
--certificate-common-name user1@demo.test
```

## Service to service authorization

### Step 1: Create service to service authorization

For the VPN service to get the certificates from Secrets Manager, an authorization must exist.
 
1. Go to IBM Cloud console  **Manage > Access (IAM) > Authorizations**.
2. Click "Create".
3. In the dialogue boxes create an authorization with the following characteristics:
   
   * **Source**: `VPC Infrastructure Services` with ResourceType equals `vpn-server`
   * **Target**: `Secrets Manager service`
   * **Role**: `SecretsReader`

## VPC client-to-site VPN

The steps are as follows:

* Step 1: Create client-to-site VPN
* Step 2: Configure VPN Server Routes
* Step 3: Connect to the VPC via the VPN
* Step 4: Get the Windows password
* Step 5: Connect to th Management Servers

### Step 1: Create client-to-site VPN

To create a client-to-site VPN server in the console:

1. Click **Infrastructure > Network > VPNs**.
2. Click **Create** in the upper right of the page.
3. In the VPN type section, click **Client-to-site servers**
4. In the **Details** section, specify the following information:

    * **Location**: `North America`, `Dallas (us-south)`
    * **VPN server name**: `<TEAM_NAME>-client-server-vpn`
    * **Resource group**: `<TEAM_NAME>-management-rg`.
    * **Tags**: `env:mgmt`
    * **Virtual private cloud**: `<TEAM_NAME>-management-vpc`
    * **Client IPv4 address pool**: `172.16.0.0/22`.

5. In the **Subnets** section:

    * **Select a VPN server mode**: `Stand-alone mode`.
    * **Subnets**: `<TEAM_NAME>vpn-sn`.

6. In the **Authentication** section, select:

    * **Server secrets manager**: <TEAM_NAME>-secrets-mgr-svc
    * **Server certificate**: `vpn-server-cert`

7. In the **Client authentication modes** section, select:

   * **Client secrets manager**: <TEAM_NAME>-secrets-mgr-svc
   * **Client certificate**: `vpn-client-cert`

8. In the **VPN security groups** section select `<TEAM_NAME>-vpn-sg`

9. In the Additional configuration section, specify the following information:

    * **DNS server IP address**: Use the IP addresses you fetched in HOL1.
    * **Transport protocol**: UDP, 443.
    * **Tunnel mode**: Split tunnel.

10. Click **Create VPN Server**.

For information only, if you used the CLI, the commands would be similar to the following:

```bash
vpn_server_cert_crn=$(ibmcloud secrets-manager secrets --output JSON | jq -r '.secrets.[] | select(.name=="vpn-server-cert") | .crn')
vpn_client_cert_crn=$(ibmcloud secrets-manager secrets --output JSON | jq -r '.secrets.[] | select(.name=="vpn-client-user1") | .crn')
target_security_group_id=$(ibmcloud is security-group team1-mgmt-sg  --output JSON | jq -r '.id')
subnet_1_id=$(ibmcloud is subnet team1-vpn-sn --output JSON | jq -r '.id')

ibmcloud is vpn-server-create \
--subnet $subnet_1_id \
--client-ip-pool 172.16.0.0/22 \
--cert $vpn_server_cert_crn \
--client-auth-methods certificate \
--client-ca $vpn_client_cert_crn \
--client-dns 10.1.2.4,10.1.2.5 \
--client-idle-timeout 3600 \
--enable-split-tunnel true \
--port 443 \
--protocol udp \
--sg team1-vpn-sg \
--name team1-client-server-vpn \
--resource-group-name team1-management-rg
```

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
2. Select the client certificate and then download the client profile. If the download is a zip file, then extract the files ready for the next task.
3. Open the OpenVPN client UI and import the .ovpn profile file by clicking the Plus icon on the lower right of the window.
4. Click Browse to select and import the .ovpn file (client profile).
5. To connect, click Connect.
6. Ensure that the VPN becomes **connected**.
7. To verify, in a console session use the command `ping 10.<TEAM_NUMBER>.1.4`. This will fail. Why? Troubleshot the issue, and as a hint review the relevant security groups. Add the required icmp rule.
8. Once rectified, test with a FQDN with ping `<TEAM_NAME>-mgmt-02-vsi.team<TEAM_NUMBER>.hol.cloud`

### Step 4: Get the Windows password

1. In a terminal session:

    ```bash
    # Get the VSI instance ID
    WIN_VSI_INSTANCE_ID=$(ibmcloud is instance <TEAM_NAME>-mgmt-02-vsi --output json | jq -r '.id')

    # Get the password
    ibmcloud is instance-initialization-values \
    $WIN_VSI_INSTANCE_ID \
    --private-key @~/.ssh/hol-key --output json | jq -r '.password.decrypted_password'
    ```

### Step 5: Connect to the Management Servers

1. Using SSH, connect to `ssh -i ~/.ssh/hol-key root@<TEAM_NAME>-mgmt-01-vsi.<TEAM_NAME>.hol.cloud`.
2. Type `cat /var/log/userdata.log` and ensure you something like `Sun Jun  1 10:14:37 UTC 2025: IBM Cloud CLI and tools installation completed` that was generated by the cloud-init user-data file we used.
3. Exit from the ssh session.
4. Use RDP to the connect to the Windows server using the FQDN <TEAM_NAME>-mgmt-02-vsi.team<TEAM_NUMBER>.hol.cloud. 
5. The credentials for the VSI are:

    * **Username**: Administrator
    * **Password**: The password noted above

6. Check that the applications have been installed; Firefox, VSCode etc

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

## Questions

Use [VPNs for VPC overview](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview) to help you answer the following:

1. What are the two main types of VPN services offered by IBM Cloud for VPC, and what is their primary purpose?
2. Describe the high availability characteristics of policy-based and route-based VPN gateways in IBM Cloud VPC.
3. When planning to deploy a VPN gateway, what is the minimum recommended subnet size, and why are certain IP addresses reserved within that subnet?
4. How does IBM Cloud VPN for VPC handle IKE local identity and peer gateway address by default, and what customisation options are available?
5. What crucial network configuration must be enabled on your on-premises VPN device for it to correctly communicate with IBM Cloud VPN for VPC, and which UDP ports must be allowed?
6. Which of the following statements about Perfect Forward Secrecy (PFS) in IBM Cloud VPN for VPC is true?
  A. PFS is enabled by default for all VPN connections.
  B. PFS is a mandatory setting for all VPN connections.
  C. PFS is disabled by default, but can be optionally enabled for Phase 2
  D. PFS is only supported for policy-based VPNs.

7. What are the Establish mode options for a VPN connection, and when would you choose Peer only? 
8. How can you enable the distribution of traffic between the tunnels of a route-based VPN gateway connection for active/active redundancy? What is a key requirement for the peer gateway for this feature?
9. Which type of IBM Cloud VPN for VPC (policy-based or route-based) currently supports Transit Gateway route advertisement?
10. What is the purpose of the Dead peer detection (DPD) feature in IBM Cloud VPN for VPC, and what actions can be configured?

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


### References

For a fuller description of [Connecting to private VPC networks using IBM Cloud Secrets Manager authenticated VPN on IBM Cloud](https://www.ibm.com/products/tutorials/connecting-to-private-vpc-networks-using-ibm-cloud-secrets-manager-authenticated-vpn-on-ibm-cloud#:~:text=in%20Figure%201:-,Step%201:%20Create%20a%20Secrets%20Group%20to%20contain%20the%20VPN,The%20review%20page%20will%20display.)
