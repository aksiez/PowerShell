$NX_BrailleChars = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
$NX_StatusMsgs = @(
    "Preparing...", "Baking the baguettes...", "Reconsidering life choices...",
    "Be riiiiight back, sir!", "On it.", "Might take a sec.",
    "Counting pixels...", "Herding cats...", "Untangling wires...",
    "Asking AI for help...", "Loading the interwebs...",
    "Spinning up the flux capacitor...", "Distracting with shinies...",
    "Almost there...", "Polishing the bits...", "Feeding the hamsters...",
    "Doin stuff...", "Wait up.", "Downloading the purpose of life: 0%...",
    "Untangling spaghetti...", "Feeding the backlog...",
    "Consulting the oracles...", "Waking up the hamsters...",
    "Checking under the rug...", "Loading... probably...",
    "Calculating the answer to everything...",
    "Synchronizing with the mothership...",
    "Sharpening the edges...",
    "Reticulating splines...",
    "Organizing the chaos...",
    "Finding the last bug...",
    "Brewing coffee..."
)

$NX_SpinnerIdx = 0
$NX_MsgIdx = 0

function Write-Spinner {
    param([switch]$NoNewline)
    
    $braille = $NX_BrailleChars[$NX_SpinnerIdx % $NX_BrailleChars.Count]
    
    if ((Get-Random -Minimum 0 -Maximum 1000) -eq 0) {
        $msg = "hi L! :3"
    } else {
        $msg = Get-Random -InputObject $NX_StatusMsgs
    }
    
    if ($NoNewline) {
        Write-Host "$braille $msg" -NoNewline
    } else {
        Write-Host "$braille $msg"
    }
    
    $NX_SpinnerIdx++
}

function Clear-Spinner {
    $width = 80
    try { $width = $Host.UI.RawUI.BufferSize.Width } catch {}
    Write-Host ("`r" + (" " * ($width - 1)) + "`r") -NoNewline
}

function Test-CommandAvailable {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-ScoopIfNeeded {
    if (Test-CommandAvailable "scoop") { return $true }
    
    Write-Host ""
    Write-Host "Installing Scoop (Windows package manager)..." -ForegroundColor Cyan
    
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
        Start-Sleep -Seconds 3
        
        if (Test-CommandAvailable "scoop") {
            Write-Host "Scoop installed!" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "Could not install Scoop automatically" -ForegroundColor Yellow
    }
    
    return $false
}

function Install-GitIfNeeded {
    if (Test-CommandAvailable "git") { return $true }
    
    Write-Host ""
    Write-Host "Installing Git via Scoop..." -ForegroundColor Yellow
    
    if (-not (Install-ScoopIfNeeded)) {
        Write-Host "Please install Git from https://git-scm.com/download/win" -ForegroundColor Red
        return $false
    }
    
    scoop install git 2>$null
    
    if (Test-CommandAvailable "git") {
        Write-Host "Git installed!" -ForegroundColor Green
        return $true
    }
    
    Write-Host "Please install Git from https://git-scm.com/download/win" -ForegroundColor Red
    return $false
}

function Invoke-GitWithSpinner {
    param(
        [string]$GitArgs,
        [string]$WorkingDirectory,
        [string]$LoadingMessage = "Git is thinking...",
        [string]$SuccessMessage = "Done!",
        [string]$ErrorMessage = "Failed"
    )
    
    if (-not (Test-CommandAvailable "git")) {
        if (-not (Install-GitIfNeeded)) {
            return $false
        }
    }
    
    Write-Spinner -NoNewline
    
    try {
        if ($WorkingDirectory) {
            $output = git -C $WorkingDirectory $GitArgs 2>&1
        } else {
            $output = git $GitArgs 2>&1
        }
        $exitCode = $LASTEXITCODE
    } catch {
        $exitCode = 1
        $output = $_
    }
    
    Clear-Spinner
    
    if ($exitCode -eq 0) {
        if ($SuccessMessage) { Write-Host "$SuccessMessage" -ForegroundColor Green }
        return $output
    } else {
        if ($ErrorMessage) { Write-Host "$ErrorMessage" -ForegroundColor Red }
        return $false
    }
}
