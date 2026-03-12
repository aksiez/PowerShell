# NexShell Installer

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$NX_BrailleChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
$NX_StatusMsgs = @(
    "Preparing...", "Baking the baguettes...", "Reconsidering life choices...",
    "Be riiiiight back, sir!", "On it.", "Might take a sec.",
    "Counting pixels...", "Herding cats...", "Untangling wires...",
    "Asking AI for help...", "Loading the interwebs...",
    "Spinning up the flux capacitor...", "Distracting with shinies...",
    "Almost there...", "Polishing the bits...", "Feeding the hamsters..."
)

$NX_SpinnerIdx = 0
$NX_MsgIdx = 0

function Write-Spinner {
    param([switch]$NoNewline)
    
    $braille = $NX_BrailleChars[$NX_SpinnerIdx % $NX_BrailleChars.Count]
    $msg = $NX_StatusMsgs[$NX_MsgIdx % $NX_StatusMsgs.Count]
    
    if ($NoNewline) {
        Write-Host "$braille $msg" -NoNewline
    } else {
        Write-Host "$braille $msg"
    }
    
    $NX_SpinnerIdx++
    if ($NX_SpinnerIdx % 8 -eq 0) { $NX_MsgIdx++ }
}

function Clear-Spinner {
    $width = 80
    try { $width = $Host.UI.RawUI.BufferSize.Width } catch {}
    Write-Host ("`r" + (" " * ($width - 1)) + "`r") -NoNewline
}

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
    
    try {
        if (!(Test-Path $env:USERPROFILE\scoop)) {
            [Environment]::SetEnvironmentVariable('SCOOP', "$env:USERPROFILE\scoop", 'User')
            $env:SCOOP = "$env:USERPROFILE\scoop"
        }
        
        Write-Host "Installing Scoop... " -NoNewline
        for ($i = 0; $i -lt 10; $i++) { 
            Write-Spinner -NoNewline
            Start-Sleep -Milliseconds 100
            $len = $NX_BrailleChars[($i) % $NX_BrailleChars.Count].Length + $NX_StatusMsgs[([Math]::Floor($i/8)) % $NX_StatusMsgs.Count].Length + 1
            Write-Host ("`b" * $len) -NoNewline
        }
        
        $rs = irm get.scoop.sh -UseB
        & $rs -RunAsAdmin
        
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
        
        Start-Sleep -Seconds 3
        
        if (Test-ScoopInstalled) {
            Clear-Spinner
            Write-Success "Scoop installed!"
            return $true
        }
    } catch {
        Clear-Spinner
        Write-Warning "Could not install Scoop automatically - please install from https://scoop.sh"
    }
    
    return $false
}

function Install-GitViaScoop {
    Write-Host "Installing Git via Scoop... " -NoNewline
    for ($i = 0; $i -lt 10; $i++) { 
        Write-Spinner -NoNewline
        Start-Sleep -Milliseconds 100
        $len = $NX_BrailleChars[($i) % $NX_BrailleChars.Count].Length + $NX_StatusMsgs[([Math]::Floor($i/8)) % $NX_StatusMsgs.Count].Length + 1
        Write-Host ("`b" * $len) -NoNewline
    }
    
    try {
        scoop install git 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
        Start-Sleep -Seconds 2
        
        if (Test-GitInstalled) {
            Clear-Spinner
            Write-Success "Git installed!"
            return $true
        }
    } catch {
        Clear-Spinner
    }
    
    Write-Warning "Could not install Git automatically - please install from https://git-scm.com"
    return $false
}

function Get-Git {
    if (Test-GitInstalled) {
        return $true
    }
    
    if (Test-ScoopInstalled) {
        return Install-GitViaScoop
    }
    
    $scoopResult = Install-Scoop
    if (-not $scoopResult) {
        return $false
    }
    
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

if (-not (Get-Git)) {
    Write-Error "Could not install Git. Please install manually from https://git-scm.com"
    return
}

$isUpdate = Test-Path $installPath

if ($isUpdate -and -not $Force) {
    Write-Step "Updating NexShell..."
    Write-Host "Pulling changes... " -NoNewline
    for ($i = 0; $i -lt 8; $i++) { 
        Write-Spinner -NoNewline
        Start-Sleep -Milliseconds 100
        $len = $NX_BrailleChars[($i) % $NX_BrailleChars.Count].Length + $NX_StatusMsgs[([Math]::Floor($i/8)) % $NX_StatusMsgs.Count].Length + 1
        Write-Host ("`b" * $len) -NoNewline
    }
    
    try {
        git -C $installPath pull 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Clear-Spinner
            Write-Success "Updated!"
            Write-Host ""
            Write-Host "Run: reload" -ForegroundColor Yellow
            return
        }
    } catch {
        Clear-Spinner
        Write-Warning "Update failed, will re-install..."
    }
}

if ($isUpdate) {
    Write-Step "Removing old installation..."
    Remove-Item -Recurse -Force $installPath -ErrorAction SilentlyContinue
}

$existingItems = Get-ChildItem -Path $profilePath -Force -ErrorAction SilentlyContinue | Where-Object { 
    $_.Name -ne "NexShell" -and $_.Name -ne "Documents" 
}

if ($existingItems -and -not $Force) {
    Write-Host ""
    Write-Warning "Found existing files in profile folder:"
    $existingItems | ForEach-Object { Write-Host "  - $($_.Name)" }
    Write-Host ""
    $response = Read-Host "These will be DELETED. Continue? (y/n)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Installation cancelled." -ForegroundColor Red
        return
    }
    $existingItems | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Cloning NexShell... " -NoNewline
for ($i = 0; $i -lt 12; $i++) { 
    Write-Spinner -NoNewline
    Start-Sleep -Milliseconds 100
    $len = $NX_BrailleChars[($i) % $NX_BrailleChars.Count].Length + $NX_StatusMsgs[([Math]::Floor($i/8)) % $NX_StatusMsgs.Count].Length + 1
    Write-Host ("`b" * $len) -NoNewline
}

git clone https://github.com/aksiez/PowerShell.git $installPath 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Clear-Spinner
    Write-Error "Failed to clone repository."
    return
}

Clear-Spinner
Write-Success "Cloned!"

$defaultConfig = @"
# NexShell Configuration

showWelcome = false
"@

$configPath = Join-Path $installPath "config.toml"
Set-Content -Path $configPath -Value $defaultConfig

$lineToAdd = ". `"$installPath\Microsoft.PowerShell_profile.ps1`""
$profileContent = if (Test-Path $profile) { Get-Content $profile -Raw } else { "" }

if ($profileContent -notmatch [regex]::Escape($lineToAdd)) {
    Set-Content -Path $profile -Value $lineToAdd
    Write-Success "Added to profile"
} else {
    Write-Success "Already in profile"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  NexShell installed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Restart terminal or run: . `$profile" -ForegroundColor Yellow
Write-Host ""
