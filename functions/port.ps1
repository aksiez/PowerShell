function port {
    param($p)

    Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue |
    Select-Object LocalAddress, LocalPort, OwningProcess |
    ForEach-Object {
        $proc = Get-Process -Id $_.OwningProcess
        [PSCustomObject]@{
            Process = $proc.ProcessName
            PID     = $proc.Id
            Port    = $_.LocalPort
        }
    }
}
