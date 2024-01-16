<#
.SYNOPSIS
    This function performs a synchronized backup of a directory to another directory using rsync.

.DESCRIPTION
    This function uses the rsync command-line utility to perform a synchronized backup of a specified source directory to a specified destination directory.
    It allows you to exclude certain files or directories from the backup using the "$Exclude" parameter, and specify additional options to be passed to rsync using the "$Options" parameter.

.PARAMETER SourceDir
    The path of the source directory to be backed up. Default is $HOME.

.PARAMETER DestinationDir
    The path of the destination directory where the backup will be stored. This parameter is mandatory.

.PARAMETER FilterPath
    The path of the custom rsync filter file.

.PARAMETER Exclude
    An array of file or directory patterns to exclude from the backup. Default patterns are "**.cache", "**.part", "**.qcow2", and "**Trash".

.PARAMETER Options
    An array of additional options to be passed to the rsync command. Default options are "--archive", "--verbose", and "--delete".

.EXAMPLE
    Sync-Backup -SourceDir "C:\Documents" -DestinationDir "D:\Backup" -Exclude "*.tmp" -Options "--progress"

.NOTES
    This function requires the rsync command-line utility to be installed and accessible from the system's PATH environment variable.
#>

function Sync-Backup {
    param(
        [string] $SourceDir = $HOME,
        [string] $DestinationDir,
        [string] $FilterPath,
        [string[]] $Exclude = @("**.cache", "**.part", "**.qcow2", "**Trash"),
        [string[]] $Options = @("--archive", "--quiet", "--delete", "--progress", "-H")
    )
    $ErrorActionPreference = "Stop"
    $excludeStr = ($Exclude | ForEach-Object { "--exclude $_" }) -join " "
    $optionStr = $Options -join " "
    $filterStr = ($FilterPath) ? "--filter=`"merge $FilterPath`"" : ""
    
    Invoke-Expression "rsync $excludeStr $optionStr $filterStr $SourceDir $DestinationDir"
}
