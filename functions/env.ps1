function env {
    param([string]$Filter)
    [Environment]::GetEnvironmentVariables() |
        ForEach-Object { $_.GetEnumerator() } |
        Sort-Object Name |
        Where-Object { -not $Filter -or $_.Name -like "*$Filter*" -or $_.Value -like "*$Filter*" } |
        ForEach-Object { Write-Host "$($_.Name)=" -NoNewline -ForegroundColor DarkGray; Write-Host $_.Value }
}
