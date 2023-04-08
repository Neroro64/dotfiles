function Invoke-Replace {
    [CmdletBinding()]
    [alias("irg")]
    param (
        [Parameter(Mandatory)]
        [string]    $Pattern,
        [Parameter(Mandatory)]
        [string]    $Target
    )

    $files = rg -l $Pattern;
    if ($files.Length -gt 50) {
        $files | ForEach-Object -Parallel {
            (Get-Content $_).Replace($Pattern, $Target) | Out-File -FilePath $_;
        }
    }
    else {
        $files | ForEach-Object {
            (Get-Content $_).Replace($Pattern, $Target) | Out-File -FilePath $_;
        }
    }
}