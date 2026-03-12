function chafa {
    Write-Host "Running chafa through wsl."
    Write-Host "Please wait, wsl may take a while to start if it hasn't yet..." -ForegroundColor White

    try {
        $convertedArgs = $args | ForEach-Object {
            $_ -replace "\\", "/" `
                -replace "^([A-Z]):/", {
                $driveLetter = $_.Groups[1].Value.ToLower()
                "/mnt/$driveLetter/"
            }
        }

        wsl chafa --format sixel $convertedArgs
    }
    finally {
        Remove-Variable convertedArgs -ErrorAction SilentlyContinue
        Remove-Variable driveLetter -ErrorAction SilentlyContinue
    }
}
