write-host "hi l"

$configPath = Join-Path $PSScriptRoot "config.toml"

$showWelcome = $true
if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match 'showWelcome\s*=\s*(true|false)') {
        $showWelcome = $matches[1] -eq "true"
    }
}

if ($showWelcome) {
    Write-Host ""
    Write-Host "Welcome to $([char]0x1B)[1mNexShell$([char]0x0F)" -ForegroundColor White
    Write-Host "This project contains my personal PowerShell configuration." -ForegroundColor Gray
    Write-Host "To update: use $([char]0x1B)[1mupd$([char]0x0F) command" -ForegroundColor DarkGray
    Write-Host "To reload: use $([char]0x1B)[1mreload$([char]0x0F) command" -ForegroundColor DarkGray
    Write-Host ""
    
    $response = Read-Host "Disable this message? (y/n)"
    if ($response -match "^[Yy]$") {
        $defaultConfig = @"
# NexShell Configuration

showWelcome = false
"@
        Set-Content -Path $configPath -Value $defaultConfig
        Write-Host "Message disabled. Edit $([char]0x1B)[36mconfig.toml$([char]0x0F) to re-enable." -ForegroundColor Green
    }
    Write-Host ""
}

Write-Host "Checking for updates..." -ForegroundColor Cyan

Start-Sleep -Milliseconds 500

function Get-GitUpdateStatus {
    try {
        git -C $PSScriptRoot fetch origin main 2>&1 | Out-Null
        $localCommit = git -C $PSScriptRoot rev-parse HEAD
        $remoteCommit = git -C $PSScriptRoot rev-parse origin/main
        if ($localCommit -ne $remoteCommit) {
            return "Update available! Run $([char]0x1B)[1mupd$([char]0x0F) to update."
        }
    } catch {}
    return $null
}

function update_line {
    param([string]$Message = "")
    $width = $Host.UI.RawUI.BufferSize.Width
    $clearLine = "`r" + (" " * ($width - 1)) + "`r"
    Write-Host "$clearLine$Message" -NoNewline
}

$updateStatus = Get-GitUpdateStatus
if ($updateStatus) {
    Write-Host $updateStatus -ForegroundColor Yellow
    Write-Host "Do you want to update now? (y/n)" -NoNewline
    $response = Read-Host " "
    if ($response -match "^[Yy]$") {
        Write-Host ""
        update_line "Updating..."
        git -C $PSScriptRoot pull | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Update complete. Restart your terminal or use $([char]0x1B)[1mreload$([char]0x0F)." -ForegroundColor Green
        } else {
            Write-Host "Update failed." -ForegroundColor Red
        }
    } else {
        Write-Host ""
    }
} else {
    Write-Host "NexShell is up to date." -ForegroundColor Green
}

Get-ChildItem "$PSScriptRoot\functions\*.ps1" | ForEach-Object { 
    update_line "Loading $($_.Name)"
    . $_.FullName 
}

update_line ""

update_line "PSReadLine"
Set-PSReadLineOption -PredictionSource Plugin
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

update_line ""
