# Hands-on Lab 6 - Monitoring: Configuring Observability services to monitor IBM Cloud, VPC and PowerVS

## Objective

Learn how to configure and manage Observability services to monitor your workloads, focusing on IBM Cloud VPC and IBM Power Virtual Server.

What you will learn:

- Configure IBM Cloud Observability services in an IBM Cloud account
- Core features in IBM Cloud Logs and IBM Cloud Monitoring
- Monitoring IBM Cloud VPC using IBM Cloud Logs and IBM Cloud Monitoring
- Building views and dashboards, configuring alerts for automated incident response.
- Configuring PowerVS to send logs to IBM Cloud Logs and metrics to IBM Cloud Monitoring
- Integrating third-party observability tools with IBM Cloud.


## Overview

Cloud governance is a framework of guidelines, policies, and practices that help standardize the adoption and management of cloud services securely, mitigate risks, meet compliance requirements, and optimize costs.

_Observability is a core displine of Cloud governance._

Observability involves monitoring and understanding the health and performance of systems that run in the cloud. By analyzing data such as logs, and metrics, you can identify issues and troubleshoot problems.

- Metrics are numerical data points that quantify system behavior, like CPU usage or network traffic.
- Logs are records of events that occur within the system, and provide detailed information about system activity.

In IBM Cloud, you can find the following Observability services:

- **IBM Cloud Logs**

    IBM Cloud Logs is a scalable logging service that persists logs and provides users with capabilities for querying, tailing, and visualizing logs. You can get real-time insights on IBM Cloud services, infrastructure, and applications. You can analyze logs for troubleshooting, and alerting, as well as, use the data for long-term trend analysis.

    Logs are comprised of events that are typically human-readable and have different formats, for example, unstructured text, JSON, delimiter-separated values, key-value pairs, and so on. The IBM Cloud Logs service can manage general purpose application logs, platform logs, or structured audit events. IBM Cloud Logs can be used with logs from both IBM Cloud services and customer applications, in IBM Cloud and outside IBM Cloud.


- **IBM Cloud Activity Tracker Event Routing**

    With IBM Cloud Activity Tracker Event Routing, you configure how to route auditing events in your IBM Cloud account.

    Auditing events are critical data for security operations and a key element for meeting compliance requirements.

- **IBM Cloud Logs Routing**

    With IBM Cloud Logs Routing, you configure how to route platform logs that are generated by services running in your IBM Cloud account.

- **IBM Cloud Metrics Routing**

    With IBM Cloud Metrics Routing, you configure the routing of platform metrics that are generated in your IBM Cloud account.

    Platform metrics are key to monitor the health and status of IBM Cloud services.

- **IBM Cloud Monitoring**

    IBM Cloud Monitoring is a cloud-native, and container-intelligence management system that you can include as part of your IBM Cloud architecture to gain operational visibility into the performance and health of your applications, services, and platforms. It offers administrators, DevOps teams and developers full-stack telemetry with advanced features to monitor and troubleshoot, define alerts, and design custom dashboards.

Reference information:
- [IBM Cloud Activity Tracker Event Routing](https://cloud.ibm.com/docs/atracker?topic=atracker-getting-started)
- [IBM Cloud Logs Routing](https://cloud.ibm.com/docs/logs-router?topic=logs-router-getting-started)
- [IBM Cloud Metrics Routing](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-getting-started)
- [IBM Cloud Logs](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-getting-started)
- [IBM Cloud Monitoring](https://cloud.ibm.com/docs/monitoring?topic=monitoring-getting-started)

## What you will learn:

- Deploy and configure IBM Cloud Observability services
- How to monitor in IBM Cloud user actions and relevant security events related to IBM Cloud VPC, IBM Power Virtual Server, and other IBM Cloud services.
- Configure a Linux hosts on a PowerVS workspace to forward logs to the IBM Cloud Logs service.
- Configure a Linux hosts on a PowerVS workspace to forward metrics to the IBM Cloud Monitoring service
- Building dashboards, setting alerts, and automated incident response.
- Integrating third-party observability tools with IBM Cloud

## Prerequisites:

* An IBM Cloud Account with Power Virtual Server access.
* IBM Cloud CLI installed and configured / access to IBM Cloud console.
* An SSH key uploaded to your Power Virtual Server workspace.
* Familiarity with curl for making REST API calls.
* Basic understanding of JSON.
* jq installed (highly recommended for parsing JSON responses from API calls)

   `yum install jq (RHEL/CentOS) or brew install jq (macOS).`

Your IBMID must have assigned IAM policies for each of the Observability services.


## Resources that will be deployed in this HOL

In this HOL, you will deploy the following resources:

Service  | Resource Type | Name     | Notes
---------|---------------|----------|---------
Activity Tracker Event Routing | target | <TEAM_NAME>-target |
Activity Tracker Event Routing | route  | <TEAM_NAME>-route |
Metrics Routing | target | <TEAM_NAME>-target |
Metrics Routing | target | <TEAM_NAME>-route |
Logs Routing | target | |
Cloud Logs | instance | <TEAM_NAME>-cl-instance |
Monitoring | instance | <TEAM_NAME>-mon-instance |
Cloud Object Storage | bucket | <TEAM_NAME>-cl-bucket |
Event Notifications | topic | <TEAM_NAME>-topic |
Event Notifications | subscription | <TEAM_NAME>-subscription |

This document references:

- `<TEAM_NAME>` this is your team name and ID e.g. `team`

## Configure Observability in the account

### Step 1: Provision and configure IBM Cloud Monitoring in the account

Complete the following steps to provision an instance of IBM Cloud Monitoring:
1. Log in to your IBM Cloud account.
1. Click Catalog. The list of the services that are available in IBM Cloud opens.
1. To filter the list of services that is displayed, select the **Logging and Monitoring** category.
1. Click the **IBM Cloud Monitoring** tile.
1. Select the location where you plan to provision the instance. Choose `eu-es`
1. Select the **Graduated Tier** service plan.
1. Enter a name for the service instance. Use <TEAM_NAME>-mon-instance
1. Select the resource group for your team <TEAM_NAME>-management-rg. By default, the Default resource group is set.
1. Enable platform metrics.
1. Click **Create**.
After you provision an instance, the UI opens.

Reference information:
- [Provision an instance through the UI](https://cloud.ibm.com/docs/monitoring?topic=monitoring-provision#provision_ui)
- [Provision an instance by using the CLI](https://cloud.ibm.com/docs/monitoring?topic=monitoring-provision#provision_cli)
- [Provision an instance by using terraform](https://cloud.ibm.com/docs/monitoring?topic=monitoring-terraform-setup)


### Step 2: Configure IBM Cloud Metrics Routing in the account

Complete the following steps to configure IBM Cloud Metrics Routing to route metrics that are generated by IBM Cloud services in the account to a central Monitoring instance:

1. Configure a service-to-service authorization to your IBM Cloud Monitoring instance.

    You must use IBM Cloud Identity and Access Management (IAM) to create an authorization that grants IBM Cloud Metrics Routing access to IBM Cloud Monitoring so the IBM Cloud Metrics Routing service can send metrics to your IBM Cloud Monitoring instance.

    For more information, see [Creating a S2S authorization to grant access to the IBM Cloud Monitoring service](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-iam-service-auth&interface=ui).

1. Create a target from the Observability dashboard in the IBM Cloud.

    1. Go to **Observability > Monitoring > Routing**.
    1. In the *Targets* section, click **Create**.
    1. Select your instance of IBM Cloud Monitoring under *Choose destination*.
    1. Select **Create target**.

1. Create a route to define the rules that determine where metrics are routed in your account. For example, you can define a route that routes metrics from 2 different regions.

    1. Go to **Observability > Monitoring > Routing**.
    1. In the *Routes* section, click **Create**.
    1. In the *Routing rules* section, modify Rule 1:

        Select **Send** for the rule to route metrics to the associated targets.

        Select **Drop** for the rule to drop metrics matching this rule.

        Add the inclusion filters to determine the metrics routed to the targets specified in the rule. Select **Location in Dallas (us-south) Madrid (eu-es)**.

        To add multiple inclusion filters, click **Add filter** to add additional filters.

    1. In the *Targets* section, select yout monitoring target from the list.

    1. [Optional] Click **Add rule** to add additional rules to the route. The order of route rules affects the routing behavior. Rules are processed in order and once a rule is matched, the subsequent rules are not processed. The order of the routing rules can be changed by clicking the up and down arrows to the right of each rule definition.

        _Note: You can configure up to 10 rules per route._

    1. Click **Next**.
    1. Review the route definition ensuring the order of the rules is as intended.
    1. Enter a name for the route <TEAM_NAME>-mon-route.
    1. Click **Create**.


Reference information:
- [Managing IBM Cloud Monitoring targets through the UI](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-target-manage&interface=ui)
- [Managing IBM Cloud Monitoring targets through the CLI](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-target-manage&interface=cli)
- [Managing IBM Cloud Monitoring targets through the API](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-target-manage&interface=api)
- [Managing IBM Cloud Monitoring targets by using terraform](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/metrics_router_target)
- [Managing IBM Cloud Monitoring routes through the UI](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-route-manage&interface=ui)
- [Managing IBM Cloud Monitoring routes through the CLI](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-route-manage&interface=cli)
- [Managing IBM Cloud Monitoring routes through the API](https://cloud.ibm.com/docs/metrics-router?topic=metrics-router-route-manage&interface=api)
- [Managing IBM Cloud Monitoring routes by using terraform](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/metrics_router_route)



## Monitoring

In IBM Cloud Monitoring, you can monitor the performance and overall system health of your organization. You can collect metrics from a number of platforms, orchestrators, and a wide range of applications such as Prometheus, JMX, StatsD, Kubernetes, and other application stacks, that are available in the IBM Cloud, outside the IBM Cloud, or on-prem. You can also add more metrics by creating custom metrics and adding integrations.

### Dashboards

You can use dashboards to monitor your infrastructure, applications, and services. You can use pre-defined dashboards. You can also create custom dashboards through the Web UI or programmatically. For more information, see [Working with dashboards](https://cloud.ibm.com/docs/monitoring?topic=monitoring-dashboards).

Through the Monitoring UI, you can analyze data in the Advisor tab, the Explore tab, and in the Dashboard tab. You monitor the data through metric views and dashboards.

Consider the following information when monitoring your data:
- In the Explorer tab, you can monitor individual metrics.
- In the Advisor tab, you can monitor Kubernetes or host level metrics.
- In the Dashboard tab, you can monitor through panels predefined dashboards or custom ones and get a specialized insight into network data, application data, topology, services, hosts, and containers. A panel displays a metric or group of metrics in a dashboard.
For each metric view and dashboard, you can define the scope of the data, how to aggregate data, and what time and group filters to apply to the data. For more information, see Managing panels.

Pre-defined dashboards appear automatically when the required metrics are available in the Monitoring instance.

Complete the following steps to see the list of predefined dashboards that are available:
1. Go to **Observability > Monitoring > Instances**.
1. Identify your Monitoring instance **SCC-WP-SAP-DEMO**, and click **Dashboard**.
1. Go to **Dashboards**.
1. In the *Dashboard Library*, under **IBM**, you can find the pre-defined dashboards that are available for use. For example, explore some of the following predefined dashboards.

    Activity Tracker Event Routing - Overview
    DNS Services - Metrics Summary
    IBM COS Account Summary
    IBM COS Bucket
    IBM Schematics Summary - Charts
    IBM Schematics Summary - Counts
    Metrics Routing - Overview
    Secrets Manager
    VPC Infrastructure Service Resource Quota Overview
    Virtual Server for VPC Overview


You cannot modify predefined dashboards, however, you can copy a predefined dashboard if you need to customize it.

Complete the following steps to create a copy of a dashboard for your team:
1. Go to **Observability > Monitoring > Instances**.
1. Identify your Monitoring instance, and click **Dashboard**.
1. Go to **Dashboards**.
1. In the *Dashboard Library*, under **IBM**, select a predefined dashboard to copy.
1. Click **Copy to my Dashboards**.
1. Enter a dashboard name. For example add a prefix **[<TEAM_NAME>]** to the dashboard name to make it easy to identify.
1. Click **Create and Open**.

You can now customize the widgets in your copy of the dashboard.

### Alerts

In the IBM Cloud Monitoring service, you can configure single alerts and multi-condition alerts to notify about problems that may require attention. When an alert is triggered, you can be notified through 1 or more notification channels. An alert definition can generate multi-channel notifications.

An alert is a notification event that you can use to warn about situations that require attention. Each alert has a severity status. This status informs you about the criticality of the information it reports on.

When you define an alert, you must define the condition that triggers the notification, and one or more notification channels through which you want to be notified. You must also define the severity of the alert, and the type of alert. For more information about how to configure an alert, see Configuring an alert.

By default, severity is set to warning. You can set the severity of an alert to any of the following values: emergency, alert, critical, error, warning, notice, informational, debug*

You can define an alert on a single metric or a set of metrics to notify of events or issues that you want to monitor.

For more information, see [Working with alerts and events](https://cloud.ibm.com/docs/monitoring?topic=monitoring-alerts).



## IBM Cloud VPC

A virtual private cloud (VPC) is a secure, isolated virtual network that combines the security of a private cloud with the availability and scalability of IBM's public cloud.

VPC generates the following platform telemetry data:

- Activity Tracking events that you can use to monitor and report VPC activity in your account. For more information, see [Activity tracking events for IBM Cloud VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-at_events&interface=ui)

- Platform logs that you can use to investigate abnormal activity and critical actions in your account, and troubleshoot problems. For more information, see [Logging for VPC](https://cloud.ibm.com/docs/vpc?topic=vpc-logging&interface=ui)

- Metrics that you can use to monitor the health and quotas of selected VPC resources.

    - VPC virtual server instance: For more information, see [VPC virtual server instances metrics definitions](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-monitoring-metrics&interface=ui).

    - VPN gateway: You can monitor basic VPN metrics on IBM Cloud, such as the VPN gateway status, the VPN gateway packets input/output, and the VPN connection bytes input/output. These metrics are stored in IBM Cloud Monitoring. You can access metrics through the prebuilt dashboard. For more information, see [Monitoring VPN gateway for VPC metrics](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-monitoring-metrics&interface=ui).

    - VPN servers: For more information, see [Monitoring VPN servers](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-monitoring&interface=ui).

    - Network load balancer: For more information, see [Monitoring network load balancer metrics](https://cloud.ibm.com/docs/vpc?topic=vpc-nlb_monitoring-metrics).

    - Application load balancer: For more information, see [Monitoring application load balancer metrics](https://cloud.ibm.com/docs/vpc?topic=vpc-monitoring-metrics-alb).

    - Flow logs for VPC: For more information, see [Monitoring flow logs for VPC metrics](https://cloud.ibm.com/docs/vpc?topic=vpc-fl-monitoring-metrics).

    - VPC resource quota:  For more information, see [VPC resource quota overview metrics definitions for quota dashboard](https://cloud.ibm.com/docs/vpc?topic=vpc-vpc-quota-metrics&interface=ui)

You can use IBM Cloud Logs to visualize and alert on platform data that is generated in your account.
You can use IBM CLoud Monitoring to monitor the health and status of your VPC.


### Monitoring

Check the predefined VPC dashboards and take a look at the widget configuration and metrics collected:

- VPC Infrastructure Service Resource Quota Overview
- Virtual Server for VPC Overview
- DNS Services - Metrics Summary

For more information, see [VPC dashboards and service metric definitions](https://cloud.ibm.com/docs/vpc?topic=vpc-ibm-monitoring&interface=ui#vpc-metric-definitions).



## Sending notifications through IBM Cloud Event Notifications

You can configure alert in IBM Cloud Logs and IBM Cloud Monitoring that send notifications through IBM Clooud Event Notifications to different types of destinations.

Complete the following steps to configure alert notifications to be triggered through Event Notifications:
- [Configure alerts in IBM Cloud Monitoring that send email notifications](https://cloud.ibm.com/docs/monitoring?topic=monitoring-tutorial-en)
- [Configuring alerts in IBM Cloud Logs](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-alerts-config)


## Integrating third-party observability tools with IBM Cloud Observability services

You can integrate IBM Cloud Logs and IBM Cloud Monitoring with other third party observability tools by streaming data to IBM Cloud Event Streams.

Complete the following steps to configure streaming:

- [Integrating IBM Cloud Logs with Event Streams](https://cloud.ibm.com/docs/cloud-logs?topic=cloud-logs-streaming-config)
- [Streaming metrics to a Kafka service](https://cloud.ibm.com/docs/monitoring?topic=monitoring-data_streaming)


## Questions

1. What is the role of each Observability service?
2. What are the advantages and disadvantages of configuring a central architecture compared with a distributed architecture?
3. What services and features can you configure to detect spikes of logs promptly? And new errors? or new values of a specific field?
4. Can you outline the tasks and resources that you must configure to trigger an email alert? In Cloud Logs and in Monitoring.
5. Where do you monitor the alerts that are triggered? In Cloud Logs and in Monitoring.
6. Can you add data and enrich a log record?
7. When would you use the extract parsing rule? and the block rule?
8. When should you configure a logging agent?
9. How many query languages can you use to search data in Cloud Logs?
