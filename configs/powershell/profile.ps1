# =============================================================================
# PowerShell Profile — modern interactive defaults
# =============================================================================

# ── Encoding ────────────────────────────────────────────────────────────────
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# ── Environment ─────────────────────────────────────────────────────────────
$env:EDITOR  ??= 'nvim'
$env:VISUAL  ??= 'nvim'
$env:PAGER   ??= 'delta'

# ── PATH ────────────────────────────────────────────────────────────────────
$env:PATH = @(
    $env:PATH
    '~/.local/bin'
    '~/.dotnet/tools'
    '~/.cargo/bin'
    '~/.bun/bin'
) -join ':'

# ── PSStyle ─────────────────────────────────────────────────────────────────
$PSStyle.FileInfo.Directory          = "`e[34;1m"
$PSStyle.FileInfo.SymbolicLink       = "`e[36m"
$PSStyle.FileInfo.Executable         = "`e[32m"
$PSStyle.Progress.View               = 'Classic'

# ── PSReadLine ──────────────────────────────────────────────────────────────
Set-PSReadLineOption `
    -EditMode                Vi `
    -ViModeIndicator         Cursor `
    -HistoryNoDuplicates `
    -HistorySearchCursorMovesToEnd `
    -MaximumHistoryCount     10000 `
    -PredictionSource        HistoryAndPlugin `
    -PredictionViewStyle     ListView `
    -BellStyle               None `
    -Colors                  @{ Command = 'Yellow'; Parameter = 'Green'; String = 'Cyan' }

# Key handlers
Set-PSReadLineKeyHandler -Key UpArrow       -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow     -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab           -Function MenuComplete
Set-PSReadLineKeyHandler -Key RightArrow    -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Chord 'Ctrl+d'   -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Chord 'Ctrl+u'   -Function BackwardKillLine
Set-PSReadLineKeyHandler -Chord 'Ctrl+w'   -Function BackwardKillWord

# Store previous command's output in $__
$PSDefaultParameterValues['Out-Default:OutVariable'] = '__'

# ── Modules ─────────────────────────────────────────────────────────────────
# Terminal-Icons — pretty file listings with icons
if (-not (Get-Module -ListAvailable Terminal-Icons)) {
    Install-Module Terminal-Icons -Scope CurrentUser -Force -ErrorAction SilentlyContinue
}
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# CompletionPredictor — feeds PSReadLine predictions
Import-Module CompletionPredictor -ErrorAction SilentlyContinue

# ── Aliases ─────────────────────────────────────────────────────────────────
Remove-Alias -Name grep -ErrorAction SilentlyContinue  # don't shadow system grep
Set-Alias -Name lg    -Value lazygit
Set-Alias -Name which -Value Get-Command
Set-Alias -Name open  -Value Invoke-Item

function touch  { New-Item -ItemType File -Path $args -Force }
function ll     { Get-ChildItem -Force @args }
function ..     { Set-Location .. }
function ...    { Set-Location ../.. }
function ....   { Set-Location ../../.. }

# ── Prompt (Starship) ───────────────────────────────────────────────────────
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_CONFIG ??= "$HOME/.config/starship.toml"
    Invoke-Expression (&starship init powershell)
}

# ── Custom scripts ──────────────────────────────────────────────────────────

Import-Module Microsoft.PowerShell.UnixTabCompletion
. "$HOME/.cargo/env.ps1"
