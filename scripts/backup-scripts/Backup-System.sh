#!/bin/bash

# Default value for MaxSnapshotCount
MaxSnapshotCount=3

# Function to display usage information
usage() {
    echo "Usage: $0 -r <RepositoryName> -e <ExcludeFilePath> -i <IncludeFilePath> [-m <MaxSnapshotCount>]"
    echo "  -r: Repository name"
    echo "  -e: Path to exclude file"
    echo "  -i: Path to include file"
    echo "  -m: Maximum number of snapshots to keep (default: 3)"
    exit 1
}

# Parse command line arguments
while getopts ":r:e:i:m:" opt; do
    case $opt in
        r) RepositoryName="$OPTARG" ;;
        e) ExcludeFilePath="$OPTARG" ;;
        i) IncludeFilePath="$OPTARG" ;;
        m) MaxSnapshotCount="$OPTARG" ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# Check if required arguments are provided
if [ -z "$RepositoryName" ] || [ -z "$ExcludeFilePath" ] || [ -z "$IncludeFilePath" ]; then
    echo "Error: Missing required arguments."
    usage
fi

# Backup
restic backup --exclude-file "$ExcludeFilePath" --files-from "$IncludeFilePath" --repo "$RepositoryName"

# Clean old snapshots
restic forget --keep-last "$MaxSnapshotCount" --prune --repo "$RepositoryName"
