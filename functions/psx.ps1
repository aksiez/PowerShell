function psx {
    Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 15 Name, Id, CPU, WS |
    Format-Table -AutoSize
}
