# Hands-on Lab 8: Protecting Workloads with IBM Cloud Security and Compliance Center Workload Protection

What you will learn:

* Overview of IBM Cloud Security and Compliance Center Workload Protection.
* Installing and configuring Workload Protection agents for VPC and PowerVS instances.
* Policy creation: vulnerability management, compliance enforcement, and threat detection.
* Real-time security event monitoring and automated response workflows.

## Overview

IBM Cloud Security and Compliance Center Workload Protection is a comprehensive platform designed to find and prioritise software vulnerabilities, detect and respond to threats, and manage configurations, permissions, and compliance from source to runtime in various environments, including hosts and VMs.

While Workload Protection offers **unified and centralized management** for the security and compliance of applications, workloads, and infrastructure across different environments, including IBM Cloud, other cloud providers (like AWS, Azure, GCP), and on-premises systems, including hosts, virtual machines (VMs), containers, and Kubernetes/OpenShift environments, we will focus on Linux and Windows hosts.

For standalone Linux and Windows hosts, Workload Protection provides several key features:

*   **Threat Detection and Response (Server Endpoint Detection and Response - EDR)**:
    *   This feature instruments hosts and VMs through eBPF to inspect all system activity via system calls with a minimal performance footprint.
    *   It helps identify threats and suspicious activity based on application, network, and host activity by processing syscall events.
    *   You can investigate incidents with detailed system captures.
    *   Preemptive blocking is available to prevent blacklisted or malicious binaries from execution.
    *   Advanced remediation allows for automatic execution of corrective actions, such as killing processes or containers.
    *   Detection rules like File Integrity Monitoring (FIM) can be defined per scope (path, filename, command, user, etc.) to detect various activities.
    *   Malware Control Policies can be created to detect malware execution using known malware hashes and YARA rules.
*   **Posture Management (Cloud Security Posture Management - CSPM)**:
    *   Workload Protection automates compliance checks for various industry standards and best practices, including CIS Linux Benchmark and CIS Windows Server Benchmarks.
    *   It scans host configuration files for compliance and benchmarks.
    *   For Windows Servers, CIS Windows Server 2022 Benchmark v3.0.0 and CIS Windows Server 2019 Benchmark v3.0.1 Posture policies are provided.
    *   For AIX on PowerVS, it supports CIS AIX Benchmark.
    *   Compliance results are persisted in an inventory, which enhances resource visibility and prioritization for remediation of violations.
    *   It offers an **inventory of all your Cloud assets** (compute resources, managed services, identities, entitlements) and hosts, VMs, and clusters, whether in the Cloud or on-premises.
    *   Users can review host entries in the Inventory by filtering by hostname (`Resource Name`) or operating system type (`Platform`).
*   **Vulnerability Management (Host Scanning)**:
    *   This feature scans host packages and detects associated vulnerabilities.
    *   It identifies the resolution priority based on available fixed versions and severity.
    *   For Windows Servers, it provides coverage for operating system vulnerabilities from Microsoft Security Response Center and detects non-operating system package vulnerabilities.
    *   For Linux hosts, it adds **in-use runtime context** to filter out vulnerabilities exposed on running applications, which can reduce the number of vulnerabilities to immediately fix.
    *   The Inventory also allows tracking vulnerabilities and analyzed packages of images.

### Supported Host Environments

Workload Protection supports deploying agents on a variety of hosts:

*   **Linux hosts**: This includes IBM Cloud, other cloud providers (AWS, Azure, GCP), or on-premises. Support exists for Debian, Ubuntu, CentOS, RHEL, Fedora, Amazon AMI, and Amazon Linux. Power Virtual Server (PowerVS) Linux hosts are also supported.
*   **AIX servers on PowerVS**: Posture compliance for AIX operating system is provided.
*   **Windows Servers**: Compliance scanning and host scanning for standalone Windows Server hosts are supported.

The Workload Protection agent is deployed on target hosts to collect events and protect workloads.



**Verifying Results in UI (for Linux hosts)**:
*   Access your Workload Protection instance and verify your agent is connected under **Integrations / Data Sources / Sysdig Agents**.
*   Review your host under **Inventory** (filter by hostname or Platform).
*   See vulnerability reports under **Vulnerabilities / Runtime** (search by hostname or `asset.type is host`).
*   View posture validation results under **Posture/Compliance**.
*   Check for detected threats under **Threats**.


## Resources that will be deployed in this HOL

In this HOL, you will deploy the following:

Resource Type | Name | Notes
---------|----------|---------


## Scenario

In this HOL we will:

* Step 1: Provisioning a Workload Protection instance

### Step 1: Provisioning a Workload Protection instance

1. Using the information at [Provisioning an instance](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-provision&interface=ui) and using either the UI or CLI, provision an instance of Workload Protection:

* **Location**: Dallas (us-south)
* **Plan**: Free Trial
* **Name**: <TEAM_NAME>-scc-wp-svc
* **Resource Group**: <TEAM_NAME>-services-rg
* **Tags**: `env:mgmt`
* **Enable Cloud Security Posture Management (CSPM) for your IBM Cloud account**: Disabled

We have disabled **Cloud Security Posture Management** in this hands on lab so that we can focus on the workload protection features. If you have time at the end of this lab then enable CSPM and investigate,

### Step 2: Install a Workload Protection Agent for Linux

1. On the Workload Protection instance page, click Sources then Linux.
2. Note the commandline instructions to install via the provate endpoint.
3. Via the VPN, SSH to <TEAM_NAME>-mgmt-01-vsi.
4. Using the commandline noted earlier install the Agent


## Verify the Agent Connection

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

### Step 4: Compliance

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
6. Select `3.2.1 Ensure source routed packets are not accepted (Scoredd)`.
7. Select `Show Results` next to `sysctl reports appropriate net.ipv4.conf.default.accept_source`
8. Review the information in the panel,
9. In the `RESOURCES EVALUATION` section click on the `View remediation`.
10. Review the remediation in the new panel.
11. Repeat for other failed checks that are of interest to you.
12. Review the hardening script at [Scripts/HOL8/cis-hardening.sh](https://github.com/neil1taylor/HOL-VPC-PowerVS/blob/main/Scripts/HOL8/cis-hardening.sh)
13. In an SSH session to the Ubuntu Management VSI use the command `curl -sSL https://raw.githubusercontent.com/neil1taylor/HOL-VPC-PowerVS/refs/heads/main/Scripts/HOL8/cis-hardening.sh | sudo bash` to download and run the hardening script. 

### Step 5: Vulnerability Management (Host Scanning)

The Workload Protection agent scans host packages to detect associated vulnerabilities and prioritizes them based on severity and the availability of fixed versions. Workload Protection streamlines vulnerability prioritization, enabling more efficient patching efforts by focusing on real-world exposure. You can expect the results of a scan to be visible in the UI within 15 minutes max. Scans are refreshed every 12 hours.

1. In the Workload Protection UI, navigate to **Vulnerabilities / Findings / Runtime**.
2. In the **Asset** section select the management VSI.
3. Select a package and explore the detailed information available.



3.
Threat Detection and Response (Server EDR)
◦
Concept: Workload Protection instruments Linux hosts via eBPF to inspect all system activity through system calls with minimal performance impact. It uses thousands of out-of-the-box policies, updated weekly by the Threat Research team, and supports custom rules using Falco language. It can also detect malware and perform behavioral analysis.
◦
Demo Scenario (Simulated Attack):
▪
Pre-Demo Setup (if time permits): Briefly show enabling or customising a runtime policy under Policies / Runtime Policies in the "Linux Workload" section. For example, a File Integrity Monitoring (FIM) rule. You could also show a Malware Control Policy being created to detect execution based on hashes or YARA rules.
▪
Simulate Malicious Activity on the Linux Host:
•
File Integrity Violation: On the Linux host, demonstrate modifying a critical system file, such as /etc/passwd or /etc/hosts, or creating a suspicious file in a sensitive directory. For example, echo "malicious_entry" >> /etc/passwd.
•
Suspicious Command Execution: Run a command that typically indicates suspicious activity, like attempting to access /dev/mem or using strace on a sensitive process. Or, try to execute a binary that could be associated with known malware (if a custom Malware Control Policy with a YARA rule for a harmless "test malware" signature is set up).
•
Preemptive Blocking (if possible): If a policy for preemptive blocking is configured, attempt to execute a blacklisted binary and show it being prevented.
▪
Observe Detection in UI:
•
Quickly navigate to Threats in the Workload Protection UI.
•
Show the real-time alert for the simulated activity. Click into the alert to view the detailed system capture, which provides full context of the incident, including executed commands, file changes, and network connections.
•
Discuss how Workload Protection can also perform advanced remediation actions like killing processes or containers automatically.
•
Mention the capability to forward security events to SIEM tools like Splunk or QRadar for further correlation.
◦
Insight: This demonstrates Workload Protection's ability to provide deep runtime visibility, detect anomalies, and enable rapid incident response, even capturing forensic data for in-depth investigation.