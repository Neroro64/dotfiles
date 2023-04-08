<#
.SYNOPSIS
Invokes RipGrep to find occurrences of a regex 'Pattern' recursively in the provided 'Path' and group the results into a PowerShell hashtable

.DESCRIPTION
Long description

.PARAMETER Path
Parameter description

.PARAMETER Pattern
Parameter description

.PARAMETER Literal
Parameter description

.PARAMETER Context
Parameter description

.PARAMETER CaseSensitive
Parameter description

.PARAMETER Glob
Parameter description

.PARAMETER Hidden
Parameter description

.PARAMETER Invert
Parameter description

.PARAMETER Max
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Invoke-RipGrep {
    [Alias("irg")]
    [CmdletBinding()]
    param (
        [string] $Path = ".\",
        [string] $Pattern,
        [switch] $Literal,
        [int] $Context = 0,
        [switch] $CaseSensitive,
        [string[]] $Glob,
        [switch] $Hidden,
        [switch] $Invert,
        [switch] $NoColors,
        [switch] $FilenameOnly,
        [int] $MaxDepth = -1,
        [int] $MaxResultsPerFile = -1
    )

    $cmdBuilder = [System.Text.StringBuilder]::new("rg")

    if ($Literal) {
         [void]$cmdBuilder.Append(" -e")
    }

    [void]$cmdBuilder.Append(" $Pattern")
    [void]$cmdBuilder.Append(" $Path")

    if ($Context.Count -gt 0){
        [void]$cmdBuilder.Append(" -C $Context")
    }
    if ($CaseSensitive){
        [void]$cmdBuilder.Append(" -s")
    }
    if ($Glob){
        $Glob | ForEach-Object {
            [void]$cmdBuilder.Append(" -g $_")
        }
    }
    if ($Hidden){
        [void]$cmdBuilder.Append(" --hidden")
    }
    if ($Invert){
        [void]$cmdBuilder.Append(" --invert-match")
    }
    if ($MaxResultsPerFile -gt 0) {
        [void]$cmdBuilder.Append(" --max-count $MaxResultsPerFile")
    }
    if ($MaxDepth -gt 0) {
        [void]$cmdBuilder.Append(" --max-depth $MaxDepth")
    }
    if (-not ($NoColors)){
        [void]$cmdBuilder.Append(" -p")
    }
    if ($FilenameOnly){
        [void]$cmdBuilder.Append(" -l")
    }
    [void]$cmdBuilder.Append(" -n")
    
   $cmd = $cmdBuilder.ToString()
   Write-Verbose "Execute: $cmd"
   if ($Context -gt 0 -or $FilenameOnly){
       Invoke-Expression $cmd
   }
   else {
       Invoke-Expression $cmd | Group-RgOutput
   }
}

<#
.SYNOPSIS
Group the output piped from Ripgrep into Powershell hashtable.


.DESCRIPTION
Long description

.PARAMETER Line
Parameter description

.PARAMETER Pretty
Enable this if using -p to ripgrep

.EXAMPLE
PS > rg "function" -p | Group-RgOutput

filename                     LineNumber Line
--------                     ---------- ----
sha2decimal.ps1              1          function sha2Decimal ($sha) {
replace_default_database.ps1 1          function Invoke-ReplaceDefaultDatabase($ProjPath, $targetDb) {
RenameWorkspace.ps1          1          function Rename-CurrentP4Workspace {
removeObj.ps1                1          function Remove-Folders{
P4FindAndReplace.ps1         1          function Invoke-P4FindAndReplace {
NewBCTTicket.ps1             1          function New-BCTIntegrationTicket {
Invoke-FDU.ps1               1          function Invoke-FDU ([string] path]){

.NOTES
General notes
#>
function Group-RgOutput {
	[CmdletBinding()]
	param ( 
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[AllowEmptyString()]
		[string] $Line
	)

	begin {
		$results = [System.Collections.ArrayList]::new()
        $isFirstLine = $true
        $hasColor = $true
	}

	process {
        if ($isFirstLine -and $Line -notmatch "\[0m.*\[36m"){
            $hasColor = $false
        }

        if (-not [String]::IsNullOrEmpty($Line)) {
            $Line = $Line.Trim() 
            if ($hasColor){
                if ($Line -match "^.*\[32m(?<num>\d+).*:(?<line>.*)") {
                    [void] $results.Add([pscustomobject]@{
                            filename   = $lastFile;
                            LineNumber = $Matches.num;
                            Line       = $Matches.line
                        })
                }
                else{
                    $lastFile = $Line
                }
            }
			else {
				$tokens = $Line.Split(":")
                [void] $results.Add([pscustomobject]@{
                        filename = $tokens[0]
                        LineNumer = $tokens[1]
                        Line     = $tokens[2..$tokens.Count]
                    })
                }
			}
        $isFirstLine = $false
	}
	end {
		return $results
	}
}
