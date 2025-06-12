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
   * **Trusted profile Name**: `<TEAM_NAME>-scc-wp-tp`
   * **App configuration Name**: `<TEAM_NAME>-scc-wp-ap`
   * **Connect a Monitoring instance**: `Disabled`

2. Once the instance is created, navigate to **Sources / IBM Cloud Account** and check that your account is in a status of **Active**.
3. Navigate to **Overview** and click on **Open dashboard**.
4. 