$profilePath = $profile | Split-Path -Parent
$installPath = Join-Path $profilePath "NexShell"

$existingItems = Get-ChildItem -Path $profilePath -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "NexShell" }

if ($existingItems) {
    Write-Host "Found existing files/folders in profile folder:" -ForegroundColor Yellow
    $existingItems | ForEach-Object { Write-Host "  - $($_.Name)" }
    Write-Host ""
    $response = Read-Host "This will DELETE everything except NexShell. Continue? (y/n)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Installation cancelled." -ForegroundColor Red
        return
    }
    $existingItems | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path $installPath) {
    Remove-Item -Recurse -Force $installPath
}

Write-Host "Cloning NexShell..." -ForegroundColor Cyan
git clone https://github.com/aksiez/PowerShell.git $installPath

$lineToAdd = ". `"$installPath\Microsoft.PowerShell_profile.ps1`""

$profileContent = if (Test-Path $profile) { Get-Content $profile -Raw } else { "" }

if ($profileContent -notmatch [regex]::Escape($lineToAdd)) {
    Set-Content $profile $lineToAdd
    Write-Host "Added NexShell to profile." -ForegroundColor Green
} else {
    Write-Host "NexShell already in profile." -ForegroundColor Yellow
}

Write-Host "Done! Restart your terminal or run . `$profile" -ForegroundColor Green
