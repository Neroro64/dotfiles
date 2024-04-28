# Get user name
$user = $ENV:USER

# Setup prompt
try {
	oh-my-posh init pwsh --config "$PSScriptRoot/posh-themes/tokyonight_storm.omp.json" | Invoke-Expression
}
catch {
	Write-Warning "Oh-My-Posh is not installed. Skipping."
}

# ReadlineOptions

Set-PSReadLineOption `
 -EditMode Vi -ViModeIndicator Cursor `
 -HistoryNoDuplicates  -HistorySearchCursorMovesToEnd `
 -MaximumHistoryCount 1000 `
 -PredictionSource HistoryAndPlugin  -PredictionViewStyle ListView 

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Store previous command's output in $__
$PSDefaultParameterValues['Out-Default:OutVariable'] = '__'

# Environment variables
$ENV:PATH+=":/root/.local/bin"
$ENV:PATH+=":~/.local/bin"
$ENV:PATH+=":~/.cargo/bin"
$ENV:MANGOHUD_CONFIG="~/.config/MangoHUD/mangohud.conf"

$ENV:PATH += ":~/.bun/bin"

# Mojo stuff
$ENV:LD_LIBRARY_PATH += ":/home/$user/.local/lib/mojo"
$ENV:MAX_PATH = "/home/$user/.modular/pkg/packages.modular.com_max"
$ENV:PATH += ":/home/$user/.modular/pkg/packages.modular.com_nightly_mojo/bin/"
$ENV:PATH += ":/home/$user/.modular/pkg/packages.modular.com_max/bin/"
$ENV:MOJO_PYTHON_LIBRARY="/usr/lib/libpython3.11.so"

# Alias
Set-Alias -Name lg -Value lazygit
Set-Alias -Name rng -Value ranger
Set-Alias -Name hx -Value helix

# Import
Import-Module $PSScriptRoot/scripts/_fd.psm1 -Force
. $PSScriptRoot/scripts/Mount-SSHFS.ps1

# Auto mount external drives
function Mount-RemoteDrives{
 Mount-SSHFS -ConfigName honeypot -RemoteDir /home/homie/Lake/Vattern -MountPoint /home/$user/Network/HoneyPot.Lake.Vattern
 Mount-SSHFS -ConfigName honeypot -RemoteDir /home/homie/Lake/Vanern -MountPoint /home/$user/Network/HoneyPot.Lake.Vanern
}
