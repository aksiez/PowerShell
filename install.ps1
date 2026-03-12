$profilePath = $profile | Split-Path -Parent
$installPath = Join-Path $profilePath "NexShell"

if (Test-Path $installPath) {
    Write-Host "Removing previous installation..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $installPath
}

Write-Host "Cloning NexShell..." -ForegroundColor Cyan
git clone https://github.com/aksiez/PowerShell.git $installPath

$lineToAdd = ". `"$installPath\Microsoft.PowerShell_profile.ps1`""

$profileContent = if (Test-Path $profile) { Get-Content $profile -Raw } else { "" }

if ($profileContent -notmatch [regex]::Escape($lineToAdd)) {
    Add-Content $profile $lineToAdd
    Write-Host "Added NexShell to profile." -ForegroundColor Green
} else {
    Write-Host "NexShell already in profile." -ForegroundColor Yellow
}

Write-Host "Done! Restart your terminal or run . `$profile" -ForegroundColor Green
