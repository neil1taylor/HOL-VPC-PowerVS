## Step 1: Generate Instance IDentity token
```
instance_identity_token=`curl -X PUT https://api.metadata.cloud.ibm.com/instance_identity/v1/token?version=2022-08-08 -H "Metadata-Flavor: ibm" -d '{"expires_in": 600}' | jq -r '(.access_token)'
```

## Step2: Generate IAM token if a TP was already attached to the instance during VM creation
```
iam_token=$(curl -s -X POST https://api.metadata.cloud.ibm.com/instance_identity/v1/iam_token?version=2024-11-12 \
  -H "Authorization: Bearer $instance_identity_token" | jq -r '.access_token'
```

**Or** 

## Step2: Generate IAM token if TP was attached later after instance creation

### 2.1 List the trusted profiles
       `curl -d "cr_token=${instance_identity_token}" "https://iam.cloud.ibm.com/identity/profiles"`

Make a note of it.

### 2.2 Use the TP id and generate iam token

Prerequisites: 
1. Trusted profile ID
Replace the value below in place:  **profile_id**

```
iam_token=$(curl -s -X POST https://api.metadata.cloud.ibm.com/instance_identity/v1/iam_token?version=2024-11-12 \
  -H "Authorization: Bearer $instance_identity_token" \
  -H "Content-Type: application/json" \
  -d '{
    "trusted_profile": {
      "id": "profile_id"
    }
  }' | jq -r '.access_token')
```

## Step 3: List policies in account

Replace the value below in place:  **ACCOUNT_ID**
```
curl -X GET "https://private.iam.cloud.ibm.com/v2/policies?account_id=ACCOUNT_ID" -H 'Content-Type: application/json' -H "Authorization: $iam_token" -s| jq .
```

## Step4: Get VM deatils
```
curl -X GET "http://api.metadata.cloud.ibm.com/metadata/v1/instance/initialization?version=2024-11-12"    -H "Accept: application/json"    -H "Authorization: Bearer $instance_identity_token"    | jq -r
```
