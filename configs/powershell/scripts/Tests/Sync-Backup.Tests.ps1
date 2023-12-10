BeforeAll {
    . "$PSScriptRoot/../Sync-Backup.ps1"
}
Describe "Sync-Backup" {
    It "Verify correct parameter bindings" {
        Mock Invoke-Expression -MockWith {} -Verifiable -ParameterFilter { $Command -eq "rsync --exclude **.cache --exclude **.part --exclude **.qcow2 --exclude **Trash --archive --verbose --delete --progress -H  C:\path\to\source C:\path\to\destination" }
        
        # Arrange
        $sourceDir = "C:\path\to\source"
        $destinationDir = "C:\path\to\destination"
        $expectedExclude = @("**.cache", "**.part", "**.qcow2", "**Trash")

        # Act
        Sync-Backup -SourceDir $sourceDir -DestinationDir $destinationDir -Exclude $expectedExclude

        # Assert
        Should -InvokeVerifiable
    }
    It "Verify correct parameter bindings with filter" {
        Mock Invoke-Expression -MockWith {} -Verifiable -ParameterFilter { $Command -eq "rsync --exclude **.cache --exclude **.part --exclude **.qcow2 --exclude **Trash --archive --verbose --delete --progress -H --filter=`"merge test/filter`" C:\path\to\source C:\path\to\destination" }
        
        # Arrange
        $sourceDir = "C:\path\to\source"
        $destinationDir = "C:\path\to\destination"
        $expectedExclude = @("**.cache", "**.part", "**.qcow2", "**Trash")
        $filterPath = "test/filter"

        # Act
        Sync-Backup -FilterPath:$filterPath -SourceDir:$sourceDir -DestinationDir:$destinationDir -Exclude:$expectedExclude

        # Assert
        Should -InvokeVerifiable
    }
}