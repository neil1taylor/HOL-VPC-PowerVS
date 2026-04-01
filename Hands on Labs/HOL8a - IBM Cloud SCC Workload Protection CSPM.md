# Hands-on Lab 8a: Protecting Workloads with IBM Cloud Security and Compliance Center Workload Protection

This hands on lab explores IBM Cloud Security and Compliance Center Workload Protection with Cloud Security Posture Management (CSPM) for your IBM Cloud account **ONLY**. It does not explore IBM Cloud Security and Compliance Center Workload Protection with agents.

By enabling CSPM, it grants Workload Protection IAM permissions to provide continuous compliance from your IBM Cloud resources. The integration creates a Trusted Profile and App Configuration instance in your account to collect the compliance data.

## Step 1: Provisioning an instance

1. Follow the steps at [Provisioning an instance](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-provision&interface=ui) with the following information:

   * **Location**: Dallas `(us-south)`
   * **Plan**: `Free Trial`
   * **Name**: `<TEAM_NAME>-scc-wp-svc`
   * **Resource group**: `<TEAM_NAME>-services-rg`
   * **Tags**: `env:services`
   * **Enable Cloud Security Posture Management (CSPM) for your IBM Cloud account**: `Enabled`
   * **Trusted profile Name**: `<TEAM_NAME>-scc-wp-tp`
   * **App configuration Name**: `<TEAM_NAME>-scc-wp-ap`
   * **Connect a Monitoring instance**: `Disabled`

2. Once the instance is created, navigate to **Sources / IBM Cloud Account** and check that your account is in a status of **Active**.
3. Navigate to **Overview** and click on **Open dashboard**.

## Step 2: Explore the CSPM Dashboard

1. In the Workload Protection dashboard, navigate to **Compliance / Overview**.
2. Review the compliance score and the policies that are automatically applied to your account.
3. Note the number of passing and failing controls across the different compliance frameworks.

## Step 3: Review Compliance Policies

1. Navigate to **Policies / Posture / Policies**.
2. Review the available policies. Note that IBM Cloud-specific policies are pre-configured.
3. Select the **CIS IBM Cloud Foundations Benchmark** policy.
4. Review the requirements and controls.
5. For any failing control, click on it to see:
   * The affected resources
   * The control description
   * The remediation guidance

## Step 4: Investigate Failing Controls

1. Navigate to **Compliance / Overview** and select a zone (e.g., `Entire Infrastructure`).
2. Select a policy with failing controls.
3. Click on a failing control to see the list of affected resources.
4. For each failing resource:
   1. Click **View remediation** to review the remediation steps.
   2. Note the severity and the compliance framework the control belongs to.
5. If you find a known risk that you accept, click on the failing control and select **Accept Risk**. Choose whether to accept temporarily (with an expiry date) or permanently.

## Step 5: Review DORA Policy

1. In the Workload Protection UI, navigate to **Policies / Posture / Policies**.
2. In the search bar enter `DORA`.
3. Click on `Digital Operational Resilience Act (DORA) - Regulation (EU) 2022/2554`.
4. Select `Requirements & Controls`.
5. Under `Article 5, Governance and organisation`, select `Art 5.2(b)` and review the controls.
6. Click `Article 12, Backup policies and procedures, restoration and recovery procedures and methods`. In the search bar type `VPC`. Review the controls.
7. On a control, select the menu icon and select `Control Details`.
   1. Note what other policies include this control.
   2. Click on each of the following in turn; `Code`, `Remediation Playbook` and `Parameters`.

## Step 6: Explore Identity and Access Management (CIEM)

1. Navigate to **Policies / Posture / Identity and Access**.
2. Review the identity and access findings for your account.
3. Look for:
   * Users with excessive permissions
   * Inactive users or service IDs
   * API keys that have not been rotated

## Step 7: Create a Custom Zone

1. Navigate to **Policies / Posture / Zones**.
2. Click **New Zone**.
3. Enter the following:
   * **Name**: `<TEAM_NAME>-management-zone`
   * **Description**: `Management resources for team`
4. Under **Scope**, define the scope to include only your management resource group.
5. Click **Save**.
6. Navigate to **Compliance / Overview** and select your new zone.
7. Apply a policy to the zone and review the results.

## Questions

1. What is Cloud Security Posture Management (CSPM) and how does it differ from agent-based workload protection?
2. What IBM Cloud services are automatically created when CSPM is enabled on a Workload Protection instance?
3. What role do Trusted Profiles play in enabling CSPM for IBM Cloud?
4. How often are compliance scans refreshed for CSPM, and can they be triggered manually?
5. What is the purpose of a "Zone" in Workload Protection, and how can zones be used to organise compliance reporting?
6. What is "risk acceptance" in Workload Protection, and what options are available when accepting a risk?
7. Name three compliance frameworks or benchmarks that are available out-of-the-box for IBM Cloud CSPM.
8. What is CIEM (Cloud Infrastructure Entitlement Management) and how does it relate to CSPM?
9. How does CSPM use the App Configuration service to collect resource configuration data?
10. When implementing Context-Based Restrictions (CBR) for Workload Protection resources, what should you consider regarding the scope of restrictions?
