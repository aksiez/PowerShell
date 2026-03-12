function chafa {
    if ($global:lang -eq "français") {
        Write-Host "Exécution de chafa via wsl."
    } else {
        Write-Host "Running chafa through wsl."
    }

    if ($global:lang -eq "français") {
        Write-Host "Veuillez patienter, wsl peut prendre du temps à démarrer..." -ForegroundColor White
    } else {
        Write-Host "Please wait, wsl may take a while to start if it hasn't yet..." -ForegroundColor White
    }

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
