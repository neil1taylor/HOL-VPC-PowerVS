## Step 1: Generate Instance IDentity token
```
instance_identity_token=`curl -X PUT https://api.metadata.cloud.ibm.com/instance_identity/v1/token?version=2022-08-08 -H "Metadata-Flavor: ibm" -d '{"expires_in": 600}' | jq -r '(.access_token)'
```

## Step2: Generate IAM token if a TP was already attached to the instance during VM creation
```
iam_token=$(curl -s -X POST https://api.metadata.cloud.ibm.com/instance_identity/v1/iam_token?version=2024-11-12 \
  -H "Authorization: Bearer $instance_identity_token"
```

**Or** 

## Step2: Generate IAM token if TP was attached later after instance creation

2.1 List the trusted profiles
       `curl -d "cr_token=${instance_identity_token}" "https://iam.cloud.ibm.com/identity/profiles"`
       
2.2 Use the TP id and generate iam token
```
iam_token=$(curl -s -X POST https://api.metadata.cloud.ibm.com/instance_identity/v1/iam_token?version=2024-11-12 \
  -H "Authorization: Bearer $instance_identity_token" \
  -H "Content-Type: application/json" \
  -d '{
    "trusted_profile": {
      "id": "Profile-4ed68d9b-40fb-4734-8871-bfc96735e574"
    }
  }' | jq -r '.access_token')
```

## Step 3: List policies in account
```
curl -X GET "https://private.iam.cloud.ibm.com/v2/policies?account_id=cb83fe3c3d9b4308a919413aa69e9e37" -H 'Content-Type: application/json' -H "Authorization: $iam_token" -s| jq .
```
