$configPath = Join-Path $PSScriptRoot "config.toml"
$lang = "unset"

if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match 'language\s*=\s*["'']([^"'']+)["'']') {
        $lang = $matches[1].ToLower()
    }
}

if ($lang -eq "unset" -or $lang -notmatch "^(français|english)$") {
    $lang = Read-Host "Language / Langue (english/français)"
    $lang = $lang.Trim().ToLower()
    if ($lang -notmatch "^(français|english)$") {
        $lang = "english"
    }
}

$global:lang = $lang

$showWelcome = $true
if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match 'showWelcome\s*=\s*(true|false)') {
        $showWelcome = $matches[1] -eq "true"
    }
}

if ($showWelcome) {
    Write-Host ""
    if ($lang -eq "français") {
        Write-Host "Bienvenue dans $([char]0x1B)[1mNexShell$([char]0x0F)" -ForegroundColor White
        Write-Host "Ce projet contient ma configuration PowerShell personnelle." -ForegroundColor Gray
        Write-Host "Pour mettre à jour: utilisez la commande $([char]0x1B)[1mupd$([char]0x0F)" -ForegroundColor DarkGray
        Write-Host "Pour recharger le profile: utilisez $([char]0x1B)[1mreload$([char]0x0F)" -ForegroundColor DarkGray
    } else {
        Write-Host "Welcome to $([char]0x1B)[1mNexShell$([char]0x0F)" -ForegroundColor White
        Write-Host "This project contains my personal PowerShell configuration." -ForegroundColor Gray
        Write-Host "To update: use $([char]0x1B)[1mupd$([char]0x0F) command" -ForegroundColor DarkGray
        Write-Host "To reload: use $([char]0x1B)[1mreload$([char]0x0F) command" -ForegroundColor DarkGray
    }
    Write-Host ""
    
    $disablePrompt = ""
    if ($lang -eq "français") {
        $disablePrompt = "Désactiver ce message? (o/n)"
    } else {
        $disablePrompt = "Disable this message? (y/n)"
    }
    $response = Read-Host $disablePrompt
    if ($response -match "^[YyOo]$") {
        $defaultConfig = @"
# NexShell Configuration

language = "$lang"
showWelcome = false
"@
        Set-Content -Path $configPath -Value $defaultConfig
        if ($lang -eq "français") {
            Write-Host "Message désactivé. Modifiez $([char]0x1B)[36mconfig.toml$([char]0x0F) pour le réactiver." -ForegroundColor Green
        } else {
            Write-Host "Message disabled. Edit $([char]0x1B)[36mconfig.toml$([char]0x0F) to re-enable." -ForegroundColor Green
        }
    }
    Write-Host ""
}

$updateCheck = ""
if ($lang -eq "français") {
    $updateCheck = "Vérification des mises à jour ... (Appuyez sur Ctrl+C pour annuler)"
} else {
    $updateCheck = "Checking for updates ... (Press Ctrl+C to cancel)"
}
Write-Host $updateCheck -ForegroundColor Cyan

Start-Sleep -Milliseconds 500

function Get-GitUpdateStatus {
    try {
        git -C $PSScriptRoot fetch origin main 2>&1 | Out-Null
        $localCommit = git -C $PSScriptRoot rev-parse HEAD
        $remoteCommit = git -C $PSScriptRoot rev-parse origin/main
        if ($localCommit -ne $remoteCommit) {
            if ($lang -eq "français") {
                return "Mise à jour disponible! Exécutez $([char]0x1B)[1mupd$([char]0x0F) pour mettre à jour."
            } else {
                return "Update available! Run $([char]0x1B)[1mupd$([char]0x0F) to update."
            }
        }
    } catch {}
    return $null
}

$updateStatus = Get-GitUpdateStatus
if ($updateStatus) {
    Write-Host $updateStatus -ForegroundColor Yellow
    if ($lang -eq "français") {
        $prompt = "Voulez-vous mettre à jour maintenant? (o/n)"
    } else {
        $prompt = "Do you want to update now? (y/n)"
    }
    Write-Host $prompt -NoNewline
    $response = Read-Host " "
    if ($response -eq "y" -or $response -eq "Y" -or $response -eq "o" -or $response -eq "O") {
        Write-Host ""
        update_line "Updating..."
        git -C $PSScriptRoot pull | Out-Null
        if ($LASTEXITCODE -eq 0) {
            if ($lang -eq "français") {
                Write-Host "Mise à jour terminée. Redémarrez votre terminal ou utilisez $([char]0x1B)[1mreload$([char]0x0F)." -ForegroundColor Green
            } else {
                Write-Host "Update complete. Restart your terminal or use $([char]0x1B)[1mreload$([char]0x0F)." -ForegroundColor Green
            }
        } else {
            if ($lang -eq "français") {
                Write-Host "Erreur lors de la mise à jour." -ForegroundColor Red
            } else {
                Write-Host "Update failed." -ForegroundColor Red
            }
        }
    } else {
        Write-Host ""
    }
} else {
    if ($lang -eq "français") {
        Write-Host "NexShell est à jour." -ForegroundColor Green
    } else {
        Write-Host "NexShell is up to date." -ForegroundColor Green
    }
}

function update_line {
    param(
        [string]$Message = ""
    )
    $width = $Host.UI.RawUI.BufferSize.Width
    $clearLine = "`r" + (" " * ($width - 1)) + "`r"
    Write-Host "$clearLine$Message" -NoNewline
}

Get-ChildItem "$PSScriptRoot\functions\*.ps1" | ForEach-Object { update_line "dot-sourcing $($_.Name)"; . $_.FullName }

update_line ""

update_line "PSReadLine stuff"
Set-PSReadLineOption -PredictionSource Plugin
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

update_line ""
