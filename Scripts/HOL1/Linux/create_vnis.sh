#!/bin/bash

# Script to create Virtual Network Interfaces (VNIs) in IBM Cloud
# using parameters from a CSV file

# Check if ibmcloud CLI is installed
if ! command -v ibmcloud &> /dev/null; then
    echo "Error: IBM Cloud CLI is not installed. Please install it first."
    echo "Visit: https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli"
    exit 1
fi

# Check if logged in to IBM Cloud
ibmcloud account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Not logged in to IBM Cloud. Please login first using:"
    echo "ibmcloud login"
    exit 1
fi

# Check if a CSV file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <csv_file>"
    echo "CSV format should have headers and contain: name,reserved_ip_name,subnet_name,security_group_name,resource_group_name,vpc_name"
    exit 1
fi

CSV_FILE=$1

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file not found: $CSV_FILE"
    exit 1
fi

# Check if the CSV file is readable
if [ ! -r "$CSV_FILE" ]; then
    echo "Error: Cannot read CSV file: $CSV_FILE"
    exit 1
fi

# Skip the header line and process each row in the CSV
echo "Starting VNI creation process..."
echo "--------------------------------"

# Counter for created VNIs
count=0

# Read the CSV file line by line (skipping the header)
tail -n +2 "$CSV_FILE" | while IFS=, read -r name reserved_ip_name subnet_name security_group_name resource_group_name vpc_name; do
    # Trim any whitespace
    name=$(echo "$name" | xargs)
    reserved_ip_name=$(echo "$reserved_ip_name" | xargs)
    subnet_name=$(echo "$subnet_name" | xargs)
    security_group_name=$(echo "$security_group_name" | xargs)
    resource_group_name=$(echo "$resource_group_name" | xargs)
    vpc_name=$(echo "$vpc_name" | xargs)
    
    echo "Creating VNI: $name"
    echo "  - VPC: $vpc_name"
    echo "  - Subnet: $subnet_name"
    echo "  - Reserved IP: $reserved_ip_name"
    echo "  - Security Group: $security_group_name"
    echo "  - Resource Group: $resource_group_name"
    
    # Target the resource group
    ibmcloud target -g "$resource_group_name"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to target resource group: $resource_group_name"
        continue
    fi
    
    # Create the VNI
    echo "Running command: ibmcloud is virtual-network-interface-create $name --vpc $vpc_name --subnet $subnet_name --reserved-ip $reserved_ip_name --security-group $security_group_name"
    
    ibmcloud is virtual-network-interface-create "$name" --vpc "$vpc_name" --subnet "$subnet_name" --reserved-ip "$reserved_ip_name" --security-group "$security_group_name"
    
    if [ $? -eq 0 ]; then
        echo "Successfully created VNI: $name"
        count=$((count+1))
    else
        echo "Failed to create VNI: $name"
    fi
    
    echo "--------------------------------"
done

echo "VNI creation process completed."
echo "Created $count VNIs successfully."