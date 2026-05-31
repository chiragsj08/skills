<#
.SYNOPSIS
Automated OpenSSH Server Setup and SSH Connection Configuration
.DESCRIPTION
This script automates the entire OpenSSH server installation, configuration, and setup process.
It was created based on the session from 2026-05-30 where OpenSSH was successfully installed
and configured for SSH connections from multiple devices (laptops and phone via Termius).

.AUTHOR
Claude Code Assistant
.DATE
2026-05-30

.USAGE
Run as Administrator:
  .\Setup-OpenSSH-Server.ps1
#>

param(
    [switch]$SkipFirewall,
    [switch]$SkipPasswordSetup,
    [switch]$GenerateKeys
)

Write-Host "=== OpenSSH Server Automated Setup ===" -ForegroundColor Cyan
Write-Host "Starting OpenSSH installation and configuration..." -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

# Step 1: Check and install OpenSSH
Write-Host "[1/5] Checking OpenSSH installation..." -ForegroundColor Yellow
$openSSH = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

if ($openSSH.State -eq "Installed") {
    Write-Host "✓ OpenSSH is already installed" -ForegroundColor Green
} else {
    Write-Host "Installing OpenSSH Server..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -Verbose
    Write-Host "✓ OpenSSH installed successfully" -ForegroundColor Green
}

# Step 2: Start SSH service
Write-Host "[2/5] Starting SSH service..." -ForegroundColor Yellow
Start-Service sshd -ErrorAction SilentlyContinue
Set-Service -Name sshd -StartupType Automatic
Write-Host "✓ SSH service started and set to auto-start" -ForegroundColor Green

# Step 3: Configure Firewall (optional)
if (-not $SkipFirewall) {
    Write-Host "[3/5] Configuring Windows Firewall..." -ForegroundColor Yellow
    $rule = Get-NetFirewallRule -Name "sshd" -ErrorAction SilentlyContinue
    if (-not $rule) {
        New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        Write-Host "✓ Firewall rule created" -ForegroundColor Green
    } else {
        Write-Host "✓ Firewall rule already exists" -ForegroundColor Green
    }
} else {
    Write-Host "[3/5] Skipping firewall configuration" -ForegroundColor Yellow
}

# Step 4: Verify SSH is listening
Write-Host "[4/5] Verifying SSH is listening on port 22..." -ForegroundColor Yellow
$listening = netstat -an | findstr :22
if ($listening) {
    Write-Host "✓ SSH is listening on port 22" -ForegroundColor Green
    Write-Host $listening
} else {
    Write-Host "✗ SSH is NOT listening on port 22" -ForegroundColor Red
}

# Step 5: SSH Key Generation (optional)
if ($GenerateKeys) {
    Write-Host "[5/5] Generating SSH keys..." -ForegroundColor Yellow
    $sshPath = "$env:USERPROFILE\.ssh"
    mkdir -Force $sshPath | Out-Null
    ssh-keygen -t ed25519 -f "$sshPath\id_ed25519" -N "" -C "OpenSSH Key - Generated $(Get-Date -Format 'yyyy-MM-dd')"
    Get-Content "$sshPath\id_ed25519.pub" | Add-Content "$sshPath\authorized_keys"
    Write-Host "✓ SSH keys generated" -ForegroundColor Green
} else {
    Write-Host "[5/5] Skipping SSH key generation" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Connection Information:" -ForegroundColor Cyan
$ipConfig = ipconfig | Select-String "IPv4 Address" | Select-Object -First 1
Write-Host $ipConfig
Write-Host ""
Write-Host "To connect from another device:" -ForegroundColor Green
Write-Host "  ssh $env:USERNAME@<your-ip-address>" -ForegroundColor White
Write-Host ""
Write-Host "SSH Service Status:" -ForegroundColor Green
Get-Service sshd | Format-Table Name, Status, StartType
Write-Host ""
Write-Host "To test locally:" -ForegroundColor Green
Write-Host "  ssh $env:USERNAME@localhost" -ForegroundColor White
