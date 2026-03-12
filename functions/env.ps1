function env {
    param([string]$Filter)
    try {
        $envVars = [Environment]::GetEnvironmentVariables()
        if (-not $envVars) {
            Write-Error "Failed to retrieve environment variables."
            return
        }
        $envVars |
        ForEach-Object { $_.GetEnumerator() } |
        Sort-Object Name |
        Where-Object { -not $Filter -or $_.Name -like "*$Filter*" -or $_.Value -like "*$Filter*" } |
        ForEach-Object {
            try {
                Write-Host "$($_.Name)=" -NoNewline -ForegroundColor DarkGray
                Write-Host $_.Value
            }
            catch {
                Write-Error "Error displaying environment variable '$($_.Name)': $_"
            }
        }
    }
    catch {
        Write-Error "Failed to process environment variables: $_"
    }
}
