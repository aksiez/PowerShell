. "$PSScriptRoot\Spinner.ps1"

Write-Host ""
Write-Host "Welcome to $([char]0x1B)[1mNexShell$([char]0x0F)" -ForegroundColor White

$configPath = Join-Path $PSScriptRoot "config.toml"

$showWelcome = $true
if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match 'showWelcome\s*=\s*(true|false)') {
        $showWelcome = $matches[1] -eq "true"
    }
}

if ($showWelcome) {
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

[Console]::CursorVisible = $false
Write-Host ""
$spinnerMsg = Get-Random -InputObject $NX_StatusMsgs
$lastLen = 0

for ($i = 0; $i -lt 12; $i++) { 
    $braille = $NX_BrailleChars[$i % $NX_BrailleChars.Count]
    
    if ($i % 5 -eq 0 -and $i -gt 0) {
        if ((Get-Random -Minimum 0 -Maximum 1000) -eq 0) {
            $spinnerMsg = "hi L! :3"
        } else {
            $spinnerMsg = Get-Random -InputObject $NX_StatusMsgs
        }
    }
    
    $curLen = $braille.Length + $spinnerMsg.Length + 1
    
    if ($lastLen -gt 0 -and $lastLen -ne $curLen) {
        Write-Host ("`r" + (" " * $lastLen) + ("`r")) -NoNewline
    } elseif ($lastLen -gt 0) {
        Write-Host ("`r") -NoNewline
    }
    
    Write-Host "$braille $spinnerMsg" -NoNewline
    $lastLen = $braille.Length + $spinnerMsg.Length + 1
    Start-Sleep -Milliseconds 100
}

$updateAvailable = $false

try {
    $null = git -C $PSScriptRoot fetch origin main 2>&1
    $localCommit = git -C $PSScriptRoot rev-parse HEAD 2>$null
    $remoteCommit = git -C $PSScriptRoot rev-parse origin/main 2>$null
    
    if ($localCommit -and $remoteCommit -and ($localCommit -ne $remoteCommit)) {
        $updateAvailable = $true
    }
} catch {}

if ($lastLen -gt 0) {
    Write-Host ("`r" + (" " * $lastLen) + ("`r")) -NoNewline
}
[Console]::CursorVisible = $true

if ($updateAvailable) {
    Write-Host "Update available! Run $([char]0x1B)[1mupd$([char]0x0F) to update." -ForegroundColor Yellow
} else {
    Write-Host "NexShell is up to date." -ForegroundColor Green
}

Write-Host ""

$spinnerMsg = Get-Random -InputObject $NX_StatusMsgs
$lastLen = 0

for ($i = 0; $i -lt 6; $i++) { 
    $braille = $NX_BrailleChars[$i % $NX_BrailleChars.Count]
    
    if ($i % 5 -eq 0 -and $i -gt 0) {
        if ((Get-Random -Minimum 0 -Maximum 1000) -eq 0) {
            $spinnerMsg = "hi L! :3"
        } else {
            $spinnerMsg = Get-Random -InputObject $NX_StatusMsgs
        }
    }
    
    $curLen = $braille.Length + $spinnerMsg.Length + 1
    
    if ($lastLen -gt 0 -and $lastLen -ne $curLen) {
        Write-Host ("`r" + (" " * $lastLen) + ("`r")) -NoNewline
    } elseif ($lastLen -gt 0) {
        Write-Host ("`r") -NoNewline
    }
    
    Write-Host "$braille $spinnerMsg" -NoNewline
    $lastLen = $braille.Length + $spinnerMsg.Length + 1
    Start-Sleep -Milliseconds 100
}

Get-ChildItem "$PSScriptRoot\functions\*.ps1" | ForEach-Object { 
    . $_.FullName 
}

$funcCount = (Get-ChildItem "$PSScriptRoot\functions\*.ps1").Count

if ($lastLen -gt 0) {
    Write-Host ("`r" + (" " * $lastLen) + ("`r")) -NoNewline
}
[Console]::CursorVisible = $true
Write-Host "Loaded $funcCount functions" -ForegroundColor Green

$spinnerMsg = Get-Random -InputObject $NX_StatusMsgs
$lastLen = 0

for ($i = 0; $i -lt 4; $i++) { 
    $braille = $NX_BrailleChars[$i % $NX_BrailleChars.Count]
    
    if ($i % 5 -eq 0 -and $i -gt 0) {
        if ((Get-Random -Minimum 0 -Maximum 1000) -eq 0) {
            $spinnerMsg = "hi L! :3"
        } else {
            $spinnerMsg = Get-Random -InputObject $NX_StatusMsgs
        }
    }
    
    $curLen = $braille.Length + $spinnerMsg.Length + 1
    
    if ($lastLen -gt 0 -and $lastLen -ne $curLen) {
        Write-Host ("`r" + (" " * $lastLen) + ("`r")) -NoNewline
    } elseif ($lastLen -gt 0) {
        Write-Host ("`r") -NoNewline
    }
    
    Write-Host "$braille $spinnerMsg" -NoNewline
    $lastLen = $braille.Length + $spinnerMsg.Length + 1
    Start-Sleep -Milliseconds 100
}

Set-PSReadLineOption -PredictionSource Plugin
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

if ($lastLen -gt 0) {
    Write-Host ("`r" + (" " * $lastLen) + ("`r")) -NoNewline
}
[Console]::CursorVisible = $true
Write-Host "PSReadLine ready" -ForegroundColor Green

Write-Host ""
