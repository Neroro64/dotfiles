
Sync-Backup -SourceDir:"/" -DestinationDir /mnt/f/Backup/sys.bak/ -FilterPath /home/nuoc/.dotfiles/scripts/backup.filter
New-rdiffBackup -SourceDir /mnt/f/Backup/sys.bak/ -DestinationDir /mnt/f/Backup/archive/

try {
# Sync to remote drive if available
Sync-Backup -SourceDir:"/" -DestinationDir /home/nuoc/Network/HoneyPot.Lake.Vanern/Backups/7950x -FilterPath /home/nuoc/.dotfiles/scripts/backup.filter
}
catch {}
