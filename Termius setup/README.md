# OpenSSH Server Setup Skill

Automated PowerShell script to install, configure, and test OpenSSH Server on Windows 11.

## What This Does

This script automates the entire OpenSSH Server setup process:
1. Installs OpenSSH Server (if not already installed)
2. Starts the SSH service and enables auto-start
3. Creates Windows Firewall rule for port 22
4. Verifies SSH is listening
5. Optionally generates SSH keys for key-based authentication

## Session History

Created: **2026-05-30**

This script was created based on a real session where OpenSSH was manually installed and configured on a Windows 11 laptop. The script now automates all those steps so they can be repeated on any Windows system.

### What Happened in the Original Session

1. Downloaded OpenSSH from GitHub
2. Extracted and ran install-sshd.ps1
3. Created firewall rules for port 22
4. Verified SSH service was running
5. Set up password authentication
6. Created SSH keys (ED25519)
7. Successfully connected from:
   - Second laptop: `ssh chira@192.168.1.96`
   - Phone (Termius app): `192.168.1.96:22`

## Usage

### Basic Setup
Run as Administrator:
```powershell
.\Setup-OpenSSH-Server.ps1
```

### Advanced Options

**Skip firewall configuration:**
```powershell
.\Setup-OpenSSH-Server.ps1 -SkipFirewall
```

**Generate SSH keys:**
```powershell
.\Setup-OpenSSH-Server.ps1 -GenerateKeys
```

**Combine options:**
```powershell
.\Setup-OpenSSH-Server.ps1 -GenerateKeys -SkipFirewall
```

## Requirements

- Windows 10/11
- Administrator privileges
- PowerShell 5.0+

## Connection Methods After Setup

### From Another Computer (Same Network)
```powershell
ssh username@192.168.1.x
```

### From Phone (Termius App)
- Host: Your laptop's IP address
- Username: Your Windows username
- Password: Your Windows password
- Port: 22

### Test Locally
```powershell
ssh username@localhost
```

## Troubleshooting

**SSH not connecting:**
- Verify both devices are on the same WiFi network
- Check firewall rule is enabled: `Get-NetFirewallRule -Name "sshd" | Format-Table Name, Enabled`
- Verify SSH is listening: `netstat -an | findstr :22`

**Service won't start:**
- Run PowerShell as Administrator
- Check service status: `Get-Service sshd`

**Authentication fails:**
- Ensure you have a Windows password set (not just PIN)
- Reset password in Settings > Accounts > Sign-in options

## Files Modified/Created

- `C:\Program Files\OpenSSH` - OpenSSH installation directory
- `C:\ProgramData\ssh\sshd_config` - SSH server configuration
- `C:\Users\<username>\.ssh\` - SSH keys and authorized_keys (if -GenerateKeys used)

## Configuration Files

SSH Server Config: `C:\ProgramData\ssh\sshd_config`
- Key setting: `PasswordAuthentication yes`

## Next Steps

1. Run this script to set up OpenSSH
2. Get your IP address: `ipconfig`
3. Connect from another device
4. (Optional) Set up SSH keys for better security

---
For more information, see the Termius folder for connection guides.
