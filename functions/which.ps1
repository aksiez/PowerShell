function which {
    param($name)
    if (-not $name) {
        Write-Error "nothing to find"
        return
    }
    try {
        $result = Get-Command $name -ErrorAction Stop | Select-Object -ExpandProperty Source
        if ($null -eq $result) {
            Write-Error "command '$name' not found"
        }
        else {
            $result
        }
    }
    catch {
        Write-Error "command '$name' not found"
    }
}
