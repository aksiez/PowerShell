function ff {
    param($name="*")
    Get-ChildItem -Recurse -Filter "*$name*"
}
