function Invoke-PythonVenv
{
	[Alias("pyv")]
	param (
		[string] $VenvPath = $PSScriptRoot
	)
	
	$pathLinux =  "$VenvPath/bin/activate.ps1"
	$pathWin =  "$VenvPath/scripts/activate.ps1"
	if (Test-Path $pathLinux)
	{
		. $pathLinux
	} elseif (Test-Path $pathWin)
	{
		. $pathWin
	} else
	{
		Write-Error "Activate.ps1 script not found in $VenvPath!"
	}
}
