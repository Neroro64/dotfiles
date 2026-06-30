-- EmberBox: A Gruvbox-Material dark theme styled after the Mojo docs.
-- Warm Gruvbox bg with muted accents; functions yellow, strings aqua,
-- punctuation in Mojo's signature periwinkle.

local M = {}

-- ╭──────────────────────────────────────────────────────────╮
-- │ Palettes                                                 │
-- │ Dark: Gruvbox Material on Gruvbox bg (matches mojolang.org). │
-- ╰──────────────────────────────────────────────────────────╯

local palettes = {
  light = {
    -- Clean ash/parchment backgrounds
    bg = "#f9f5d7", -- Gruvbox light bg0
    bg_dark = "#f2e5bc", -- Gruvbox light bg1
    bg_light = "#ffffff",
    bg_visual = "#eadaa3",
    bg_search = "#f0d6a0",
    bg_cursor = "#eadaa3",
    bg_popup = "#f2e5bc",
    bg_nc = "#f9f5d7",

    -- Text
    fg_bright = "#282828",
    fg = "#3c3836",
    fg_muted = "#7c6f64",
    fg_subtle = "#928374",

    -- Accents (Gruvbox Light)
    red = "#9d0006",
    orange = "#af3a03",
    yellow = "#b57614",
    green = "#79740e",
    ruby = "#8f3f71", -- Gruvbox dark purple/pink
    coral = "#c87040", -- Soft peach/orange
    purple = "#8f3f71",
    pink = "#9d0006", -- red-ish (punctuation, imports; was periwinkle)

    -- Brighter variants
    bright_red = "#cc241d",
    bright_orange = "#d65d0e",
    bright_yellow = "#d79921",
    bright_green = "#98971a",
    bright_ruby = "#b16286",
    bright_coral = "#e09560",
    bright_purple = "#b16286",
    bright_pink = "#d3869b",

    -- Grays
    gray1 = "#d5c4a1",
    gray2 = "#bdae93",
    gray3 = "#a89984",
    gray4 = "#928374",
    gray5 = "#7c6f64",

    border = "#bdae93",

    -- Semantic
    error = "#cc241d",
    warn = "#d65d0e",
    info = "#b16286",
    hint = "#98971a",

    git_add = "#98971a",
    git_change = "#d79921",
    git_delete = "#cc241d",

    -- Virtual text
    vbg_error = "#f5dede",
    vbg_warn = "#f5e5d0",
    vbg_info = "#eadce4",
    vbg_hint = "#dde8d8",

    -- Gitsigns
    gs_add_bg = "#e8f0e0",
    gs_change_bg = "#f0ead0",
    gs_delete_bg = "#f5dede",
  },

  dark = {
    -- Mojo docs style: Gruvbox-Material muted accents on Gruvbox bg.
    -- Hex values sourced from the rendered mojolang.org code blocks.
    bg = "#282828", -- Gruvbox bg0 (Mojo code-block bg)
    bg_dark = "#1d2021", -- Gruvbox bg0 hard (statusline / winbar)
    bg_light = "#504945", -- Gruvbox bg2 (popups, floats — elevated for selection contrast)
    bg_visual = "#3c3836", -- Gruvbox bg1 (visual select)
    bg_search = "#3c3836",
    bg_cursor = "#32302f", -- Subtle cursor-line tint
    bg_popup = "#32302f",
    bg_nc = "#252220", -- Non-current window

    -- Text (Gruvbox)
    fg_bright = "#fbf1c7", -- Gruvbox fg0
    fg = "#ebdbb2", -- Gruvbox fg1 (Mojo default code color)
    fg_muted = "#a89984", -- Gruvbox gray (Mojo operator/comment color)
    fg_subtle = "#928374", -- Gruvbox dark gray

    -- Accents (Gruvbox Material muted palette — as rendered by Mojo docs).
    -- pink maps to the keyword red (imports, punctuation, decorators).
    red = "#ea6962", -- keywords, errors (Mojo keyword red)
    orange = "#e78a4e", -- UI accent (Gruvbox Material orange)
    yellow = "#d8a657", -- functions, TODO (Mojo function yellow)
    green = "#89b482", -- strings (Gruvbox Material aqua — Mojo uses aqua for strings)
    ruby = "#d3869b", -- numbers, constants (Mojo number purple)
    coral = "#e78a4e", -- alias orange (module / UI accents)
    purple = "#d3869b", -- alias ruby
    pink = "#ea6962", -- red (was periwinkle: imports, punctuation, decorators)

    -- Brighter variants (emphasis / search highlights)
    bright_red = "#f2594a",
    bright_orange = "#f2814c",
    bright_yellow = "#e8b86a",
    bright_green = "#9bc892",
    bright_ruby = "#e09eae",
    bright_coral = "#f2814c",
    bright_purple = "#e09eae",
    bright_pink = "#f2594a", -- bright red (was light periwinkle)

    -- Grays (Gruvbox ramp)
    gray1 = "#3c3836",
    gray2 = "#504945",
    gray3 = "#665c54",
    gray4 = "#928374",
    gray5 = "#a89984",

    border = "#3c3836", -- Gruvbox bg1

    -- Semantic (harmonized with Gruvbox Material)
    error = "#ea6962", -- red
    warn = "#d8a657", -- yellow
    info = "#d3869b", -- purple (was teal/blue; avoids blue in diagnostics)
    hint = "#89b482", -- aqua

    git_add = "#89b482", -- aqua
    git_change = "#d8a657", -- yellow
    git_delete = "#ea6962", -- red

    -- Diagnostic virtual-text backgrounds (low-sat tints on Gruvbox bg)
    vbg_error = "#3b1c1c",
    vbg_warn = "#38301c",
    vbg_info = "#1c2a26",
    vbg_hint = "#1c281e",

    -- Gitsigns line backgrounds
    gs_add_bg = "#1f2a1e",
    gs_change_bg = "#342d17",
    gs_delete_bg = "#341c1c",
  },
}

-- ╭──────────────────────────────────────────────────────────╮
-- │ Highlight Groups                                         │
-- │ Solarized Chandrian logic applied to EmberBox palette.   │
-- ╰──────────────────────────────────────────────────────────╯

local function make_groups(p)
  return {
    ---- Editor base ------------------------------------------------

    Normal = { fg = p.fg, bg = p.bg },
    NormalFloat = { fg = p.fg, bg = p.bg_light },
    NormalNC = { fg = p.fg_muted, bg = p.bg_nc },
    FloatBorder = { fg = p.border, bg = p.bg_light },
    FloatTitle = { fg = p.fg_bright, bg = p.bg_light, bold = true },

    Cursor = { fg = p.bg, bg = p.fg_bright },
    CursorLine = { bg = p.bg_cursor },
    CursorColumn = { bg = p.bg_cursor },
    CursorLineNr = { fg = p.orange, bold = true },
    CursorLineSign = { bg = p.bg_cursor },
    CursorLineFold = { bg = p.bg_cursor },
    ColorColumn = { bg = p.bg_dark },

    LineNr = { fg = p.gray3 },
    SignColumn = { bg = p.bg },
    FoldColumn = { fg = p.fg_subtle, bg = p.bg },
    Folded = { fg = p.fg_muted, bg = p.bg_dark, italic = true },

    Visual = { bg = p.bg_visual },
    VisualNOS = { bg = p.bg_visual },

    Search = { fg = p.bg_dark, bg = p.bright_orange, bold = true },
    IncSearch = { fg = p.bg_dark, bg = p.orange, bold = true },
    CurSearch = { fg = p.bg_dark, bg = p.orange, bold = true },
    Substitute = { fg = p.bg_dark, bg = p.pink },

    StatusLine = { fg = p.fg, bg = p.bg_dark },
    StatusLineNC = { fg = p.fg_subtle, bg = p.bg_dark },

    WinBar = { fg = p.fg_bright, bg = p.bg_dark, bold = true },
    WinBarNC = { fg = p.fg_muted, bg = p.bg_dark },
    WinSeparator = { fg = p.gray2 },

    TabLine = { fg = p.fg_muted, bg = p.bg_dark },
    TabLineFill = { fg = p.fg_muted, bg = p.bg_dark },
    TabLineSel = { fg = p.fg_bright, bg = p.bg, bold = true },

    EndOfBuffer = { fg = p.bg },
    NonText = { fg = p.gray2 },
    Whitespace = { fg = p.gray1 },
    SpecialKey = { fg = p.gray3 },

    Pmenu = { fg = p.fg, bg = p.bg_visual },
    PmenuSel = { fg = p.fg_bright, bg = p.bg_nc, bold = true },
    PmenuSbar = { bg = p.gray1 },
    PmenuThumb = { bg = p.gray3 },
    WildMenu = { fg = p.fg_bright, bg = p.bg_visual },

    QuickFixLine = { bg = p.bg_visual },
    MatchParen = { fg = p.orange, bg = p.bg_visual, bold = true },

    ModeMsg = { fg = p.fg_muted },
    MoreMsg = { fg = p.orange },
    Question = { fg = p.coral },
    MsgArea = { fg = p.fg },
    MsgSeparator = { fg = p.gray2 },

    Directory = { fg = p.orange, bold = true },
    Title = { fg = p.orange, bold = true },
    Bold = { bold = true },
    Italic = { italic = true },

    Conceal = { fg = p.fg_subtle },
    SpellBad = { undercurl = true, sp = p.red },
    SpellCap = { undercurl = true, sp = p.coral },
    SpellLocal = { undercurl = true, sp = p.coral },
    SpellRare = { undercurl = true, sp = p.purple },

    ---- Syntax (EmberBox/Chandrian Architecture) -------------------

    Comment = { fg = p.fg_muted, italic = true },
    Todo = { fg = p.bg_dark, bg = p.yellow, bold = true, italic = true },
    Error = { fg = p.error },
    ErrorMsg = { fg = p.error },
    WarningMsg = { fg = p.warn },

    String = { fg = p.green },
    Character = { fg = p.green },
    Number = { fg = p.ruby },
    Boolean = { fg = p.ruby, bold = true },
    Float = { fg = p.ruby },
    Constant = { fg = p.ruby },

    Identifier = { fg = p.fg },
    Function = { fg = p.yellow, bold = true },

    Statement = { fg = p.red },
    Conditional = { fg = p.red },
    Repeat = { fg = p.red },
    Label = { fg = p.orange },
    Operator = { fg = p.fg_muted },
    Keyword = { fg = p.red, italic = true },
    Exception = { fg = p.red },

    PreProc = { fg = p.pink },
    Include = { fg = p.pink },
    Define = { fg = p.pink },
    Macro = { fg = p.bright_pink },
    PreCondit = { fg = p.pink },

    Type = { fg = p.fg },
    StorageClass = { fg = p.orange },
    Structure = { fg = p.fg },
    Typedef = { fg = p.fg },

    Special = { fg = p.orange },
    SpecialChar = { fg = p.orange },
    Tag = { fg = p.orange },
    Delimiter = { fg = p.pink },
    SpecialComment = { fg = p.fg_muted, italic = true },
    Debug = { fg = p.bright_orange },

    Underlined = { fg = p.orange, underline = true },
    Ignore = { fg = p.fg_subtle },

    ---- Tree-sitter ------------------------------------------------

    ["@variable"] = { fg = p.fg },
    ["@variable.builtin"] = { fg = p.ruby, italic = true },
    ["@variable.parameter"] = { fg = p.fg_muted, italic = true },
    ["@variable.member"] = { fg = p.fg },
    ["@constant"] = { fg = p.ruby },
    ["@constant.builtin"] = { fg = p.ruby, bold = true },
    ["@constant.macro"] = { fg = p.pink },

    ["@module"] = { fg = p.coral },
    ["@namespace"] = { fg = p.coral },
    ["@label"] = { fg = p.orange },

    ["@string"] = { fg = p.green },
    ["@string.regexp"] = { fg = p.ruby },
    ["@string.escape"] = { fg = p.bright_ruby },
    ["@string.special"] = { fg = p.orange },
    ["@string.delimiter"] = { fg = p.fg_muted },

    ["@character"] = { fg = p.green },
    ["@character.special"] = { fg = p.orange },
    ["@boolean"] = { fg = p.ruby, bold = true },
    ["@number"] = { fg = p.ruby },
    ["@float"] = { fg = p.ruby },

    ["@function"] = { fg = p.yellow, bold = true },
    ["@function.call"] = { fg = p.yellow },
    ["@function.builtin"] = { fg = p.bright_yellow, bold = true },
    ["@function.macro"] = { fg = p.pink },
    ["@method"] = { fg = p.yellow, bold = true },
    ["@method.call"] = { fg = p.yellow },
    ["@constructor"] = { fg = p.yellow, bold = true },
    ["@parameter"] = { fg = p.fg_muted, italic = true },

    ["@property"] = { fg = p.fg },
    ["@field"] = { fg = p.fg },

    ["@type"] = { fg = p.fg },
    ["@type.builtin"] = { fg = p.fg, italic = true },
    ["@type.definition"] = { fg = p.fg },
    ["@type.qualifier"] = { fg = p.red },
    ["@class"] = { fg = p.fg },
    ["@enum"] = { fg = p.fg },
    ["@interface"] = { fg = p.fg },
    ["@struct"] = { fg = p.fg },
    ["@union"] = { fg = p.fg },

    ["@attribute"] = { fg = p.pink },
    ["@annotation"] = { fg = p.pink, italic = true },

    ["@keyword"] = { fg = p.red, italic = true },
    ["@keyword.function"] = { fg = p.red, italic = true },
    ["@keyword.operator"] = { fg = p.red },
    ["@keyword.return"] = { fg = p.red, italic = true },
    ["@keyword.debug"] = { fg = p.bright_orange },
    ["@keyword.exception"] = { fg = p.red },
    ["@keyword.conditional"] = { fg = p.red, italic = true },
    ["@keyword.repeat"] = { fg = p.red, italic = true },
    ["@keyword.import"] = { fg = p.red },
    ["@keyword.storage"] = { fg = p.orange },
    ["@keyword.coroutine"] = { fg = p.red },
    ["@keyword.directive"] = { fg = p.pink },

    ["@conditional"] = { link = "@keyword.conditional" },
    ["@repeat"] = { link = "@keyword.repeat" },
    ["@for"] = { link = "@keyword.repeat" },
    ["@while"] = { link = "@keyword.repeat" },

    ["@operator"] = { fg = p.fg_muted },

    ["@comment"] = { fg = p.fg_muted, italic = true },
    ["@comment.documentation"] = { fg = p.fg_muted, italic = true },
    ["@comment.todo"] = { fg = p.bg_dark, bg = p.yellow, bold = true },
    ["@comment.error"] = { fg = p.error },
    ["@comment.warning"] = { fg = p.warn },
    ["@comment.note"] = { fg = p.purple },

    ["@punctuation"] = { fg = p.pink },
    ["@punctuation.bracket"] = { fg = p.pink },
    ["@punctuation.delimiter"] = { fg = p.pink },
    ["@punctuation.special"] = { fg = p.pink },

    ["@tag"] = { fg = p.red },
    ["@tag.attribute"] = { fg = p.orange },
    ["@tag.delimiter"] = { fg = p.fg_muted },

    ["@text"] = { fg = p.fg },
    ["@text.literal"] = { fg = p.green },
    ["@text.reference"] = { fg = p.orange },
    ["@text.emphasis"] = { italic = true },
    ["@text.strong"] = { bold = true },
    ["@text.title"] = { fg = p.orange, bold = true },
    ["@text.uri"] = { fg = p.orange, underline = true },
    ["@text.math"] = { fg = p.ruby },
    ["@text.note"] = { fg = p.purple },
    ["@text.danger"] = { fg = p.error },
    ["@text.warning"] = { fg = p.warn },
    ["@text.diff.add"] = { fg = p.git_add },
    ["@text.diff.delete"] = { fg = p.git_delete },

    ["@diff.plus"] = { fg = p.git_add },
    ["@diff.minus"] = { fg = p.git_delete },
    ["@diff.delta"] = { fg = p.git_change },

    ["@define"] = { fg = p.pink },
    ["@macro"] = { fg = p.pink },
    ["@include"] = { fg = p.pink },
    ["@preproc"] = { fg = p.pink },
    ["@exception"] = { fg = p.red },
    ["@error"] = { fg = p.error },

    ---- LSP semantic tokens ----------------------------------------

    ["@lsp.type.class"] = { link = "@class" },
    ["@lsp.type.enum"] = { link = "@enum" },
    ["@lsp.type.interface"] = { link = "@interface" },
    ["@lsp.type.struct"] = { link = "@struct" },
    ["@lsp.type.typeParameter"] = { fg = p.coral, italic = true },
    ["@lsp.type.decorator"] = { fg = p.yellow },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.macro"] = { fg = p.pink },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.method"] = { link = "@method" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.variable"] = { link = "@variable" },

    ---- Diagnostics ------------------------------------------------

    DiagnosticError = { fg = p.error },
    DiagnosticWarn = { fg = p.warn },
    DiagnosticInfo = { fg = p.info },
    DiagnosticHint = { fg = p.hint },
    DiagnosticOk = { fg = p.green },

    DiagnosticSignError = { fg = p.error },
    DiagnosticSignWarn = { fg = p.warn },
    DiagnosticSignInfo = { fg = p.info },
    DiagnosticSignHint = { fg = p.hint },

    DiagnosticVirtualTextError = { fg = p.error, bg = p.vbg_error },
    DiagnosticVirtualTextWarn = { fg = p.warn, bg = p.vbg_warn },
    DiagnosticVirtualTextInfo = { fg = p.info, bg = p.vbg_info },
    DiagnosticVirtualTextHint = { fg = p.hint, bg = p.vbg_hint },

    DiagnosticUnderlineError = { undercurl = true, sp = p.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = p.warn },
    DiagnosticUnderlineInfo = { undercurl = true, sp = p.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = p.hint },

    ---- LSP --------------------------------------------------------

    LspReferenceText = { bg = p.bg_visual },
    LspReferenceRead = { bg = p.bg_visual },
    LspReferenceWrite = { bg = p.bg_visual, underline = true },
    LspCodeLens = { fg = p.fg_subtle, italic = true },
    LspCodeLensSeparator = { fg = p.gray3 },
    LspInlayHint = { fg = p.fg_subtle, bg = p.bg_cursor, italic = true },
    LspSignatureActiveParameter = { fg = p.orange },

    ---- Git / Diff -------------------------------------------------

    diffAdded = { fg = p.git_add },
    diffChanged = { fg = p.git_change },
    diffRemoved = { fg = p.git_delete },
    diffFile = { fg = p.orange },
    diffNewFile = { fg = p.git_add },
    diffLine = { fg = p.fg_subtle },
    diffIndexLine = { fg = p.fg_muted },

    ---- blink.cmp --------------------------------------------------

    BlinkCmpDoc = { fg = p.fg, bg = p.bg_light },
    BlinkCmpDocBorder = { fg = p.border, bg = p.bg_light },
    BlinkCmpDocCursorLine = { bg = p.bg_visual },
    BlinkCmpGhostText = { fg = p.gray3 },
    BlinkCmpKind = { fg = p.fg },
    BlinkCmpKindText = { fg = p.green },
    BlinkCmpKindMethod = { fg = p.yellow },
    BlinkCmpKindFunction = { fg = p.yellow },
    BlinkCmpKindConstructor = { fg = p.yellow },
    BlinkCmpKindField = { fg = p.fg },
    BlinkCmpKindVariable = { fg = p.fg },
    BlinkCmpKindClass = { fg = p.coral },
    BlinkCmpKindInterface = { fg = p.coral },
    BlinkCmpKindModule = { fg = p.coral },
    BlinkCmpKindProperty = { fg = p.fg },
    BlinkCmpKindUnit = { fg = p.ruby },
    BlinkCmpKindValue = { fg = p.ruby },
    BlinkCmpKindEnum = { fg = p.coral },
    BlinkCmpKindKeyword = { fg = p.red },
    BlinkCmpKindSnippet = { fg = p.pink },
    BlinkCmpKindColor = { fg = p.purple },
    BlinkCmpKindFile = { fg = p.orange },
    BlinkCmpKindReference = { fg = p.orange },
    BlinkCmpKindFolder = { fg = p.orange },
    BlinkCmpKindEnumMember = { fg = p.ruby },
    BlinkCmpKindConstant = { fg = p.ruby },
    BlinkCmpKindStruct = { fg = p.coral },
    BlinkCmpKindEvent = { fg = p.orange },
    BlinkCmpKindOperator = { fg = p.fg_muted },
    BlinkCmpKindTypeParameter = { fg = p.coral, italic = true },

    ---- bufferline -------------------------------------------------

    BufferLineFill = { bg = p.bg_dark },
    BufferLineBackground = { fg = p.fg_muted, bg = p.bg_dark },
    BufferLineBuffer = { fg = p.fg_muted, bg = p.bg_dark },
    BufferLineBufferSelected = { fg = p.fg_bright, bg = p.bg },
    BufferLineBufferVisible = { fg = p.fg, bg = p.bg },
    BufferLineSeparator = { fg = p.gray2, bg = p.bg_dark },
    BufferLineSeparatorSelected = { fg = p.gray2, bg = p.bg },
    BufferLineIndicatorSelected = { fg = p.orange, bg = p.bg },
    BufferLineCloseButton = { fg = p.fg_subtle, bg = p.bg_dark },
    BufferLineCloseButtonSelected = { fg = p.red, bg = p.bg },
    BufferLineModified = { fg = p.git_change, bg = p.bg_dark },
    BufferLineModifiedSelected = { fg = p.git_change, bg = p.bg },
    BufferLineTab = { fg = p.orange, bg = p.bg_dark },
    BufferLineTabSelected = { fg = p.orange, bg = p.bg },
    BufferLineTabClose = { fg = p.red, bg = p.bg_dark },
    BufferLineDuplicate = { fg = p.fg_subtle, bg = p.bg_dark },
    BufferLineDuplicateSelected = { fg = p.fg, bg = p.bg },

    ---- flash.nvim -------------------------------------------------

    FlashBackdrop = { fg = p.fg_subtle },
    FlashLabel = { fg = p.bg_dark, bg = p.bright_orange },
    FlashMatch = { fg = p.purple, bg = p.bg_search },
    FlashCurrent = { fg = p.orange, bg = p.bg_search },
    FlashCursor = { fg = p.bg_dark, bg = p.orange },
    FlashPrompt = { fg = p.fg },

    ---- gitsigns ---------------------------------------------------

    GitSignsAdd = { fg = p.git_add },
    GitSignsChange = { fg = p.git_change },
    GitSignsDelete = { fg = p.git_delete },
    GitSignsAddLn = { fg = p.git_add, bg = p.gs_add_bg },
    GitSignsChangeLn = { fg = p.git_change, bg = p.gs_change_bg },
    GitSignsDeleteLn = { fg = p.git_delete, bg = p.gs_delete_bg },
    GitSignsAddCul = { fg = p.git_add, bg = p.bg_cursor },
    GitSignsChangeCul = { fg = p.git_change, bg = p.bg_cursor },
    GitSignsDeleteCul = { fg = p.git_delete, bg = p.bg_cursor },
    GitSignsStagedAdd = { fg = p.gray4 },
    GitSignsStagedChange = { fg = p.gray4 },
    GitSignsStagedDelete = { fg = p.gray4 },

    ---- indent-blankline -------------------------------------------

    IblIndent = { fg = p.gray1, nocombine = true },
    IblBlank = { fg = p.gray1, nocombine = true },
    IblScope = { fg = p.gray4, nocombine = true },
    IblWhitespace = { fg = p.gray1, nocombine = true },

    ---- mini.nvim --------------------------------------------------

    MiniSurround = { fg = p.bg_dark, bg = p.bright_orange },
    MiniJump = { fg = p.bg_dark, bg = p.bright_orange },
    MiniJump2dSpot = { fg = p.bg_dark, bg = p.bright_orange },
    MiniStarterCurrent = { nocombine = true },
    MiniStarterFooter = { fg = p.fg_muted },
    MiniStarterHeader = { fg = p.orange },
    MiniStarterInactive = { fg = p.fg_subtle },
    MiniStarterItem = { fg = p.fg },
    MiniStarterItemBullet = { fg = p.gray3 },
    MiniStarterItemPrefix = { fg = p.orange },
    MiniStarterSection = { fg = p.coral },
    MiniStarterQuery = { fg = p.green },

    ---- neotest ----------------------------------------------------

    NeotestPassed = { fg = p.green },
    NeotestFailed = { fg = p.red },
    NeotestRunning = { fg = p.orange },
    NeotestSkipped = { fg = p.fg_muted },
    NeotestFocused = { fg = p.orange },
    NeotestMarked = { fg = p.orange },
    NeotestAdapterName = { fg = p.purple },
    NeotestDir = { fg = p.orange },
    NeotestFile = { fg = p.orange },
    NeotestNamespace = { fg = p.coral },
    NeotestIndent = { fg = p.gray3 },
    NeotestExpand = { fg = p.gray3 },
    NeotestWatching = { fg = p.yellow },

    ---- noice.nvim -------------------------------------------------

    NoicePopup = { fg = p.fg, bg = p.bg_light },
    NoicePopupBorder = { fg = p.border, bg = p.bg_light },
    NoiceCmdline = { fg = p.fg },
    NoiceCmdlineIcon = { fg = p.orange },
    NoiceCmdlineIconSearch = { fg = p.orange },
    NoiceCmdlinePrompt = { fg = p.fg },
    NoiceConfirm = { fg = p.fg, bg = p.bg_light },
    NoiceMini = { fg = p.fg, bg = p.bg_dark },

    ---- nvim-dap ---------------------------------------------------

    DapBreakpoint = { fg = p.red },
    DapBreakpointCondition = { fg = p.yellow },
    DapBreakpointRejected = { fg = p.fg_muted },
    DapLogPoint = { fg = p.purple },
    DapStopped = { fg = p.orange, bg = p.bg_visual },
    NvimDapVirtualText = { fg = p.purple, italic = true },

    DapUIBreakpointsCurrentLine = { fg = p.orange },
    DapUIBreakpointsDisabledLine = { fg = p.fg_muted },
    DapUIBreakpointsInfo = { fg = p.purple },
    DapUIBreakpointsLine = { fg = p.purple },
    DapUIBreakpointsPath = { fg = p.orange },
    DapUICurrentFrameName = { fg = p.yellow },
    DapUIDecoration = { fg = p.coral },
    DapUIEndofBuffer = { fg = p.bg },
    DapUIFloatBorder = { fg = p.border },
    DapUILineNumber = { fg = p.orange },
    DapUIModifiedValue = { fg = p.orange },
    DapUIPlayPause = { fg = p.green },
    DapUIPlayPauseNC = { fg = p.green },
    DapUIRestart = { fg = p.green },
    DapUIRestartNC = { fg = p.green },
    DapUIScope = { fg = p.orange },
    DapUISource = { fg = p.purple },
    DapUIStepBack = { fg = p.yellow },
    DapUIStepBackNC = { fg = p.yellow },
    DapUIStepInto = { fg = p.yellow },
    DapUIStepIntoNC = { fg = p.yellow },
    DapUIStepOut = { fg = p.yellow },
    DapUIStepOutNC = { fg = p.yellow },
    DapUIStepOver = { fg = p.yellow },
    DapUIStepOverNC = { fg = p.yellow },
    DapUIStop = { fg = p.red },
    DapUIStopNC = { fg = p.red },
    DapUIStoppedThread = { fg = p.orange },
    DapUIThread = { fg = p.green },
    DapUIType = { fg = p.coral },
    DapUIValue = { fg = p.fg },
    DapUIVariable = { fg = p.fg },
    DapUIWatchesEmpty = { fg = p.red },
    DapUIWatchesError = { fg = p.red },
    DapUIWatchesValue = { fg = p.green },
    DapUIWinSelect = { fg = p.orange },

    ---- todo-comments ----------------------------------------------

    TodoBgFixme = { fg = p.bg_dark, bg = p.red },
    TodoBgTodo = { fg = p.bg_dark, bg = p.yellow },
    TodoBgNote = { fg = p.bg_dark, bg = p.purple },
    TodoBgHack = { fg = p.bg_dark, bg = p.orange },
    TodoBgWarn = { fg = p.bg_dark, bg = p.warn },
    TodoBgPerf = { fg = p.bg_dark, bg = p.coral },
    TodoBgTest = { fg = p.bg_dark, bg = p.pink },

    TodoFgFixme = { fg = p.red },
    TodoFgTodo = { fg = p.yellow },
    TodoFgNote = { fg = p.purple },
    TodoFgHack = { fg = p.orange },
    TodoFgWarn = { fg = p.warn },
    TodoFgPerf = { fg = p.coral },
    TodoFgTest = { fg = p.pink },

    TodoSignFixme = { fg = p.red },
    TodoSignTodo = { fg = p.yellow },
    TodoSignNote = { fg = p.purple },
    TodoSignHack = { fg = p.orange },
    TodoSignWarn = { fg = p.warn },
    TodoSignPerf = { fg = p.coral },
    TodoSignTest = { fg = p.pink },

    ---- trouble.nvim -----------------------------------------------

    TroubleText = { fg = p.fg },
    TroubleSource = { fg = p.fg_muted },
    TroubleFile = { fg = p.orange },
    TroubleLocation = { fg = p.fg_subtle },
    TroubleFoldIcon = { fg = p.fg_muted },
    TroubleCount = { fg = p.purple },
    TroubleNormal = { fg = p.fg, bg = p.bg },
    TroubleIndent = { fg = p.gray2 },

    ---- which-key --------------------------------------------------

    WhichKey = { fg = p.orange },
    WhichKeyDesc = { fg = p.fg },
    WhichKeyGroup = { fg = p.coral },
    WhichKeySeparator = { fg = p.fg_subtle },
    WhichKeyValue = { fg = p.fg_muted },
    WhichKeyIcon = { fg = p.orange },
    WhichKeyNormal = { fg = p.fg, bg = p.bg_light },

    ---- lazy.nvim --------------------------------------------------

    LazyH1 = { fg = p.bg_dark, bg = p.orange, bold = true },
    LazyH2 = { fg = p.orange },
    LazyButton = { fg = p.fg, bg = p.bg_dark },
    LazyButtonActive = { fg = p.fg_bright, bg = p.bg_visual },
    LazyDimmed = { fg = p.fg_muted },
    LazySpecial = { fg = p.orange },
    LazyReasonCmd = { fg = p.orange },
    LazyReasonEvent = { fg = p.purple },
    LazyReasonKeys = { fg = p.coral },
    LazyReasonPlugin = { fg = p.green },
    LazyReasonRequire = { fg = p.pink },
    LazyReasonSource = { fg = p.yellow },
    LazyValue = { fg = p.fg },

    ---- treesitter context -----------------------------------------

    TreesitterContext = { bg = p.bg_dark },
    TreesitterContextLineNumber = { fg = p.fg_muted, bg = p.bg_dark },
    TreesitterContextBottom = { underline = true, sp = p.border },

    ---- snacks.nvim ------------------------------------------------

    SnacksNormal = { fg = p.fg, bg = p.bg },
    SnacksNormalNC = { fg = p.fg_muted, bg = p.bg_nc },
    SnacksWinBar = { fg = p.fg_bright, bg = p.bg_dark, bold = true },
    SnacksWinBarNC = { fg = p.fg_muted, bg = p.bg_dark },
    SnacksTitle = { fg = p.fg_bright, bg = p.bg_light, bold = true },
    SnacksWinSeparator = { fg = p.gray2 },

    SnacksPickerDir = { fg = p.fg_muted },
    SnacksPickerDirectory = { fg = p.orange, bold = true },
    SnacksPickerFile = { fg = p.fg },
    SnacksPickerLink = { fg = p.orange, underline = true },
    SnacksPickerMatch = { fg = p.orange, bold = true },
    SnacksPickerSpecial = { fg = p.orange },
    SnacksPickerPrompt = { fg = p.orange },

    SnacksPickerInput = { fg = p.fg, bg = p.bg_light },
    SnacksPickerList = { fg = p.fg, bg = p.bg },
    SnacksPickerPreview = { fg = p.fg, bg = p.bg },
    SnacksPickerBox = { fg = p.fg, bg = p.bg_light },
  }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Terminal Colors                                          │
-- │ Gruvbox-Material accents for the integrated terminal.    │
-- ╰──────────────────────────────────────────────────────────╯

local terminal_colors = {
  light = {
    [0] = "#f9f5d7", -- bg
    [1] = "#cc241d", -- red
    [2] = "#98971a", -- green
    [3] = "#d79921", -- yellow
    [4] = "#8f3f71", -- ruby
    [5] = "#b16286", -- purple
    [6] = "#c87040", -- coral
    [7] = "#3c3836", -- fg
    [8] = "#928374", -- gray3
    [9] = "#9d0006", -- bright_red
    [10] = "#79740e", -- bright_green
    [11] = "#b57614", -- bright_yellow
    [12] = "#b16286", -- bright_ruby
    [13] = "#8f3f71", -- bright_purple
    [14] = "#af3a03", -- bright_coral
    [15] = "#282828", -- fg_bright
  },
  dark = {
    [0] = "#282828", -- bg (Gruvbox bg0)
    [1] = "#ea6962", -- red
    [2] = "#a9b665", -- green
    [3] = "#d8a657", -- yellow
    [4] = "#7daea3", -- blue
    [5] = "#d3869b", -- magenta
    [6] = "#89b482", -- cyan
    [7] = "#ebdbb2", -- fg
    [8] = "#928374", -- bright black
    [9] = "#f2594a", -- bright red
    [10] = "#bfcf7e", -- bright green
    [11] = "#e8b86a", -- bright yellow
    [12] = "#97c5c0", -- bright blue
    [13] = "#e09eae", -- bright magenta
    [14] = "#9bc892", -- bright cyan
    [15] = "#fbf1c7", -- bright white
  },
}

-- ╭──────────────────────────────────────────────────────────╮
-- │ Load                                                     │
-- ╰──────────────────────────────────────────────────────────╯

M.palette = nil

function M.load()
  vim.api.nvim_command("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.api.nvim_command("syntax reset")
  end

  local mode = vim.o.background -- "light" or "dark"
  local p = palettes[mode] or palettes.dark
  M.palette = p

  for name, opts in pairs(make_groups(p)) do
    vim.api.nvim_set_hl(0, name, opts)
  end

  local tc = terminal_colors[mode] or terminal_colors.dark
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = tc[i]
  end

  vim.g.colors_name = "emberbox"
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Lualine theme                                            │
-- ╰──────────────────────────────────────────────────────────╯

function M.lualine_theme()
  local p = M.palette or palettes.dark
  return {
    normal = {
      a = { fg = p.bg_dark, bg = p.orange, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_dark },
      c = { fg = p.fg, bg = p.bg },
    },
    insert = {
      a = { fg = p.bg_dark, bg = p.green, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_dark },
      c = { fg = p.fg, bg = p.bg },
    },
    visual = {
      a = { fg = p.bg_dark, bg = p.purple, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_dark },
      c = { fg = p.fg, bg = p.bg },
    },
    replace = {
      a = { fg = p.bg_dark, bg = p.red, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_dark },
      c = { fg = p.fg, bg = p.bg },
    },
    command = {
      a = { fg = p.bg_dark, bg = p.yellow, gui = "bold" },
      b = { fg = p.fg, bg = p.bg_dark },
      c = { fg = p.fg, bg = p.bg },
    },
    inactive = {
      a = { fg = p.fg_subtle, bg = p.bg_dark },
      b = { fg = p.fg_subtle, bg = p.bg_dark },
      c = { fg = p.fg_muted, bg = p.bg_dark },
    },
  }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Auto-reload on background switch                         │
-- ╰──────────────────────────────────────────────────────────╯

local group = vim.api.nvim_create_augroup("emberbox", { clear = true })
vim.api.nvim_create_autocmd("OptionSet", {
  group = group,
  pattern = "background",
  callback = function()
    M.load()
  end,
})

return M
