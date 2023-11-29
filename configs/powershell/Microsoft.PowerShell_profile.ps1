# Setup prompt
oh-my-posh init pwsh --config "$PSScriptRoot/posh-themes/nordtron.omp.json" | Invoke-Expression

#
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


# Alias
Set-Alias -Name lg -Value lazygit
Set-Alias -Name rng -Value ranger
Set-Alias -Name hx -Value helix

# Import
Import-Module $PSScriptRoot/scripts/_fd.psm1 -Force


$ENV:LD_LIBRARY_PATH += ":/home/nuoc/.local/lib/mojo"
$ENV:PATH += ":~/.modular/pkg/packages.modular.com_mojo/bin/"
