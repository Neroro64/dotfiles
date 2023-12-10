$backupName = "$(get-date -Format "yy.MM.dd").from_homePC"

Sync-Backup -SourceDir:"/" -DestinationDir /mnt/f/Backup/$backupName/ -FilterPath /home/nuoc/.dotfiles/scripts/backup.filter

try {
New-rdiffBackup -SourceDir /mnt/f/Backup/$backupName/ -DestinationDir /home/nuoc/Network/HoneyPot.Lake.Vanern/Backups/7590x/
}
catch {}
