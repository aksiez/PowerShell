function reload {
    if ($global:lang -eq "français") {
        Write-Host "Chargement du profile: " -NoNewline
    } else {
        Write-Host "Dot-sourcing this profile: " -NoNewline
    }
    Write-Host $profile -ForegroundColor Cyan
    if ($global:lang -eq "français") {
        Write-Host "Note: le rechargement peut ne pas mettre à jour certaines fonctions." -ForegroundColor Yellow
        Write-Host "Pour celles-ci, vous devrez peut-être ouvrir un nouveau terminal." -ForegroundColor Yellow
    } else {
        Write-Host "Please note that reloading the profile may not update certain functions." -ForegroundColor Yellow
        Write-Host "For those, you may have to open a new terminal." -ForegroundColor Yellow
    }
    . $profile
}
