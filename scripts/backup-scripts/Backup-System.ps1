param(
  [string] $RepositoryName,
  [string] $ExcludeFilePath,
  [string] $IncludeFilePath,
  [int] $MaxSnapshotCount = 3
)

# Backup
restic backup --exclude-file $ExcludeFilePath --files-from $IncludeFilePath --repo $RepositoryName

# Clean old snapshots
restic forget --keep-last $MaxSnapshotCount --prune
