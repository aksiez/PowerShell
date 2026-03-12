function update_line {
    param(
        [string]$Message = ""
    )
    $width = $Host.UI.RawUI.BufferSize.Width
    $clearLine = "`r" + (" " * ($width - 1)) + "`r"
    Write-Host "$clearLine$Message" -NoNewline
}

Get-ChildItem "$PSScriptRoot\functions\*.ps1" | ForEach-Object { update_line "dot-sourcing $($_.Name)"; . $_.FullName }

update_line ""

update_line "PSReadLine stuff"
Set-PSReadLineOption -PredictionSource Plugin
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

update_line ""
