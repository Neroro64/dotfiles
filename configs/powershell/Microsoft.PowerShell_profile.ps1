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

# Alias
Set-Alias -Name lg -Value lazygit
Set-Alias -Name rng -Value ranger
