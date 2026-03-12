function treex {
    param($path=".", $depth=2)

    Get-ChildItem $path -Recurse -Depth $depth |
    ForEach-Object {
        $level = ($_.FullName.Replace((Resolve-Path $path), "").Split("\").Count - 1)
        (" " * ($level * 2)) + $_.Name
    }
}
