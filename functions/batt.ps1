function batt {
    $b = Get-CimInstance Win32_Battery
    if (-not $b) { 
        "No battery detected"
        return
    }

    $pct = $b.EstimatedChargeRemaining
    if ($b.BatteryStatus -eq 2) {
        $status = "Charging"
    } else {
        $status = "Battery"
    }

    "$pct% ($status)"
}
