## HOL9 - IBM Cloud Identity and Access Management

What you will learn:

* Configure IBM Cloud IAM settings using UI, CLI, and REST APIs
* Manage users, access groups, roles, and policies through all interfaces
* Create service identities, generate API keys, and configure automation access
* Monitor IAM activities via Activity Tracker
* Set up federated identity and trusted profiles for workload access
* Simulate IAM security scenarios using multiple access paths

✅ Module 1: IAM Overview & Interface Setup (10 mins)

Objectives:

* Understand the IAM model and supported interfaces
* Set up CLI and prepare REST tools (Postman or curl)

Tasks:

* Log in to IBM Cloud Console (UI)
* Install and configure IBM Cloud CLI
* Set up Postman or curl with IAM token-based authentication

✅ Module 2: User Management (20 mins)

Objectives:

* Manage user invitations and role assignments via UI, CLI, and REST

Tasks:

* UI: Invite a new user, assign Viewer role
* CLI:
```bash
ibmcloud account user-invite user@example.com --role Viewer
```
* REST:
Send POST to /v1/invites with user email and roles
* Revoke user and verify access removal using Activity Tracker (UI)

✅ Module 3: Access Groups & IAM Policies (20 mins)

Objectives:

* Create access groups and assign policies

Tasks:

* UI:
    * Create group "DevOps Team"
    * Add members and assign Viewer + Editor roles

* CLI:
```
ibmcloud iam access-group-create "DevOps Team"
ibmcloud iam access-group-policy-create "DevOps Team" --roles Viewer,Editor --service-name cloud-object-storage
```
* REST:
    * Use POST /v2/groups to create group
    * Use POST /v1/policies to attach policy

✅ Module 4: Service IDs and API Keys (15 mins)

Objectives:

* Automate access with service IDs and keys

Tasks:

* UI:
    * Create Service ID for automation
    * Generate and download API Key

* CLI:

```
ibmcloud iam service-id-create app-automation
ibmcloud iam service-api-key-create key1 app-automation
```
* REST:
    * Use POST /v1/serviceids and POST /v1/apikeys

✅ Module 5: Activity Tracker and IAM Logs (10 mins)

Objectives:

    Monitor IAM activity across interfaces

Tasks:

    UI:

        Open Activity Tracker, filter IAM events

    CLI:
    Activity Tracker currently has limited CLI support—use UI

    REST:
    Access logs via Activity Tracker API (for advanced users)

✅ Module 6: Trusted Profiles and Identity Federation (25 mins)

Objectives:

    Configure trusted profile for workload identity

    Connect federated IdP (SAML/OIDC)

Tasks:

    UI:

        Create Trusted Profile “K8sAccess”

        Add compute resource link

        Assign access policies

    CLI:

    ibmcloud iam trusted-profile-create K8sAccess --description "Kubernetes Access Profile"
    ibmcloud iam trusted-profile-policy-create K8sAccess --roles Viewer --service-name cloud-object-storage

    REST:
    Use POST /v1/profiles and POST /v1/policies
    (Federation via PATCH /v1/saml_configuration or oidc_configuration)

✅ Module 7: Advanced IAM Scenarios (15 mins)

Objectives:

    Create conditional, time-based, and scoped policies

    Disable public access group

Tasks:

    UI:

        Create policy valid for 1 hour

        Disable "public access group" in IAM settings

    CLI:

    ibmcloud iam policy-create <subject> --roles Viewer --service-name cloud-object-storage --condition expiration="1h"
    ibmcloud account-settings-update --disable-public-access-group true

    REST:
    Use POST /v1/policies with conditions
    Update account settings via PATCH /v1/account_settings

✅ Wrap-Up and Q&A (5 mins)

    Recap differences between UI, CLI, and REST API

    Tips for choosing the right interface (automation vs. usability)

    Discuss IAM troubleshooting and best practices