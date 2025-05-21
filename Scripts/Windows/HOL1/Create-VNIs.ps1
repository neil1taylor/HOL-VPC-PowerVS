# PowerShell Script to create Virtual Network Interfaces (VNIs) in IBM Cloud
# using parameters from a CSV file

# Check if ibmcloud CLI is installed
try {
    $ibmcloudVersion = ibmcloud --version
    Write-Host "IBM Cloud CLI found: $ibmcloudVersion"
}
catch {
    Write-Host "Error: IBM Cloud CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit: https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in to IBM Cloud
try {
    $accountInfo = ibmcloud account show 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Not logged in"
    }
}
catch {
    Write-Host "Error: Not logged in to IBM Cloud. Please login first using:" -ForegroundColor Red
    Write-Host "ibmcloud login" -ForegroundColor Yellow
    exit 1
}

# Check if a CSV file is provided
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$CsvFile
)

# Check if the CSV file exists
if (-not (Test-Path $CsvFile)) {
    Write-Host "Error: CSV file not found: $CsvFile" -ForegroundColor Red
    exit 1
}

# Check if the CSV file is readable
try {
    $null = Get-Content $CsvFile -ErrorAction Stop
}
catch {
    Write-Host "Error: Cannot read CSV file: $CsvFile" -ForegroundColor Red
    exit 1
}

# Process the CSV file
Write-Host "Starting VNI creation process..." -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan

# Counter for created VNIs
$count = 0

# Import the CSV file
try {
    $vniData = Import-Csv $CsvFile
}
catch {
    Write-Host "Error: Failed to parse CSV file. Please ensure it's properly formatted." -ForegroundColor Red
    exit 1
}

# Process each row in the CSV
foreach ($row in $vniData) {
    # Get values from CSV (and trim whitespace)
    $name = $row.name.Trim()
    $reserved_ip_name = $row.reserved_ip_name.Trim()
    $subnet_name = $row.subnet_name.Trim()
    $security_group_name = $row.security_group_name.Trim()
    $resource_group_name = $row.resource_group_name.Trim()
    $vpc_name = $row.vpc_name.Trim()
    
    Write-Host "Creating VNI: $name" -ForegroundColor Green
    Write-Host "  - VPC: $vpc_name"
    Write-Host "  - Subnet: $subnet_name"
    Write-Host "  - Reserved IP: $reserved_ip_name"
    Write-Host "  - Security Group: $security_group_name"
    Write-Host "  - Resource Group: $resource_group_name"
    
    # Target the resource group
    $targetOutput = ibmcloud target -g "$resource_group_name" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to target resource group: $resource_group_name" -ForegroundColor Red
        Write-Host $targetOutput -ForegroundColor Red
        continue
    }
    
    # Create the VNI
    Write-Host "Running command: ibmcloud is virtual-network-interface-create $name --vpc $vpc_name --subnet $subnet_name --reserved-ip $reserved_ip_name --security-group $security_group_name" -ForegroundColor Cyan
    
    $createOutput = ibmcloud is virtual-network-interface-create "$name" --vpc "$vpc_name" --subnet "$subnet_name" --reserved-ip "$reserved_ip_name" --security-group "$security_group_name" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully created VNI: $name" -ForegroundColor Green
        $count++
    }
    else {
        Write-Host "Failed to create VNI: $name" -ForegroundColor Red
        Write-Host $createOutput -ForegroundColor Red
    }
    
    Write-Host "--------------------------------" -ForegroundColor Cyan
}

Write-Host "VNI creation process completed." -ForegroundColor Green
Write-Host "Created $count VNIs successfully." -ForegroundColor Green