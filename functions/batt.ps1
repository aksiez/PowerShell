function batt {
    $b = Get-CimInstance Win32_Battery
    if (-not $b) { 
        if ($global:lang -eq "français") {
            "Aucune batterie détectée"
        } else {
            "No battery detected"
        }
        return
    }

    $pct = $b.EstimatedChargeRemaining
    if ($b.BatteryStatus -eq 2) {
        $status = if ($global:lang -eq "français") { "En charge" } else { "Charging" }
    } else {
        $status = if ($global:lang -eq "français") { "Batterie" } else { "Battery" }
    }

    "$pct% ($status)"
}
