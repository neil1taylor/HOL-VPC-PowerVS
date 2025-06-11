# Hands-on Lab 8: Protecting Workloads with IBM Cloud Security and Compliance Center Workload Protection

**This hands on lab focuses on Agents**. Only follow this lab if you want to explore the usage of agents. If you want to just explore CSPM of the IBM Cloud account **do not** follow this lab.

What you will learn:

* Overview of IBM Cloud Security and Compliance Center Workload Protection.
* Installing and configuring Workload Protection agents for VPC and PowerVS instances.
* Policy creation: vulnerability management, compliance enforcement, and threat detection.
* Real-time security event monitoring and automated response workflows.

## Overview

IBM Cloud Security and Compliance Center Workload Protection is a comprehensive platform designed to find and prioritize software vulnerabilities, detect and respond to threats, and manage configurations, permissions, and compliance from source to runtime in various environments, including hosts and VMs. In this hands on lab we have disabled Cloud Security Posture Management (CSPM) to focus on the features of the host agents, For further info on CSPM see Additional Information below.

For standalone Linux and Windows hosts, Workload Protection provides several key features:

* **Threat Detection and Response (Server Endpoint Detection and Response - EDR)**:
    * This feature instruments hosts and VMs through eBPF to inspect all system activity via system calls with a minimal performance footprint.
    * It helps identify threats and suspicious activity based on application, network, and host activity by processing syscall events.
    * You can investigate incidents with detailed system captures.
    * Preemptive blocking is available to prevent blacklisted or malicious binaries from execution.
    * Advanced remediation allows for automatic execution of corrective actions, such as killing processes or containers.
    * Detection rules like File Integrity Monitoring (FIM) can be defined per scope (path, filename, command, user, etc.) to detect various activities.
    * Malware Control Policies can be created to detect malware execution using known malware hashes and YARA rules.
* **Vulnerability Management (Host Scanning)**:
    * This feature scans host packages and detects associated vulnerabilities.
    * It identifies the resolution priority based on available fixed versions and severity.
    * For Windows Servers, it provides coverage for operating system vulnerabilities from Microsoft Security Response Center and detects non-operating system package vulnerabilities.
    * For Linux hosts, it adds **in-use runtime context** to filter out vulnerabilities exposed on running applications, which can reduce the number of vulnerabilities to immediately fix.
* **Compliance (Posture management)**: 
    * Allows the evaluation of standalone Hosts against a number of benchmarks, such as CIS Distribution Independent Linux Benchmark or other compliance policies.
    * This functionality is provided by the the Kubernetes Security Posture Management (KSPM) analyzer. Results will be shown within a few minutes of installation and scans are refreshed every 24 hours.

Workload Protection supports deploying agents on a variety of hosts:

*   **Linux hosts**: This includes IBM Cloud VSIs, other cloud providers (AWS, Azure, GCP), or on-premises or VMs hosted on hypervisors such as VMware. Support exists for Debian, Ubuntu, CentOS, RHEL, Fedora, Amazon AMI, and Amazon Linux. Power Virtual Server (PowerVS) Linux hosts are also supported.
*   **AIX servers on PowerVS**: Posture compliance for AIX operating system is provided.
*   **Windows Servers**: Compliance scanning and host scanning for standalone Windows Server hosts are supported.

## Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------
Workload Protection instance | <TEAM_NAME>-scc-wp-svc

## Scenario

In this HOL we will:

* Provision the service and deploy agents:
    * Step 1: Provisioning a Workload Protection instance
    * Step 2: Install a Workload Protection Agent for Linux
* Verify the Agent Connection and Status:
    * Step 1: Verify the configuration
    * Step 2: Verify Agent Status
    * Step 3: Verifying results in the UI
* Explore the UI:
    * Step 1: Compliance
    * Step 2: Vulnerability Management (Host Scanning)
    * Step 3: Threat Detection and Response (Server EDR)
    * Step 4: Create a preemptive blocking policy
    * Step 5: Review the DORA policy

## Provision the service and deploy agents

### Step 1: Provisioning a Workload Protection instance

1. Using the information at [Provisioning an instance](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-provision&interface=ui) and using either the UI or CLI, provision an instance of Workload Protection:

* **Location**: Dallas (us-south)
* **Plan**: Free Trial
* **Name**: <TEAM_NAME>-scc-wp-svc
* **Resource Group**: <TEAM_NAME>-services-rg
* **Tags**: `env:mgmt`
* **Enable Cloud Security Posture Management (CSPM) for your IBM Cloud account**: Disabled

We have disabled **Cloud Security Posture Management** in this hands on lab so that we can focus on the workload protection features. If you have time at the end of this lab then enable CSPM and investigate it's features.

### Step 2: Install a Workload Protection Agent for Linux

1. On the Workload Protection instance page, click Sources then Linux.
2. Note the commandline instructions to install via the provate endpoint.
3. Via the VPN, SSH to <TEAM_NAME>-mgmt-01-vsi.
4. Using the commandline noted earlier install the Agent


## Verify the Agent Connection and Status

### Step 1: Verify the configuration

1. SSH to the Linux VM yo installed the agent on,
2. Use the following command to review the agent configuration `cat /opt/draios/etc/dragent.yaml`.

### Step 2: Verify Agent Status

1. Use one of the followin commands `service dragent status` or `systemctl status dragent` to see that the agent is `enabled` and `active`.
2. Use `ps -ef | grep sysdig` to see that the agent process is running

### Step 3: Verifying results in the UI

After a few minutes, you can check the results in the UI for your **Vulnerabilities**, the **Posture validation** and, if any, **Threats** detected in your host.

1. Navigate to the IBM Cloud portal.
2. Select **Resource list** from the navigation menu.
3. In the **Product filter** type `workload`, then select your Workload Protection instance.
4. From the instance resource page click **Dashboard**.
5. Verify your agent is connected correctly under **Integrations / Data Sources / Sysdig Agents**.
6. Check that your host appears under Inventory. You can filter by the hostname (Resource Name) or type of operating system (Platform).

## Explore the UI

### Step 1: Compliance

In the UI and documentation Compliances is also known as **Posture Management**. Workload Protection automates compliance checks against various industry standards and best practices, including the CIS Linux Benchmark. It identifies misconfigurations and violations and suggests remediation. An understanding of the following terminology will be useful:

* **Policy** - A policy is a group of business, security, compliance, and operations requirements that represent a compliance standard (for example, NIST SP 800-53 Rev 5), benchmark (for example, CIS Distribution Independent Linux Benchmark (Level 1 - Server) v2.0.0) or business policy. A policy includes one or more controls to define a compliance standard, a benchmark, or a business policy.
* **Control** - A control identifies a potential issue or violation within the environment and the solution to remediate the situation. A control describes a rule, the code that is run to evaluate it, and a remediation playbook to fix the violation that might be detected.
* **Zone** - A zone is a group of resources that you want to associate together for management and reporting.
* **Entire infrastructure** - This zone is automatically created. This zone includes all connected data sources. CIS policies are automatically applied to this zone. Findings are reported on the Compliance page.

Compliance results will be shown within a few minutes of installation and scans are refreshed every 24 hours.

1. Navigate to **Compliance / Overview** in the Workload Protection UI.
2. As we have not setup any Zones the Agents will have been placed into the `Entire Infrastructure` zone.
3. In the `Select Zones` select `Entire Infrastructure` and in `Selct policies` select `CIS Distribution Independent Linux`.
4. Select a Policy, **CIS Linux Benchmark**.
5. Select `3.2.2 Ensure ICMP redirects are not accepted (Scored)`.
6. Select `Show Results` next to `sysctl reports appropriate net.ipv4.conf.default.accept_source`
7. Review the information in the panel,
8. In the `RESOURCES EVALUATION` section click on the `View remediation`.
9.  Review the remediation in the new panel.
10. Repeat for other failed checks that are of interest to you.
11. Review the hardening script at [Scripts/HOL8/cis-hardening.sh](https://github.com/neil1taylor/HOL-VPC-PowerVS/blob/main/Scripts/HOL8/cis-hardening.sh)
12. In an SSH session to the Ubuntu Management VSI use the command `curl -sSL https://raw.githubusercontent.com/neil1taylor/HOL-VPC-PowerVS/refs/heads/main/Scripts/HOL8/cis-hardening.sh | sudo bash` to download and run the hardening script.
13. You will not be able to see the results of the hardening until the compliance scan is re-run. This can be triggered via the API, but we will wait until the next day to see the changes

### Step 2: Vulnerability Management (Host Scanning)

The Workload Protection agent scans host packages to detect associated vulnerabilities and prioritizes them based on severity and the availability of fixed versions. Workload Protection streamlines vulnerability prioritization, enabling more efficient patching efforts by focusing on real-world exposure. You can expect the results of a scan to be visible in the UI within 15 minutes max. Scans are refreshed every 12 hours.

1. In the Workload Protection UI, navigate to **Vulnerabilities / Findings / Runtime**.
2. In the **Asset** section select the management VSI.
3. Select a package and explore the detailed information available.

### Step 3: Threat Detection and Response (Server EDR)

Workload Protection instruments Linux hosts via eBPF to inspect all system activity through system calls with minimal performance impact. It uses thousands of out-of-the-box policies, updated weekly by the Sysdig Threat Research team, and supports custom rules using Falco language. It can also detect malware and perform behavioral analysis.

In this demo scenario we will simulate an attack.

1. Navigate to **Policies / Threat Destection / Runtime Policies**.
2. Review the policies that are available, and those that are enabled. The policies applicable to Linux are under **Workload**.
3. Under **Workload**, select the policy **Sysdig Runtime Threat Detection** and review the rules.
4. Now select **Sysdig Runtime Threat Intelligence**, scroll to **Malicious filenames written** and open the tab.
5. In the **condition** section click on **malicious_filenames** and review the **items**. Note that one of the items is called **packetcrypt**
6. In an ssh session to the Linux management VSI, type `touch packetcrypt` to create a file named `packetcrypt`
7. In the Workload Protection UI, navigate to **Threats / Host & container**.
8. Review the threat event.
9. Navigate to **Threats / Investigate / Activity Audit**.
10. Review the list and find the data source `cmd` for the `touch` command. Click the entry and review the details

### Step 4: Create a preemptive blocking policy

When a policy for preemptive blocking is configured, attempts to execute a blacklisted binary will be blocked by killing the process. In this step we will:

* Install `ncat`.
* Run `ncat` to create a local server to show that it works.
* Create a rule and attach it to a policy that blocks `ncat` on the host.
* Run `ncat` and see that it is blocked.

1. In an SSH session on the Linux management VSI,enter `sudo apt install ncat -y`.
2. Once installed run `netcat -lvp 9999`. You should see `Listening on 0.0.0.0 9999`
3. Stop the process with `cntrl + c`.
4. Via the Workload Protection UI navigate to **Policies / Rules Library / Rules**.
5. Click **Add Rule / Workload**.
6. In the form enter the following and then **Save**:
      * **Name**: `Block ncat usage`
      * **Description**: `Detect and block usage of ncat`
      * **Condition**: `proc.name in ("ncat", "netcat") and evt.type = execve`
      * **Output**: `"Blocked netcat usage (user=%user.name command=%proc.cmdline)"`
      * **Priority**: `ERROR`
      * **Tags**: `network, blocking`
7. Select **Policies / Threat Detection / Runtime Policies**.
8. Click **Add Policy**, and select **Workload**.
9. In the form enter the following abd then **Save**:
      * **Name**: `Demo Policy`
      * **Description**: `My demo policy`
      * **Severity**: `High`
      * **Scope**: `Custom Scope`, `host.hostName is <TEAM_NAME>-mgmt-01-vsi`
      * **Policy Rules**: Use the Import from Library button and then search using `Block ncat usage`
      * **Kill Process**: Enabled
10. Wait a few minutes for the policy to be synchronized to the agent.
11. In the SSH session with the Linux management VSI, run `netcat -lvp 9999`. This time the process should be blocked with `Listening on 0.0.0.0 9999 Killed`

If you still have time in the hands on lab:

* Repeat the steps but use the Windows Management server.
* Configure Zones and add policies to these zones.

### Step 5: Review the DORA policy

1. In the Workload Protection UI, navigate to **Policies / Posture / Policies**.
2. In the Search bar enter `DORA`.
3. Click on `Digital Operational Resilience Act (DORA) - Regulation (EU) 2022/2554`.
4. Select `Requirements & Controls`.
5. Under `Article 5, Governance and organisation`, select `Art 5.2(b)` and review the 19 controls.
6. Click `Article 12, Backup policies and procedures, restoration and recovery procedures and methods`. In the search bar type `VPC`. Review the 12 controls.
7. On the `Check whether Application Load Balancer for VPC has health check configured when created` control select the menu icon and select `Control Details`.
   1. Note what other policies include this control.
   2. Click on each of the following in turn; `Code`, `Remediation Playbook` and `Parameters`.

## Questions

1. What is the primary purpose of IBM Cloud Security and Compliance Center Workload Protection?
    A. To manage billing and invoicing for cloud resources.
    B. To find and prioritize software vulnerabilities, detect and respond to threats, and manage configurations, permissions, and compliance from source to run.
    C. To provide general cloud infrastructure monitoring.
    D. To solely focus on network performance optimization. 
2. Which of the following capabilities are supported by the data collected by the IBM Cloud Security and Compliance Center Workload Protection agent?
    A. Only intrusion detection and incident response.
    B. Intrusion detection, posture management, vulnerability scanning, and incident response capabilities.
    C. Just billing information and resource tagging.
    D. Exclusively network traffic analysis. 
3. What core technology does Server Endpoint Detection and Response (EDR) use in Linux to inspect all system activity with minimal performance impact on hosts, VMs, and Kubernetes/OpenShift clusters?
4. Which of the following cloud environments are supported for compliance validation by the Workload Protection posture module?
    A. IBM Cloud only.
    B. IBM Cloud, AWS, Azure, and Google Cloud only.
    C. IBM Cloud, AWS, Azure, GCP,  virtual machines (VSIs for VPC, VMware, PowerVS, IBM Z with Linux), Kubernetes, and OpenShift.
    D. On-premise environments exclusively.
5. In IBM Cloud Security and Compliance Center Workload Protection, what is a "zone," and how is it defined? 
6. What is "risk acceptance" in Workload Protection, and what options are available when accepting a risk?
7. When implementing Context-Based Restrictions (CBR) for IBM Cloud Security and Compliance Center Workload Protection resources, what is a crucial point regarding their effect on agents?
8. When deploying a Workload Protection agent on a Linux host, what command can be run to verify if the agent is running, and where would you typically locate its latest log files? 
9. What open-source language is used to create and customize rules for Server Endpoint Detection and Response (EDR) in Workload Protection?
10. When implementing CSPM for IBM Cloud, what IBM Cloud service and its feature is used for gathering all resource configuration details, and is there a cost associated with this feature? 

## Additional Information

* **Purpose and Scope of CSPM**: CSPM provides a unified and centralised platform to manage the security and compliance of applications, workloads, and infrastructure across various environments, including IBM Cloud, other cloud providers (AWS, Azure, GCP), and on-premise setups. Its core purpose is to identify misconfigurations and validate compliance against numerous industry standards and laws.
* **Key Features and Methodology**:
    * **Configuration Validation**: CSPM automatically evaluates your resources against predefined or custom policies and controls to identify failing configurations. These policies can be based on dozens of out-of-the-box frameworks such as PCI, DORA, CIS, NIST, etc.
    * **Identity and Access Management**: CSPM includes Cloud Infrastructure Entitlement Management (CIEM) capabilities to gain visibility into cloud identities, manage permissions, identify inactive users or those with excessive permissions, and optimise access policies to grant just enough privileges.
    * **Infrastructure as Code (IaC) Security Posture**: It can analyse the security posture of IaC, including Terraform, CloudFormation, Helm charts, or YAML manifests.
    * **Risk Prioritisation**: CSPM provides advanced risk prioritisation by correlating misconfigurations, public exposure, in-use context (such as vulnerabilities and active permissions), and high-confidence threat detection. Risks can be visualised through a correlation vector map to provide full situational awareness beyond static posture evaluation.
    * **Remediation and Reporting**: It offers assisted remediation instructions to fix failing controls. You can also accept known risks temporarily or permanently, which allows the resource to pass evaluation and improves the compliance score for a zone. Compliance results are typically evaluated once daily and can be reviewed in the UI, with options to download reports as CSV or PDF files.

CSPM requires trusted profiles to enable the IBM Cloud Security and Compliance Center Workload Protection service to interact with and collect resource configurations from other IBM Cloud services. Trusted profiles provide a mechanism for managing permissions without assigning access directly to individual users or service IDs. For Workload Protection to perform CSPM, it needs to collect detailed configuration data about your IBM Cloud resources. This data is aggregated by the App Configuration service. The trusted profile grants App Configuration the necessary access policies, such as "Viewer" and "Service Configuration Reader" roles for "All Account Management services" and "All Identity and Access enabled services," to perform this collection. Two trusted profiles are configured:

* Trusted profile for Workload Protection interaction with Config Service.
* Trusted profile for App Configuration for collecting service configuration.
