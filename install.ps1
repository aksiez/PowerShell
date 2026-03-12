# NexShell Installer
# This script installs or updates NexShell

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[+] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[-] $Message" -ForegroundColor Red
}

function Test-GitInstalled {
    try {
        git --version 2>$null
        return $true
    } catch {
        return $false
    }
}

function Test-ScoopInstalled {
    try {
        scoop --version 2>$null
        return $true
    } catch {
        return $false
    }
}

function Install-Scoop {
    Write-Step "Scoop not found. Installing Scoop..."
    
    $scoopInstallScript = {
        if (!(Test-Path $env:USERPROFILE\scoop)) {
            [Environment]::SetEnvironmentVariable('SCOOP', "$env:USERPROFILE\scoop", 'User')
            $env:SCOOP = "$env:USERPROFILE\scoop"
        }
        
        $rs =irm get.scoop.sh -UseB
        & $rs -RunAsAdmin
    }
    
    try {
        Invoke-Expression ($scoopInstallScript.ToString())
        
        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
        
        Start-Sleep -Seconds 2
        
        if (Test-ScoopInstalled) {
            Write-Success "Scoop installed successfully"
            return $true
        } else {
            Write-Error "Scoop installation failed. Please install Scoop manually: https://scoop.sh"
            return $false
        }
    } catch {
        Write-Error "Failed to install Scoop: $_"
        Write-Host "Please install Scoop manually from https://scoop.sh" -ForegroundColor Yellow
        return $false
    }
}

function Install-GitViaScoop {
    Write-Step "Git not found. Installing Git via Scoop..."
    
    try {
        scoop install git
        Write-Success "Git installed successfully"
        
        # Refresh PATH to include git
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
        
        # Verify git is now available
        Start-Sleep -Seconds 1
        if (Test-GitInstalled) {
            return $true
        } else {
            Write-Warning "Git installed but not immediately available. Please restart your terminal."
            return $false
        }
    } catch {
        Write-Error "Failed to install Git via Scoop: $_"
        return $false
    }
}

function Get-Git {
    if (Test-GitInstalled) {
        return $true
    }
    
    if (Test-ScoopInstalled) {
        return Install-GitViaScoop
    }
    
    # Scoop not installed, install it first
    $scoopResult = Install-Scoop
    if (-not $scoopResult) {
        return $false
    }
    
    # Now install git via scoop
    return Install-GitViaScoop
}

# Main installation logic
$profilePath = $profile | Split-Path -Parent
$installPath = Join-Path $profilePath "NexShell"

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "     NexShell Installer" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Check for git
if (-not (Get-Git)) {
    Write-Error "Could not install Git. Please install Git manually from https://git-scm.com"
    Write-Host "Or install Scoop first: https://scoop.sh" -ForegroundColor Yellow
    return
}

# Check for existing installation
$isUpdate = Test-Path $installPath

if ($isUpdate -and -not $Force) {
    Write-Step "NexShell found at: $installPath"
    Write-Step "Updating NexShell via git pull..."
    
    try {
        git -C $installPath pull
        if ($LASTEXITCODE -eq 0) {
            Write-Success "NexShell updated successfully!"
            Write-Host ""
            Write-Host "To apply changes, restart your terminal or run: reload" -ForegroundColor Yellow
            return
        } else {
            Write-Warning "Git pull failed. Trying to re-clone..."
            $isUpdate = $false
        }
    } catch {
        Write-Warning "Update failed: $_"
        Write-Step "Will re-install from scratch..."
    }
}

# Fresh install or re-install
if ($isUpdate) {
    Write-Step "Removing old installation..."
    Remove-Item -Recurse -Force $installPath -ErrorAction SilentlyContinue
}

# Check for conflicting files in profile directory
$existingItems = Get-ChildItem -Path $profilePath -Force -ErrorAction SilentlyContinue | Where-Object { 
    $_.Name -ne "NexShell" -and $_.Name -ne "Documents" 
}

if ($existingItems -and -not $Force) {
    Write-Host ""
    Write-Warning "Found existing files/folders in profile folder:"
    $existingItems | ForEach-Object { Write-Host "  - $($_.Name)" }
    Write-Host ""
    $response = Read-Host "These will be DELETED (NexShell will replace everything). Continue? (y/n)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Installation cancelled." -ForegroundColor Red
        return
    }
    $existingItems | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Step "Cloning NexShell..."
git clone https://github.com/aksiez/PowerShell.git $installPath

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to clone repository."
    return
}

# Create default config
$defaultConfig = @"
# NexShell Configuration

showWelcome = false
"@

$configPath = Join-Path $installPath "config.toml"
Set-Content -Path $configPath -Value $defaultConfig

# Add to profile if not already there
$lineToAdd = ". `"$installPath\Microsoft.PowerShell_profile.ps1`""
$profileContent = if (Test-Path $profile) { Get-Content $profile -Raw } else { "" }

if ($profileContent -notmatch [regex]::Escape($lineToAdd)) {
    Set-Content -Path $profile -Value $lineToAdd
    Write-Success "Added NexShell to PowerShell profile"
} else {
    Write-Success "NexShell already in profile"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  NexShell installed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To start using NexShell:" -ForegroundColor Yellow
Write-Host "  1. Restart your terminal, OR" -ForegroundColor White
Write-Host "  2. Run: . `$profile" -ForegroundColor White
Write-Host ""
