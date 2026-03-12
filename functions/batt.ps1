function batt {
    $b = Get-CimInstance Win32_Battery
    if (-not $b) { "No battery detected"; return }

    $pct = $b.EstimatedChargeRemaining
    $status = if ($b.BatteryStatus -eq 2) { "Charging" } else { "Battery" }

    "$pct% ($status)"
}
