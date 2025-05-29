<powershell>
# Windows PowerShell user data script for IBM Cloud VPC VSI
# Installs IBM Cloud CLI, COS tools, Firefox, WinSCP, PuTTY, and VS Code

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Function to log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Write-Output $logMessage
    Add-Content -Path "C:\userdata.log" -Value $logMessage
}

Write-Log "Starting Windows user data script execution"

# Install Chocolatey package manager
Write-Log "Installing Chocolatey package manager"
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Log "Chocolatey installed successfully"
} catch {
    Write-Log "Error installing Chocolatey: $($_.Exception.Message)"
}

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install applications via Chocolatey
$apps = @(
    "firefox",
    "winscp", 
    "putty",
    "vscode",
    "git",
    "curl",
    "jq"
)

foreach ($app in $apps) {
    Write-Log "Installing $app"
    try {
        choco install $app -y --no-progress
        Write-Log "$app installed successfully"
    } catch {
        Write-Log "Error installing $app: $($_.Exception.Message)"
    }
}

# Install IBM Cloud CLI
Write-Log "Installing IBM Cloud CLI"
try {
    # Download IBM Cloud CLI installer
    $ibmCliUrl = "https://download.clis.cloud.ibm.com/ibm-cloud-cli/2.24.0/binaries/IBM_Cloud_CLI_2.24.0_windows_amd64.exe"
    $ibmCliInstaller = "$env:TEMP\IBM_Cloud_CLI_installer.exe"
    
    Write-Log "Downloading IBM Cloud CLI from $ibmCliUrl"
    Invoke-WebRequest -Uri $ibmCliUrl -OutFile $ibmCliInstaller -UseBasicParsing
    
    # Install IBM Cloud CLI silently
    Write-Log "Installing IBM Cloud CLI silently"
    Start-Process -FilePath $ibmCliInstaller -ArgumentList "/S" -Wait -NoNewWindow
    
    Write-Log "IBM Cloud CLI installation completed"
    Remove-Item $ibmCliInstaller -Force
} catch {
    Write-Log "Error installing IBM Cloud CLI: $($_.Exception.Message)"
}

# Wait for installation to complete and refresh PATH
Start-Sleep -Seconds 30
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install IBM Cloud CLI plugins
Write-Log "Installing IBM Cloud CLI plugins"
$plugins = @(
    "cloud-object-storage",
    "vpc-infrastructure", 
    "container-service"
)

foreach ($plugin in $plugins) {
    Write-Log "Installing IBM Cloud plugin: $plugin"
    try {
        & "C:\Program Files\IBM\Cloud\bin\ibmcloud.exe" plugin install $plugin -f
        Write-Log "Plugin $plugin installed successfully"
    } catch {
        Write-Log "Error installing plugin $plugin: $($_.Exception.Message)"
    }
}

# Create desktop shortcuts
Write-Log "Creating desktop shortcuts"
$WshShell = New-Object -comObject WScript.Shell

# Firefox shortcut
try {
    $firefoxPath = Get-ChildItem -Path "C:\Program Files\Mozilla Firefox\firefox.exe" -ErrorAction SilentlyContinue
    if ($firefoxPath) {
        $shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\Firefox.lnk")
        $shortcut.TargetPath = $firefoxPath.FullName
        $shortcut.Save()
        Write-Log "Firefox desktop shortcut created"
    }
} catch {
    Write-Log "Error creating Firefox shortcut: $($_.Exception.Message)"
}

# VS Code shortcut
try {
    $vscodePath = Get-ChildItem -Path "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe" -ErrorAction SilentlyContinue
    if ($vscodePath) {
        $shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\Visual Studio Code.lnk")
        $shortcut.TargetPath = $vscodePath.FullName
        $shortcut.Save()
        Write-Log "VS Code desktop shortcut created"
    }
} catch {
    Write-Log "Error creating VS Code shortcut: $($_.Exception.Message)"
}

# WinSCP shortcut
try {
    $winscpPath = Get-ChildItem -Path "C:\Program Files (x86)\WinSCP\WinSCP.exe" -ErrorAction SilentlyContinue
    if ($winscpPath) {
        $shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\WinSCP.lnk")
        $shortcut.TargetPath = $winscpPath.FullName
        $shortcut.Save()
        Write-Log "WinSCP desktop shortcut created"
    }
} catch {
    Write-Log "Error creating WinSCP shortcut: $($_.Exception.Message)"
}

# PuTTY shortcut  
try {
    $puttyPath = Get-ChildItem -Path "C:\ProgramData\chocolatey\bin\putty.exe" -ErrorAction SilentlyContinue
    if ($puttyPath) {
        $shortcut = $WshShell.CreateShortcut("$env:PUBLIC\Desktop\PuTTY.lnk")
        $shortcut.TargetPath = $puttyPath.FullName
        $shortcut.Save()
        Write-Log "PuTTY desktop shortcut created"
    }
} catch {
    Write-Log "Error creating PuTTY shortcut: $($_.Exception.Message)"
}

# Create PowerShell profile with aliases
Write-Log "Setting up PowerShell profile with IBM Cloud aliases"
try {
    $profilePath = $PROFILE.AllUsersAllHosts
    $profileDir = Split-Path $profilePath -Parent
    
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force
    }
    
    $aliasContent = @"
# IBM Cloud CLI Aliases
Set-Alias -Name ic -Value 'C:\Program Files\IBM\Cloud\bin\ibmcloud.exe'
function icos { & 'C:\Program Files\IBM\Cloud\bin\ibmcloud.exe' cos @args }

Write-Host "IBM Cloud CLI aliases loaded:" -ForegroundColor Green
Write-Host "  ic      - IBM Cloud CLI" -ForegroundColor Yellow  
Write-Host "  icos    - IBM Cloud Object Storage" -ForegroundColor Yellow
"@
    
    Add-Content -Path $profilePath -Value $aliasContent
    Write-Log "PowerShell profile configured with IBM Cloud aliases"
} catch {
    Write-Log "Error setting up PowerShell profile: $($_.Exception.Message)"
}

# Display installed versions
Write-Log "Checking installed versions"
try {
    $ibmVersion = & "C:\Program Files\IBM\Cloud\bin\ibmcloud.exe" version 2>$null
    Write-Log "IBM Cloud CLI version: $ibmVersion"
} catch {
    Write-Log "Could not get IBM Cloud CLI version"
}

# Final system update via Windows Update (optional)
Write-Log "Installing Windows updates"
try {
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false
    Write-Log "Windows updates installed"
} catch {
    Write-Log "Error installing Windows updates: $($_.Exception.Message)"
}

Write-Log "Windows user data script execution completed"
Write-Log "Installed applications: Firefox, WinSCP, PuTTY, VS Code, IBM Cloud CLI with plugins"
Write-Log "Desktop shortcuts created for all applications"
Write-Log "PowerShell aliases configured: ic (ibmcloud), icos (ibmcloud cos)"
</powershell>