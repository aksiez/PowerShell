function which {
    param($name)
    Get-Command $name | Select-Object -ExpandProperty Source
}
