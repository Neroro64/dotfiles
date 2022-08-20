# Setup prompt
oh-my-posh init pwsh --config "$Home/.config/powershell/posh-themes/tokyo.omp.json" | Invoke-Expression
#
# ReadlineOptions
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function Complete
