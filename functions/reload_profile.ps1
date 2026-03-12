function reload {
    Write-Host "Dot-sorcing this profile: " -NoNewline
    Write-Host $profile -ForegroundColor Cyan
    Write-Host "Please note that reloading the profile may not update certain functions." -ForegroundColor Yellow
    Write-Host "For those, you may have to open a new terminal." -ForegroundColor Yellow
    Write-Host "CUSTOM FUNCTIONS APPEAR TO NOT UPDATE UPON RELOAD." -ForegroundColor DarkRed
    Write-Host "IT WILL ONLY LOAD NEW FUNCTIONS, NOT UPDATE EXISTING ONES." -ForegroundColor DarkRed
    . $profile
}
