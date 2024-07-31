<#
.SYNOPSIS
Performs a backup of the specified source directory to the specified destination directory using rdiff-backup.

.DESCRIPTION
This function performs a backup of the specified source directory to the specified destination directory using the rdiff-backup tool. It also removes old backup increments that are older than 2 weeks.

.PARAMETER SourceDir
The source directory to be backed up. Defaults to the user's home directory if not specified.

.PARAMETER DestinationDir
The destination directory where the backup will be stored.
#>
function New-rdiffBackup
{
    param(
        [Parameter(Mandatory = $true)]
        [string] $SourceDir,
        [Parameter(Mandatory = $true)]
        [string] $DestinationDir
    )
    
    # Perform the backup using rdiff-backup
    rdiff-backup backup --print-statistics $SourceDir $DestinationDir
    
    # Remove old backup increments that are older than 2 weeks
    rdiff-backup remove increments --older-than 2W $DestinationDir    
}