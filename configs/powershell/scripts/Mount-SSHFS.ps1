<#
  .SYNOPSIS
  Mounts a remote directory using SSHFS.

  .DESCRIPTION
  This function mounts a remote directory using SSHFS. It can be used either with a configuration name or by specifying the user and hostname manually.

  .PARAMETER ConfigName
  The name of the SSHFS configuration to use. This parameter is mutually exclusive with the Manual parameter set.

  .PARAMETER User
  The username to use for SSHFS. This parameter is mutually exclusive with the ConfigName parameter.

  .PARAMETER HostName
  The hostname to use for SSHFS. This parameter is mutually exclusive with the ConfigName parameter.

  .PARAMETER RemoteDir
  The remote directory to mount.

  .PARAMETER MountPoint
  The local mount point directory.

  #>
function Mount-SSHFS {
  param(
    [Parameter(ParameterSetName = "UseConfig")]
    [string] $ConfigName,
    [Parameter(ParameterSetName = "Manual")]
    [string] $User,
    [Parameter(ParameterSetName = "Manual")]
    [string] $HostName,

    [string] $RemoteDir,
    [string] $MountPoint
  )

  $RemoteLocation = ($PSCmdlet.ParameterSetName -eq "UseConfig")?
  "$ConfigName`:$RemoteDir" : "$User@$Hostname`:$RemoteDir"

  Invoke-Expression "sshfs -o Ciphers=aes128-ctr -o cache=no $RemoteLocation $MountPoint"
}

<#
.SYNOPSIS
Dismount-SSHFS function is used to unmount an SSHFS directory.

.PARAMETER MountPoint
The path to the mounted SSHFS directory

.EXAMPLE
Dismount-SSHFS -MountPoint '/path/to/mountpoint'
#>
function Dismount-SSHFS {
  param(
    [string] $MountPoint
  )

  Invoke-Expression "fusermount3 -u $MountPoint"
}

Register-ArgumentCompleter -CommandName Mount-SSHFS -ParameterName:ConfigName -ScriptBlock: {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

  # Read the entries from the text file
  $entries = Get-Content "$Home/.ssh/config"
  $hostProfiles = $entries | Where-Object { $_ -match "^Host\s[\S]+$" } | ForEach-Object { $_.Split(" ")[-1] }

  # Filter the entries based on the word to complete
  $completions = $hostProfiles | Where-Object { $_ -like "$wordToComplete*" }

  # Return the completion results
  $completions | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}