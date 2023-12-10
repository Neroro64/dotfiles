BeforeAll {
  . "$PSScriptRoot/../Mount-SSHFS.ps1"
}

Describe "Verify correct parameter bindings" {
  It "Can invoke command with UseConfig ParameterSet" {
    # Arrange
    Mock Invoke-Expression -MockWith {} -Verifiable -ParameterFilter { $Command -eq "sshfs -o Ciphers=aes128-ctr -o cache=no testConfig:/home/test /root" }

    # Action
    Mount-SSHFS -ConfigName:testConfig -RemoteDir:"/home/test" -MountPoint:"/root"
    
    # Assert
    Should -InvokeVerifiable
  }

  It "Can invoke command with Manual ParameterSet" {
    # Arrange
    Mock Invoke-Expression -MockWith {} -Verifiable -ParameterFilter {$Command -eq "sshfs -o Ciphers=aes128-ctr -o cache=no user@host.com:/home/test /root"}

    # Action
    Mount-SSHFS -User:"user" -HostName:"host.com" -RemoteDir:"/home/test" -MountPoint:"/root"
    
    # Assert
    Should -InvokeVerifiable
  }

}
