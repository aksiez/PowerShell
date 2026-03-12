function upd {
    $gitPull = git -C $PSScriptRoot pull
    if ($LASTEXITCODE -eq 0) {
        if ($gitPull -match "Already up to date") {
            Write-Host "Already up to date." -ForegroundColor Green
        } else {
            Write-Host "Update complete. Restart your terminal or use $([char]0x1B)[1mreload$([char]0x0F)." -ForegroundColor Green
        }
    } else {
        Write-Host "Update failed." -ForegroundColor Red
    }
}
