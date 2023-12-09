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