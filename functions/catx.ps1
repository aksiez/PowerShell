function catx {
    param($file)
    if (-not (Test-Path $file)) {
        Write-Error "File '$file' does not exist."
        return
    }
    try {
        [System.IO.File]::ReadAllText((Resolve-Path $file))
    }
    catch {
        Write-Error "Failed to read file '$file': $_"
    }
}
