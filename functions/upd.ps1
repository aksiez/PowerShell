function upd {
    $gitPull = git -C $PSScriptRoot pull
    if ($LASTEXITCODE -eq 0) {
        if ($gitPull -match "Already up to date") {
            if ($global:lang -eq "français") {
                Write-Host "Déjà à jour." -ForegroundColor Green
            } else {
                Write-Host "Already up to date." -ForegroundColor Green
            }
        } else {
            if ($global:lang -eq "français") {
                Write-Host "Mise à jour terminée. Redémarrez votre terminal ou utilisez $([char]0x1B)[1mreload$([char]0x0F)." -ForegroundColor Green
            } else {
                Write-Host "Update complete. Restart your terminal or use $([char]0x1B)[1mreload$([char]0x0F)." -ForegroundColor Green
            }
        }
    } else {
        if ($global:lang -eq "français") {
            Write-Host "Erreur lors de la mise à jour." -ForegroundColor Red
        } else {
            Write-Host "Update failed." -ForegroundColor Red
        }
    }
}
