# Hands on Lab - IBM Cloud VPC, PowerVS and SAP Technical Training Course

## Summary

The 5 day course outlined in this document covers IBM Cloud VPC, IAM, Power VS and SAP on IBM Cloud. The course spans 4 days while day 5 of the workshop will be for additional questions, and sessions for ad-hoc topics requested during the previous 4 days.

The workshop audience is expected to be 10 - 20 people from the SAP Operations Team. These participants are a mixture of architects, lead developers, lead operation experts, and lead solution engineers who have several years’ experience across the hyperscalers.

After the workshop the participants will function as teachers for the SAP operations team worldwide.

## Course Overview

This comprehensive hands-on technical course provides experienced IT professionals with a technical, hands-on deep dive into IBM Cloud Virtual Private Cloud (VPC), Identity and Access Management (IAM), Power Virtual Server (PowerVS) and SAP on IBM Cloud. 

Across 10 intensive hands-on lab sessions, participants will master the architecture, deployment, management, security, and optimization of these IBM Cloud services. From establishing network foundations to implementing compute and storage, this course balances theoretical knowledge with extensive hands-on labs.

Each of the hands-on lab sessions takes 1 to 2 hours (SAP specialty is currently 5 hrs but can be broken down into smaller HOLs) to complete and focuses on practical, real-world tasks using IBM Cloud services, infrastructure, and automation. The hands-on labs cover everything from core concepts to advanced deployment, operations, and hybrid integration scenarios. By the end of the course, you'll have the confidence to architect, deploy, and manage IBM Cloud VPC and PowerVS environments at an expert level.

You will learn:

* Core design patterns for secure, scalable cloud infrastructure.
* Practical deployment techniques using CLI, Terraform, and APIs.
* Troubleshooting, monitoring, and optimization best practices.
* Integration patterns for hybrid cloud scenarios.

Prior to each hands-on lab session, a 30 minute instructor-led session describes the hands-on lab and provides guidance and tips.

Participants will work in pairs to enable peer learning and be given access to an IBM Cloud account where they will follow the hands-on-lab guides, supervised by the on-site instructors. The guides are not complete step-by-step guides, so participants will need to do some limited research and discovery to progress through each of the steps to promote learning.

Each Hands-on Lab contains 10 questions that participants will need to answer. After each hands-on lab session, an instructor-led 30 minute session will review the answers and allow participants to ask further questions.

By completion of the hands-on lab sessions, participants will be able to confidently design, implement, and manage complex IBM Cloud infrastructures that leverage the unique capabilities of both VPC and PowerVS environments.

## Prerequisites

Before starting this series of hands-on labs, participants should have:

* Solid experience with general cloud concepts (e.g., AWS, Azure, GCP, OpenStack, VMware).
* Working knowledge of Linux system administration (basic CLI, SSH, networking).
* Familiarity with virtualization concepts (VMs, LPARs, networking, storage).
* Basic scripting experience (bash, PowerShell, or Python).
* Bonus: Experience with Terraform or any Infrastructure as Code (IaC) tool.

## Optional Pre-Work

Consider the following:

* IBM Cloud Essentials: Free online course, 8 hours in duration, available at https://cognitiveclass.ai/courses/ibm-cloud-essentials
* Terraform Tutorial – Getting started with Terraform: 40 minute read, available at https://spacelift.io/blog/terraform-tutorial

## Tools and Accounts Required

Ensure you have the following installed on your laptop before attending the hands-on-labs:

* Browser - Latest Chrome, Edge, or Firefox.
* SSH client - e.g., OpenSSH, PuTTY.
* IBM Cloud CLI: See Installing the stand-alone IBM Cloud CLI
* OpenVPN: See Download the official OpenVPN Connect client software developed and maintained by OpenVPN Inc.
* VS Code or IDE of choice: See Download Visual Studio Code.

## Certification Exam Alignment

After the hands-on labs consider:

[IBM Cloud Professional Architect](https://www.ibm.com/training/path/ibm-cloud-professional-architect-690)
[IBM Cloud Advanced Architect](https://www.ibm.com/training/path/ibm-cloud-advanced-architect-790)
[IBM Cloud Associate Site Reliability Engineer](https://www.ibm.com/training/path/ibm-cloud-associate-site-reliability-engineer-617)
[IBM Cloud Advocate v2](ttps://www.ibm.com/training/certification/ibm-certified-advocate-cloud-v2-C9003700)

## Hands-on Lab Synopses

### Hands-on Lab 1: Introduction to IBM Cloud VPC (120 mins)

What you will learn:

* Core concepts and architecture of IBM Cloud VPC.
* VPC components: subnets, security groups, ACLs, and virtual server instances.
* VPC management through UI, CLI, and API interfaces.
* Implementing VPC subnets, routing tables, and load balancers.
* Configuring public gateways and floating IP addresses.
* Audit logging and security monitoring in VPC environments.

### Hands-on Lab 2: IBM Cloud VPC VPN (120 mins)

What you will learn:

* VPC VPN concepts, types, and use cases.
* Configure and deploy VPN gateways within IBM Cloud VPC.
* Establish site-to-site and client-to-site VPN connections
* Monitor and troubleshoot VPN connectivity
* Apply security best practices for VPN implementations.

### Hands-on Lab 3: Storage Solutions in IBM Cloud VPC (120 mins)

What you will learn:

* Block storage provisioning and management in VPC.
* File and object storage integration with VPC resources.
* Storage performance tiers and optimization strategies.
* Snapshot and backup implementation for VPC storage.
* VPC encryption options and key management.

### Hands-on Lab 4: Introduction to IBM PowerVS (120 mins)

What you will learn:

* PowerVS fundamentals and service architecture.
* Virtual service instance deployment on PowerVS.
* PowerVS storage volume management.
* PowerVS management using console, CLI, and API interfaces.

### Hands-on Lab 5: Networking Between VPC and PowerVS (60 mins)

What you will learn:

* Establishing connectivity between VPC and PowerVS environments.
* Transit Gateway implementation for multi-region connectivity.
* Troubleshooting connectivity issues across hybrid infrastructures.

### Hands-on Lab 6: Monitoring, Observability, and Logging Across VPC and PowerVS (120 mins)

What you will learn:

* Deploying and configuring IBM Cloud Monitoring with Sysdig.
* Setting up IBM Log Analysis and integrating with VPC/PowerVS workloads.
* Custom metrics collection from virtual server instances.
* Building dashboards, setting alerts, and automated incident response.
* Integrating third-party observability tools with IBM Cloud.

### Hands-on Lab 7: Automation and Infrastructure as Code (60 mins)

What you will learn:

* Terraform implementation for VPC and PowerVS provisioning
* Ansible automation for configuration management
* Creating reusable templates and modules
* CI/CD pipeline integration for infrastructure deployment
* Managing infrastructure drift and version control

### Hands-on Lab 8: Protecting Workloads with IBM Cloud Security and Compliance Center Workload Protection (90 mins)

What you will learn:

* Overview of IBM Cloud Security and Compliance Center Workload Protection.
* Installing and configuring Workload Protection agents for VPC and PowerVS instances.
* Policy creation: vulnerability management, compliance enforcement, and threat detection.
* Real-time security event monitoring and automated response workflows.

### Hands-on Lab 9: IBM Cloud Identity and Access Management (IAM) for VPC and PowerVS (120 mins)

What you will learn:

* Configure and manage IBM Cloud IAM access policies.
* Implement role-based access control for users and service accounts.
* Leveraging service IDs and API keys.
* Using trusted profiles and context based restrictions.
* Monitor and audit IAM activities using Cloud Activity Tracker.

### Hands-on Lab 10: IBM Cloud for SAP Specialty (300 mins)

What you will learn:

* SAP Architecture in IBM Cloud.
* Compute and Storage Options for SAP.
* Network / Security and Certifications for SAP.
* SAP HANA Tuning on PowerVS.
* SAP HANA Backup COS.
 
## Course Agenda

The table below shows a suggested agenda:

Time Slot  |  Day 1  | Day 2 | Day 3 | Day 4 | Day 5 
---|---|---|---|---|--- 
09:00-09:30  |   HOL Intro | HOL 3 Intro | HOL 6 Intro | HOL 9 Intro | HOL 10 (continued)
09:30-10:00  |   HOL 1 Intro | HOL 3 (incl break) | HOL 6 (incl break) | HOL 9 (incl break)
10:00-10:30  |   HOL 1 (incl break) |  |  |  | 
10:30-11:00  |  |  |  |  | 
11:00-11:30  |  |  |  |  | 
11:30-12:00  |  | HOL 3 Q&A | HOL 6 Q&A | HOL 9 Q&A | 
12:00-12:30  |   Lunch | Lunch | Lunch | Lunch | 
12:30-13:00  |  |  |  |  | 
13:00-13:30  |   HOL 1 Q&A | HOL 4 Intro | HOL 7 Intro | HOL 10 (incl break) | 
13:30-14:00  |   HOL 2 Intro | HOL 4 | HOL 7 |  | 
14:00-14:30  |   HOL 2 (incl break) |  |  |  | 
14:30-15:00  |  | HOL 4 Q&A | HOL 7 Q&A and HOL 8 Intro |  | 
15:00-15:30  |  | HOL 5 Intro (incl break) | HOL 8 (incl break) |  | 
15:30-16:00  |  | HOL 5 |  |  | 
16:00-16:30  |   HOL 2 Q&A |  |  |  | 
16:30-17:00  |   End of Day Review | HOL 5 Q&A and End of Day Review | HOL 8 Q&A and End of Day Review | End of Day Review

