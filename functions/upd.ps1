. "$PSScriptRoot\..\Spinner.ps1"

function upd {
    Write-Host ""
    
    $localCommit = git -C $PSScriptRoot rev-parse HEAD 2>$null
    $remoteCommit = git -C $PSScriptRoot rev-parse origin/main 2>$null
    
    if (-not $remoteCommit) {
        Write-Host "Checking for updates..." -NoNewline
        $null = Invoke-GitWithSpinner -GitArgs "fetch origin main" -WorkingDirectory $PSScriptRoot -LoadingMessage "Fetching..." -SuccessMessage "" -ErrorMessage ""
        
        try {
            $remoteCommit = git -C $PSScriptRoot rev-parse origin/main 2>$null
        } catch {}
    }
    
    if ($localCommit -and $remoteCommit -and ($localCommit -eq $remoteCommit)) {
        Write-Host "Already up to date!" -ForegroundColor Green
        return
    }
    
    if ($localCommit -and $remoteCommit) {
        Write-Host "Update available!" -ForegroundColor Yellow
    }
    
    Write-Host "Pulling changes..." -NoNewline
    $output = Invoke-GitWithSpinner -GitArgs "pull origin main" -WorkingDirectory $PSScriptRoot -LoadingMessage "Pulling..." -SuccessMessage "Done!" -ErrorMessage "Failed"
    
    if ($LASTEXITCODE -eq 0 -or $output -match "Updating|changed|files") {
        Write-Host ""
        Write-Host "Run $([char]0x1B)[1mreload$([char]0x0F) to apply changes." -ForegroundColor Cyan
    }
}
