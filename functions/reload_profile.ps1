function reload {
    Write-Host "Dot-sourcing this profile: " -NoNewline
    Write-Host $profile -ForegroundColor Cyan
    Write-Host "Note: Reloading may not update all functions." -ForegroundColor Yellow
    Write-Host "For those, you may need to open a new terminal." -ForegroundColor Yellow
    . $profile
}
