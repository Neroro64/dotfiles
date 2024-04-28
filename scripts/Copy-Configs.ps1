function Copy-Configs {
  param(
    [switch] $Git,
    [switch] $Nvim,
    [switch] $Alacritty,
    [switch] $Powershell,
    [switch] $Ranger,
    [string] $DotFilesRelativePath = ".dotfiles"
  )

  $absolutePathToHome = "/home/$ENV:USERNAME/"
  if ($Git) {
    New-Item -Path:"$Home/.gitconfig" -Value:"$absolutePathToHome/$DotFilesRelativePath/configs/.gitconfig" -ItemType:SymbolicLink
  }
  if ($Nvim) {
    New-Item -Path:"$Home/.config/nvim" -Value:"$absolutePathToHome/$DotFilesRelativePath/configs/astrovim" -ItemType:SymbolicLink
  }
  if ($Alacritty) {
    New-Item -Path:"$Home/.config/alacritty" -Value:"$absolutePathToHome/$DotFilesRelativePath/configs/alacritty" -ItemType:SymbolicLink
  }
  if ($PowerShell) {
    New-Item -Path:"$Home/.config/powershell" -Value:"$absolutePathToHome/$DotFilesRelativePath/configs/powershell" -ItemType:SymbolicLink
  }
  if ($Ranger) {
    New-Item -Path:"$Home/.config/ranger" -Value:"$absolutePathToHome/$DotFilesRelativePath/configs/ranger" -ItemType:SymbolicLink
  }
}
