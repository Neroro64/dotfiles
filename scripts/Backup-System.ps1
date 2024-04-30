param(
  [switch] $SyncToRemoteRepo
)
. /home/nuoc/.config/powershell/scripts/Sync-Backup.ps1
. /home/nuoc/.config/powershell/scripts/New-rdiffBackup.ps1
. /home/nuoc/.config/powershell/scripts/Mount-SSHFS.ps1

Sync-Backup -SourceDir:"/" -DestinationDir /mnt/e/Backup/sys.bak/ -FilterPath /home/nuoc/.dotfiles/scripts/backup.filter
New-rdiffBackup -SourceDir /mnt/f/Backup/sys.bak/ -DestinationDir /mnt/f/Backup/archive/

if ($SyncToRemoteRepo) {
  try {
  # Sync to remote drive if available

  Mount-SSHFS -ConfigName honeypot -RemoteDir /home/homie/Lake/Vanern -MountPoint /home/nuoc/Network/HoneyPot.Lake.Vanern
  Sync-Backup -SourceDir:"/" -DestinationDir /home/nuoc/Network/HoneyPot.Lake.Vanern/Backups/7950x -FilterPath /home/nuoc/.dotfiles/scripts/backup.filter -Options "--archive", "--verbose", "--delete", "--progress", "-H", "--no-o", "--no-g"
  }
  catch {
    Write-Error "Failed to sync backup to remote repo. Error: $_"
  }
}
