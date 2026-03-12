function catx {
    param($file)
    if (-not (Test-Path $file)) { return }
    [System.IO.File]::ReadAllText((Resolve-Path $file))
}
