function Invoke-PythonVenv
{
	[Alias("pyv")]
	param (
		[string] $VenvPath = (Get-Location).Path
	)
	
	$pathLinux =  Join-Path -Path $VenvPath -ChildPath "bin/Activate.ps1"
	$pathWin =  Join-Path -Path $VenvPath -ChildPath "scripts/Activate.ps1"
	if (Test-Path $pathLinux)
	{
		. $pathLinux
	} elseif (Test-Path $pathWin)
	{
		. $pathWin
	} else
	{
		Write-Error "Activate.ps1 script not found in $pathLinux or $pathWin!"
	}
}
