-- EmberBox: A warm, nearly-monochrome theme inspired by ember-theme/nvim.
-- Coral hero accent, gold/olive/sage supporting accents, three variants
-- (dark, soft, light). Architecture: palette → theme → highlights.

local M = {}

-- ╭──────────────────────────────────────────────────────────╮
-- │ Configuration                                          │
-- ╰──────────────────────────────────────────────────────────╯

M.config = {
  variant = "dark",
  styles = {
    comments = { italic = true },
    keywords = { bold = true },
    functions = {},
    types = { bold = true },
  },
  transparent = false,
  on_colors = nil,
  on_highlights = nil,
}

-- ╭──────────────────────────────────────────────────────────╮
-- │ Palettes (ember palette)                               │
-- ╰──────────────────────────────────────────────────────────╯

local palettes = {
  dark = {
    type   = "dark",
    bg     = "#1c1b19",
    bg_alt = "#242320",
    base0  = "#151412",
    base1  = "#1c1b19",
    base2  = "#252422",
    base3  = "#2e2d2a",
    base4  = "#3e3c38",
    base5  = "#585550",
    base6  = "#706c61",
    base7  = "#908a7e",
    base8  = "#b8b0a0",
    fg     = "#d8d0c0",
    fg_alt = "#b0a898",
    coral  = "#e08060",
    orange = "#c09058",
    gold   = "#c8b468",
    olive  = "#8a9868",
    sage   = "#80a090",
    steel  = "#7890a0",
    rose   = "#b07878",
    mauve  = "#988090",
  },
  soft = {
    type   = "dark",
    bg     = "#242320",
    bg_alt = "#2a2927",
    base0  = "#1c1b19",
    base1  = "#222120",
    base2  = "#2c2b28",
    base3  = "#353430",
    base4  = "#444240",
    base5  = "#585550",
    base6  = "#706c61",
    base7  = "#908a7e",
    base8  = "#b8b0a0",
    fg     = "#d8d0c0",
    fg_alt = "#b0a898",
    coral  = "#e08060",
    orange = "#c09058",
    gold   = "#c8b468",
    olive  = "#8a9868",
    sage   = "#80a090",
    steel  = "#7890a0",
    rose   = "#b07878",
    mauve  = "#988090",
  },
  light = {
    type   = "light",
    bg     = "#e6dac4",
    bg_alt = "#ddd0b8",
    base0  = "#f0e8d8",
    base1  = "#e6dac4",
    base2  = "#d8ccb0",
    base3  = "#cec2a8",
    base4  = "#b8ac96",
    base5  = "#989080",
    base6  = "#787060",
    base7  = "#605848",
    base8  = "#484030",
    fg     = "#282418",
    fg_alt = "#585040",
    coral  = "#b84c30",
    orange = "#946030",
    gold   = "#7a6820",
    olive  = "#4a6830",
    sage   = "#386858",
    steel  = "#3a6080",
    rose   = "#905050",
    mauve  = "#706070",
  },
}

-- ╭──────────────────────────────────────────────────────────╮
-- │ Utilities (blend, darken, lighten)                     │
-- ╰──────────────────────────────────────────────────────────╯

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  return r, g, b
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function blend(color1, color2, t)
  local r1, g1, b1 = hex_to_rgb(color1)
  local r2, g2, b2 = hex_to_rgb(color2)
  return rgb_to_hex(
    r1 + (r2 - r1) * t,
    g1 + (g2 - g1) * t,
    b1 + (b2 - b1) * t
  )
end

local function lighten(hex, amount)
  return blend(hex, "#ffffff", amount)
end

local function darken(hex, amount)
  return blend(hex, "#000000", amount)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Semantic Theme Layer                                   │
-- ╰──────────────────────────────────────────────────────────╯

local function build_theme(p)
  return {
    ui = {
      fg = p.fg,
      fg_alt = p.fg_alt,
      bg = p.bg,
      bg_alt = p.bg_alt,
      base0 = p.base0,
      base1 = p.base1,
      base2 = p.base2,
      base3 = p.base3,
      base4 = p.base4,
      base5 = p.base5,
      base6 = p.base6,
      base7 = p.base7,
      base8 = p.base8,
      cursor = p.coral,
      selection = p.base4,
      highlight = p.base4,
      border = p.base4,
      float_bg = p.base0,
      float_border = p.base3,
      pmenu_bg = p.base2,
      pmenu_sel = p.base4,
      pmenu_fg = p.fg,
      statusline_bg = p.base1,
      statusline_fg = p.fg_alt,
      search_bg = p.coral,
      search_fg = p.bg,
      visual = p.base4,
      cursorline = p.bg_alt,
    },
    syn = {
      keyword = p.coral,
      func = p.gold,
      string = p.olive,
      type = p.gold,
      constant = p.orange,
      number = p.orange,
      method = p.sage,
      property = p.fg_alt,
      comment = p.base6,
      doc_comment = p.base7,
      operator = p.base7,
      preproc = p.coral,
      builtin = p.coral,
      variable = p.fg,
      variable_use = p.fg_alt,
      variable_builtin = p.coral,
      coral = p.coral,
      orange = p.orange,
      gold = p.gold,
      olive = p.olive,
      sage = p.sage,
      steel = p.steel,
      rose = p.rose,
      mauve = p.mauve,
    },
    diag = {
      error = p.rose,
      warn = p.gold,
      info = p.steel,
      hint = p.sage,
      error_bg = p.bg,
      warn_bg = p.bg,
      info_bg = p.bg,
      hint_bg = p.bg,
    },
    diff = {
      add = p.olive,
      change = p.gold,
      delete = p.coral,
      add_bg = blend(p.olive, p.bg, 0.10),
      change_bg = blend(p.gold, p.bg, 0.10),
      delete_bg = blend(p.rose, p.bg, 0.10),
      text_bg = blend(p.gold, p.bg, 0.20),
    },
    term = {
      [0] = p.bg,
      [1] = p.rose,
      [2] = p.olive,
      [3] = p.gold,
      [4] = p.steel,
      [5] = p.mauve,
      [6] = p.sage,
      [7] = p.fg,
      [8] = p.base4,
      [9] = p.rose,
      [10] = p.olive,
      [11] = p.gold,
      [12] = p.steel,
      [13] = p.mauve,
      [14] = p.sage,
      [15] = p.fg,
    },
  }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Highlight Groups                                       │
-- ╰──────────────────────────────────────────────────────────╯

local function make_groups(theme)
  local t = theme
  return {
    ---- Editor base ------------------------------------------------

    Normal = { fg = t.ui.fg, bg = t.ui.bg },
    NormalFloat = { fg = t.ui.fg, bg = t.ui.float_bg },
    NormalNC = { fg = t.ui.fg_alt, bg = t.ui.bg },
    FloatBorder = { fg = t.ui.border, bg = t.ui.float_bg },
    FloatTitle = { fg = t.ui.fg, bg = t.ui.float_bg, bold = true },

    Cursor = { fg = t.ui.bg, bg = t.ui.coral },
    CursorLine = { bg = t.ui.cursorline },
    CursorColumn = { bg = t.ui.cursorline },
    CursorLineNr = { fg = t.syn.orange, bold = true },
    CursorLineSign = { bg = t.ui.cursorline },
    CursorLineFold = { bg = t.ui.cursorline },
    ColorColumn = { bg = t.ui.bg_alt },

    LineNr = { fg = t.ui.base3 },
    SignColumn = { bg = t.ui.bg },
    FoldColumn = { fg = t.ui.base5, bg = t.ui.bg },
    Folded = { fg = t.ui.fg_alt, bg = t.ui.bg_alt, italic = true },

    Visual = { bg = t.ui.visual },
    VisualNOS = { bg = t.ui.visual },

    Search = { fg = t.ui.bg, bg = t.ui.search_bg, bold = true },
    IncSearch = { fg = t.ui.bg, bg = t.syn.keyword, bold = true },
    CurSearch = { fg = t.ui.bg, bg = t.syn.keyword, bold = true },
    Substitute = { fg = t.ui.bg, bg = t.syn.mauve },

    StatusLine = { fg = t.ui.fg, bg = t.ui.statusline_bg },
    StatusLineNC = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },

    WinBar = { fg = t.ui.fg, bg = t.ui.statusline_bg, bold = true },
    WinBarNC = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    WinSeparator = { fg = t.ui.base3 },

    TabLine = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    TabLineFill = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    TabLineSel = { fg = t.ui.fg, bg = t.ui.bg, bold = true },

    EndOfBuffer = { fg = t.ui.bg },
    NonText = { fg = t.ui.base3 },
    Whitespace = { fg = t.ui.base1 },
    SpecialKey = { fg = t.ui.base3 },

    Pmenu = { fg = t.ui.fg, bg = t.ui.pmenu_bg },
    PmenuSel = { fg = t.ui.fg, bg = t.ui.pmenu_sel, bold = true },
    PmenuSbar = { bg = t.ui.base1 },
    PmenuThumb = { bg = t.ui.base3 },
    WildMenu = { fg = t.ui.fg, bg = t.ui.visual },

    QuickFixLine = { bg = t.ui.visual },
    MatchParen = { fg = t.syn.orange, bg = t.ui.visual, bold = true },

    ModeMsg = { fg = t.ui.fg_alt },
    MoreMsg = { fg = t.syn.orange },
    Question = { fg = t.syn.coral },
    MsgArea = { fg = t.ui.fg },
    MsgSeparator = { fg = t.ui.base3 },

    Directory = { fg = t.syn.orange, bold = true },
    Title = { fg = t.syn.orange, bold = true },
    Bold = { bold = true },
    Italic = { italic = true },

    Conceal = { fg = t.ui.base5 },
    SpellBad = { undercurl = true, sp = t.syn.coral },
    SpellCap = { undercurl = true, sp = t.syn.steel },
    SpellLocal = { undercurl = true, sp = t.syn.steel },
    SpellRare = { undercurl = true, sp = t.syn.mauve },

    ---- Syntax -----------------------------------------------------

    Comment = { fg = t.syn.comment, italic = true },
    Todo = { fg = t.ui.bg, bg = t.syn.gold, bold = true, italic = true },
    Error = { fg = t.diag.error },
    ErrorMsg = { fg = t.diag.error },
    WarningMsg = { fg = t.diag.warn },

    String = { fg = t.syn.string },
    Character = { fg = t.syn.string },
    Number = { fg = t.syn.constant },
    Boolean = { fg = t.syn.constant, bold = true },
    Float = { fg = t.syn.constant },
    Constant = { fg = t.syn.constant, bold = true },

    Identifier = { fg = t.ui.fg },
    Function = { fg = t.syn.func },

    Statement = { fg = t.syn.keyword },
    Conditional = { fg = t.syn.keyword },
    Repeat = { fg = t.syn.keyword },
    Label = { fg = t.syn.orange },
    Operator = { fg = t.syn.operator },
    Keyword = { fg = t.syn.keyword, bold = true },
    Exception = { fg = t.syn.keyword },

    PreProc = { fg = t.syn.preproc },
    Include = { fg = t.syn.preproc },
    Define = { fg = t.syn.preproc },
    Macro = { fg = t.syn.coral },
    PreCondit = { fg = t.syn.preproc },

    Type = { fg = t.syn.type },
    StorageClass = { fg = t.syn.orange },
    Structure = { fg = t.syn.type },
    Typedef = { fg = t.syn.type },

    Special = { fg = t.syn.orange },
    SpecialChar = { fg = t.syn.orange },
    Tag = { fg = t.syn.orange },
    Delimiter = { fg = t.syn.coral },
    SpecialComment = { fg = t.syn.comment, italic = true },
    Debug = { fg = t.syn.orange },

    Underlined = { fg = t.syn.orange, underline = true },
    Ignore = { fg = t.ui.base5 },

    ---- Tree-sitter ------------------------------------------------

    ["@variable"] = { fg = t.syn.variable_use },
    ["@variable.builtin"] = { fg = t.syn.variable_builtin, italic = true },
    ["@variable.parameter"] = { fg = t.ui.fg_alt, italic = true },
    ["@variable.member"] = { fg = t.ui.fg_alt },
    ["@constant"] = { fg = t.syn.constant },
    ["@constant.builtin"] = { fg = t.syn.constant, bold = true },
    ["@constant.macro"] = { fg = t.syn.coral },

    ["@module"] = { fg = t.syn.variable_use },
    ["@namespace"] = { fg = t.syn.variable_use },
    ["@label"] = { fg = t.syn.orange },

    ["@string"] = { fg = t.syn.string },
    ["@string.regexp"] = { fg = t.syn.constant },
    ["@string.escape"] = { fg = t.syn.constant },
    ["@string.special"] = { fg = t.syn.orange },
    ["@string.delimiter"] = { fg = t.ui.fg_alt },

    ["@character"] = { fg = t.syn.string },
    ["@character.special"] = { fg = t.syn.orange },
    ["@boolean"] = { fg = t.syn.constant, bold = true },
    ["@number"] = { fg = t.syn.constant },
    ["@float"] = { fg = t.syn.constant },

    ["@function"] = { fg = t.syn.func },
    ["@function.call"] = { fg = t.syn.func },
    ["@function.builtin"] = { fg = t.syn.builtin },
    ["@function.macro"] = { fg = t.syn.coral },
    ["@method"] = { fg = t.syn.method },
    ["@method.call"] = { fg = t.syn.method },
    ["@constructor"] = { fg = t.syn.func },
    ["@parameter"] = { fg = t.ui.fg_alt, italic = true },

    ["@property"] = { fg = t.syn.property },
    ["@field"] = { fg = t.syn.property },

    ["@type"] = { fg = t.syn.type },
    ["@type.builtin"] = { fg = t.syn.type, italic = true },
    ["@type.definition"] = { fg = t.syn.type },
    ["@type.qualifier"] = { fg = t.syn.keyword },
    ["@class"] = { fg = t.syn.type },
    ["@enum"] = { fg = t.syn.type },
    ["@interface"] = { fg = t.syn.type },
    ["@struct"] = { fg = t.syn.type },
    ["@union"] = { fg = t.syn.type },

    ["@attribute"] = { fg = t.syn.coral },
    ["@annotation"] = { fg = t.syn.coral, italic = true },

    ["@keyword"] = { fg = t.syn.keyword, bold = true },
    ["@keyword.function"] = { fg = t.syn.keyword, bold = true },
    ["@keyword.operator"] = { fg = t.syn.keyword },
    ["@keyword.return"] = { fg = t.syn.keyword, bold = true },
    ["@keyword.debug"] = { fg = t.syn.orange },
    ["@keyword.exception"] = { fg = t.syn.keyword },
    ["@keyword.conditional"] = { fg = t.syn.keyword, bold = true },
    ["@keyword.repeat"] = { fg = t.syn.keyword, bold = true },
    ["@keyword.import"] = { fg = t.syn.keyword },
    ["@keyword.storage"] = { fg = t.syn.orange },
    ["@keyword.coroutine"] = { fg = t.syn.keyword },
    ["@keyword.directive"] = { fg = t.syn.coral },

    ["@conditional"] = { link = "@keyword.conditional" },
    ["@repeat"] = { link = "@keyword.repeat" },
    ["@for"] = { link = "@keyword.repeat" },
    ["@while"] = { link = "@keyword.repeat" },

    ["@operator"] = { fg = t.syn.operator },

    ["@comment"] = { fg = t.syn.comment, italic = true },
    ["@comment.documentation"] = { fg = t.syn.doc_comment, italic = true },
    ["@comment.todo"] = { fg = t.ui.bg, bg = t.syn.gold, bold = true },
    ["@comment.error"] = { fg = t.diag.error },
    ["@comment.warning"] = { fg = t.diag.warn },
    ["@comment.note"] = { fg = t.syn.steel },

    ["@punctuation"] = { fg = t.syn.coral },
    ["@punctuation.bracket"] = { fg = t.syn.coral },
    ["@punctuation.delimiter"] = { fg = t.syn.coral },
    ["@punctuation.special"] = { fg = t.syn.coral },

    ["@tag"] = { fg = t.syn.keyword },
    ["@tag.attribute"] = { fg = t.syn.orange },
    ["@tag.delimiter"] = { fg = t.ui.fg_alt },

    ["@text"] = { fg = t.ui.fg },
    ["@text.literal"] = { fg = t.syn.string },
    ["@text.reference"] = { fg = t.syn.orange },
    ["@text.emphasis"] = { italic = true },
    ["@text.strong"] = { bold = true },
    ["@text.title"] = { fg = t.syn.orange, bold = true },
    ["@text.uri"] = { fg = t.syn.orange, underline = true },
    ["@text.math"] = { fg = t.syn.constant },
    ["@text.note"] = { fg = t.syn.steel },
    ["@text.danger"] = { fg = t.diag.error },
    ["@text.warning"] = { fg = t.diag.warn },
    ["@text.diff.add"] = { fg = t.diff.add },
    ["@text.diff.delete"] = { fg = t.diff.delete },

    ["@diff.plus"] = { fg = t.diff.add },
    ["@diff.minus"] = { fg = t.diff.delete },
    ["@diff.delta"] = { fg = t.diff.change },

    ---- Heading hierarchy ------------------------------------------

    ["@markup.heading.1"] = { fg = t.syn.coral, bold = true },
    ["@markup.heading.2"] = { fg = t.syn.orange, bold = true },
    ["@markup.heading.3"] = { fg = t.syn.gold, bold = true },
    ["@markup.heading.4"] = { fg = t.syn.olive, bold = true },
    ["@markup.heading.5"] = { fg = t.syn.steel, bold = true },
    ["@markup.heading.6"] = { fg = t.syn.base7, bold = true },

    ["@define"] = { fg = t.syn.coral },
    ["@macro"] = { fg = t.syn.coral },
    ["@include"] = { fg = t.syn.coral },
    ["@preproc"] = { fg = t.syn.coral },
    ["@exception"] = { fg = t.syn.keyword },
    ["@error"] = { fg = t.diag.error },

    ---- LSP semantic tokens ----------------------------------------

    ["@lsp.type.class"] = { link = "@class" },
    ["@lsp.type.enum"] = { link = "@enum" },
    ["@lsp.type.interface"] = { link = "@interface" },
    ["@lsp.type.struct"] = { link = "@struct" },
    ["@lsp.type.typeParameter"] = { fg = t.syn.type },
    ["@lsp.type.decorator"] = { fg = t.syn.func },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.macro"] = { fg = t.syn.coral },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.method"] = { link = "@method" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.variable"] = { link = "@variable" },

    ---- Diagnostics ------------------------------------------------

    DiagnosticError = { fg = t.diag.error },
    DiagnosticWarn = { fg = t.diag.warn },
    DiagnosticInfo = { fg = t.diag.info },
    DiagnosticHint = { fg = t.diag.hint },
    DiagnosticOk = { fg = t.syn.olive },

    DiagnosticSignError = { fg = t.diag.error },
    DiagnosticSignWarn = { fg = t.diag.warn },
    DiagnosticSignInfo = { fg = t.diag.info },
    DiagnosticSignHint = { fg = t.diag.hint },

    DiagnosticVirtualTextError = { fg = t.diag.error, bg = t.diag.error_bg },
    DiagnosticVirtualTextWarn = { fg = t.diag.warn, bg = t.diag.warn_bg },
    DiagnosticVirtualTextInfo = { fg = t.diag.info, bg = t.diag.info_bg },
    DiagnosticVirtualTextHint = { fg = t.diag.hint, bg = t.diag.hint_bg },

    DiagnosticUnderlineError = { undercurl = true, sp = t.diag.error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = t.diag.warn },
    DiagnosticUnderlineInfo = { undercurl = true, sp = t.diag.info },
    DiagnosticUnderlineHint = { undercurl = true, sp = t.diag.hint },

    ---- LSP --------------------------------------------------------

    LspReferenceText = { bg = t.ui.visual },
    LspReferenceRead = { bg = t.ui.visual },
    LspReferenceWrite = { bg = t.ui.visual, underline = true },
    LspCodeLens = { fg = t.ui.base5, italic = true },
    LspCodeLensSeparator = { fg = t.ui.base3 },
    LspInlayHint = { fg = t.ui.base5, bg = t.ui.cursorline, italic = true },
    LspSignatureActiveParameter = { fg = t.syn.orange },

    ---- Git / Diff -------------------------------------------------

    diffAdded = { fg = t.diff.add },
    diffChanged = { fg = t.diff.change },
    diffRemoved = { fg = t.diff.delete },
    diffFile = { fg = t.syn.orange },
    diffNewFile = { fg = t.diff.add },
    diffLine = { fg = t.ui.base5 },
    diffIndexLine = { fg = t.ui.fg_alt },

    ---- blink.cmp --------------------------------------------------

    BlinkCmpDoc = { fg = t.ui.fg, bg = t.ui.float_bg },
    BlinkCmpDocBorder = { fg = t.ui.border, bg = t.ui.float_bg },
    BlinkCmpDocCursorLine = { bg = t.ui.visual },
    BlinkCmpGhostText = { fg = t.ui.base3 },
    BlinkCmpKind = { fg = t.syn.gold },
    BlinkCmpKindText = { fg = t.syn.olive },
    BlinkCmpKindMethod = { fg = t.syn.method },
    BlinkCmpKindFunction = { fg = t.syn.func },
    BlinkCmpKindConstructor = { fg = t.syn.func },
    BlinkCmpKindField = { fg = t.syn.property },
    BlinkCmpKindVariable = { fg = t.syn.variable_use },
    BlinkCmpKindClass = { fg = t.syn.type },
    BlinkCmpKindInterface = { fg = t.syn.type },
    BlinkCmpKindModule = { fg = t.syn.type },
    BlinkCmpKindProperty = { fg = t.syn.property },
    BlinkCmpKindUnit = { fg = t.syn.constant },
    BlinkCmpKindValue = { fg = t.syn.constant },
    BlinkCmpKindEnum = { fg = t.syn.type },
    BlinkCmpKindKeyword = { fg = t.syn.coral },
    BlinkCmpKindSnippet = { fg = t.syn.mauve },
    BlinkCmpKindColor = { fg = t.syn.coral },
    BlinkCmpKindFile = { fg = t.syn.coral },
    BlinkCmpKindReference = { fg = t.syn.coral },
    BlinkCmpKindFolder = { fg = t.syn.coral },
    BlinkCmpKindEnumMember = { fg = t.syn.constant },
    BlinkCmpKindConstant = { fg = t.syn.constant },
    BlinkCmpKindStruct = { fg = t.syn.type },
    BlinkCmpKindEvent = { fg = t.syn.coral },
    BlinkCmpKindOperator = { fg = t.syn.operator },
    BlinkCmpKindTypeParameter = { fg = t.syn.type },

    ---- bufferline -------------------------------------------------

    BufferLineFill = { bg = t.ui.statusline_bg },
    BufferLineBackground = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    BufferLineBuffer = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    BufferLineBufferSelected = { fg = t.ui.fg, bg = t.ui.bg },
    BufferLineBufferVisible = { fg = t.ui.fg, bg = t.ui.bg },
    BufferLineSeparator = { fg = t.ui.base3, bg = t.ui.statusline_bg },
    BufferLineSeparatorSelected = { fg = t.ui.base3, bg = t.ui.bg },
    BufferLineIndicatorSelected = { fg = t.syn.orange, bg = t.ui.bg },
    BufferLineCloseButton = { fg = t.ui.base5, bg = t.ui.statusline_bg },
    BufferLineCloseButtonSelected = { fg = t.syn.coral, bg = t.ui.bg },
    BufferLineModified = { fg = t.diff.change, bg = t.ui.statusline_bg },
    BufferLineModifiedSelected = { fg = t.diff.change, bg = t.ui.bg },
    BufferLineTab = { fg = t.syn.orange, bg = t.ui.statusline_bg },
    BufferLineTabSelected = { fg = t.syn.orange, bg = t.ui.bg },
    BufferLineTabClose = { fg = t.syn.coral, bg = t.ui.statusline_bg },
    BufferLineDuplicate = { fg = t.ui.base5, bg = t.ui.statusline_bg },
    BufferLineDuplicateSelected = { fg = t.ui.fg, bg = t.ui.bg },

    ---- flash.nvim -------------------------------------------------

    FlashBackdrop = { fg = t.ui.base5 },
    FlashLabel = { fg = t.ui.bg, bg = t.syn.orange },
    FlashMatch = { fg = t.syn.mauve, bg = t.ui.visual },
    FlashCurrent = { fg = t.syn.orange, bg = t.ui.visual },
    FlashCursor = { fg = t.ui.bg, bg = t.syn.orange },
    FlashPrompt = { fg = t.ui.fg },

    ---- gitsigns ---------------------------------------------------

    GitSignsAdd = { fg = t.diff.add },
    GitSignsChange = { fg = t.diff.change },
    GitSignsDelete = { fg = t.diff.delete },
    GitSignsAddNr = { fg = t.diff.add, bold = true },
    GitSignsChangeNr = { fg = t.diff.change, bold = true },
    GitSignsDeleteNr = { fg = t.diff.delete, bold = true },
    GitSignsAddLn = { fg = t.diff.add, bg = t.diff.add_bg },
    GitSignsChangeLn = { fg = t.diff.change, bg = t.diff.change_bg },
    GitSignsDeleteLn = { fg = t.diff.delete, bg = t.diff.delete_bg },
    GitSignsAddCul = { fg = t.diff.add, bg = t.ui.cursorline },
    GitSignsChangeCul = { fg = t.diff.change, bg = t.ui.cursorline },
    GitSignsDeleteCul = { fg = t.diff.delete, bg = t.ui.cursorline },
    GitSignsStagedAdd = { fg = t.ui.base4 },
    GitSignsStagedChange = { fg = t.ui.base4 },
    GitSignsStagedDelete = { fg = t.ui.base4 },
    GitSignsCurrentLineBlame = { fg = t.ui.base5, italic = true },

    ---- indent-blankline -------------------------------------------

    IblIndent = { fg = t.ui.base3, nocombine = true },
    IblBlank = { fg = t.ui.base3, nocombine = true },
    IblScope = { fg = t.ui.base5, nocombine = true },
    IblWhitespace = { fg = t.ui.base3, nocombine = true },
    IndentBlanklineChar = { fg = t.ui.base3, nocombine = true },
    IndentBlanklineContextChar = { fg = t.ui.base5, nocombine = true },

    ---- mini.nvim --------------------------------------------------

    MiniSurround = { fg = t.ui.bg, bg = t.syn.orange },
    MiniJump = { fg = t.ui.bg, bg = t.syn.orange },
    MiniJump2dSpot = { fg = t.ui.bg, bg = t.syn.orange },
    MiniStarterCurrent = { nocombine = true },
    MiniStarterFooter = { fg = t.ui.fg_alt },
    MiniStarterHeader = { fg = t.syn.orange },
    MiniStarterInactive = { fg = t.ui.base5 },
    MiniStarterItem = { fg = t.ui.fg },
    MiniStarterItemBullet = { fg = t.ui.base3 },
    MiniStarterItemPrefix = { fg = t.syn.orange },
    MiniStarterSection = { fg = t.syn.coral },
    MiniStarterQuery = { fg = t.syn.olive },

    ---- neotest ----------------------------------------------------

    NeotestPassed = { fg = t.syn.olive },
    NeotestFailed = { fg = t.syn.coral },
    NeotestRunning = { fg = t.syn.orange },
    NeotestSkipped = { fg = t.ui.fg_alt },
    NeotestFocused = { fg = t.syn.orange },
    NeotestMarked = { fg = t.syn.orange },
    NeotestAdapterName = { fg = t.syn.mauve },
    NeotestDir = { fg = t.syn.orange },
    NeotestFile = { fg = t.syn.orange },
    NeotestNamespace = { fg = t.syn.coral },
    NeotestIndent = { fg = t.ui.base3 },
    NeotestExpand = { fg = t.ui.base3 },
    NeotestWatching = { fg = t.syn.func },

    ---- noice.nvim -------------------------------------------------

    NoicePopup = { fg = t.ui.fg, bg = t.ui.float_bg },
    NoicePopupBorder = { fg = t.ui.border, bg = t.ui.float_bg },
    NoiceCmdline = { fg = t.ui.fg },
    NoiceCmdlineIcon = { fg = t.syn.orange },
    NoiceCmdlineIconSearch = { fg = t.syn.orange },
    NoiceCmdlinePrompt = { fg = t.ui.fg },
    NoiceConfirm = { fg = t.ui.fg, bg = t.ui.float_bg },
    NoiceMini = { fg = t.ui.fg, bg = t.ui.statusline_bg },
    NoiceCmdlineProgressSpinner = { fg = t.syn.coral },

    ---- nvim-dap ---------------------------------------------------

    DapBreakpoint = { fg = t.syn.coral },
    DapBreakpointCondition = { fg = t.syn.func },
    DapBreakpointRejected = { fg = t.ui.fg_alt },
    DapLogPoint = { fg = t.syn.mauve },
    DapStopped = { fg = t.syn.orange, bg = t.ui.visual },
    NvimDapVirtualText = { fg = t.syn.mauve, italic = true },

    DapUIBreakpointsCurrentLine = { fg = t.syn.orange },
    DapUIBreakpointsDisabledLine = { fg = t.ui.fg_alt },
    DapUIBreakpointsInfo = { fg = t.syn.mauve },
    DapUIBreakpointsLine = { fg = t.syn.mauve },
    DapUIBreakpointsPath = { fg = t.syn.orange },
    DapUICurrentFrameName = { fg = t.syn.func },
    DapUIDecoration = { fg = t.syn.coral },
    DapUIEndofBuffer = { fg = t.ui.bg },
    DapUIFloatBorder = { fg = t.ui.border },
    DapUILineNumber = { fg = t.syn.orange },
    DapUIModifiedValue = { fg = t.syn.orange },
    DapUIPlayPause = { fg = t.syn.olive },
    DapUIPlayPauseNC = { fg = t.syn.olive },
    DapUIRestart = { fg = t.syn.olive },
    DapUIRestartNC = { fg = t.syn.olive },
    DapUIScope = { fg = t.syn.orange },
    DapUISource = { fg = t.syn.mauve },
    DapUIStepBack = { fg = t.syn.olive },
    DapUIStepBackNC = { fg = t.syn.olive },
    DapUIStepInto = { fg = t.syn.olive },
    DapUIStepIntoNC = { fg = t.syn.olive },
    DapUIStepOut = { fg = t.syn.olive },
    DapUIStepOutNC = { fg = t.syn.olive },
    DapUIStepOver = { fg = t.syn.olive },
    DapUIStepOverNC = { fg = t.syn.olive },
    DapUIStop = { fg = t.syn.rose },
    DapUIStopNC = { fg = t.syn.rose },
    DapUIStoppedThread = { fg = t.syn.orange },
    DapUIThread = { fg = t.diff.add },
    DapUIType = { fg = t.syn.coral },
    DapUIValue = { fg = t.ui.fg },
    DapUIVariable = { fg = t.ui.fg },
    DapUIWatchesEmpty = { fg = t.syn.coral },
    DapUIWatchesError = { fg = t.syn.coral },
    DapUIWatchesValue = { fg = t.syn.olive },
    DapUIWinSelect = { fg = t.syn.orange },

    ---- todo-comments ----------------------------------------------

    TodoBgFixme = { fg = t.ui.bg, bg = t.syn.coral },
    TodoBgTodo = { fg = t.ui.bg, bg = t.syn.gold },
    TodoBgNote = { fg = t.ui.bg, bg = t.syn.mauve },
    TodoBgHack = { fg = t.ui.bg, bg = t.syn.orange },
    TodoBgWarn = { fg = t.ui.bg, bg = t.diag.warn },
    TodoBgPerf = { fg = t.ui.bg, bg = t.syn.coral },
    TodoBgTest = { fg = t.ui.bg, bg = t.syn.mauve },

    TodoFgFixme = { fg = t.syn.coral },
    TodoFgTodo = { fg = t.syn.gold },
    TodoFgNote = { fg = t.syn.mauve },
    TodoFgHack = { fg = t.syn.orange },
    TodoFgWarn = { fg = t.diag.warn },
    TodoFgPerf = { fg = t.syn.coral },
    TodoFgTest = { fg = t.syn.mauve },

    TodoSignFixme = { fg = t.syn.coral },
    TodoSignTodo = { fg = t.syn.gold },
    TodoSignNote = { fg = t.syn.mauve },
    TodoSignHack = { fg = t.syn.orange },
    TodoSignWarn = { fg = t.diag.warn },
    TodoSignPerf = { fg = t.syn.coral },
    TodoSignTest = { fg = t.syn.mauve },

    ---- trouble.nvim -----------------------------------------------

    TroubleText = { fg = t.ui.fg },
    TroubleSource = { fg = t.ui.fg_alt },
    TroubleFile = { fg = t.syn.orange },
    TroubleLocation = { fg = t.ui.base5 },
    TroubleFoldIcon = { fg = t.ui.fg_alt },
    TroubleCount = { fg = t.syn.mauve },
    TroubleNormal = { fg = t.ui.fg, bg = t.ui.bg },
    TroubleIndent = { fg = t.ui.base3 },

    ---- which-key --------------------------------------------------

    WhichKey = { fg = t.syn.orange },
    WhichKeyDesc = { fg = t.ui.fg },
    WhichKeyGroup = { fg = t.syn.gold },
    WhichKeySeparator = { fg = t.ui.base5 },
    WhichKeyValue = { fg = t.ui.fg_alt },
    WhichKeyIcon = { fg = t.syn.orange },
    WhichKeyNormal = { fg = t.ui.fg, bg = t.ui.float_bg },
    WhichKeyFloat = { fg = t.ui.fg, bg = t.ui.float_bg },
    WhichKeyBorder = { fg = t.ui.border, bg = t.ui.float_bg },

    ---- lazy.nvim --------------------------------------------------

    LazyH1 = { fg = t.ui.bg, bg = t.syn.orange, bold = true },
    LazyH2 = { fg = t.syn.orange },
    LazyButton = { fg = t.ui.fg, bg = t.ui.statusline_bg },
    LazyButtonActive = { fg = t.ui.fg, bg = t.ui.visual },
    LazyDimmed = { fg = t.ui.fg_alt },
    LazySpecial = { fg = t.syn.orange },
    LazyReasonCmd = { fg = t.syn.orange },
    LazyReasonEvent = { fg = t.syn.mauve },
    LazyReasonKeys = { fg = t.syn.coral },
    LazyReasonPlugin = { fg = t.syn.olive },
    LazyReasonRequire = { fg = t.syn.coral },
    LazyReasonSource = { fg = t.syn.func },
    LazyValue = { fg = t.ui.fg },
    LazyComment = { fg = t.syn.comment, italic = true },
    LazyCommit = { fg = t.ui.fg },
    LazyCommitType = { fg = t.syn.coral, bold = true },
    LazyProp = { fg = t.syn.property },
    LazyUrl = { fg = t.syn.steel, underline = true },
    LazyLocal = { fg = t.syn.olive },
    LazyProgressDone = { fg = t.syn.olive },
    LazyProgressTodo = { fg = t.ui.base3 },

    ---- treesitter context -----------------------------------------

    TreesitterContext = { bg = t.ui.statusline_bg },
    TreesitterContextLineNumber = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    TreesitterContextBottom = { underline = true, sp = t.ui.border },

    ---- snacks.nvim ------------------------------------------------

    SnacksNormal = { fg = t.ui.fg, bg = t.ui.bg },
    SnacksNormalNC = { fg = t.ui.fg_alt, bg = t.ui.bg },
    SnacksWinBar = { fg = t.ui.fg, bg = t.ui.statusline_bg, bold = true },
    SnacksWinBarNC = { fg = t.ui.fg_alt, bg = t.ui.statusline_bg },
    SnacksTitle = { fg = t.ui.fg, bg = t.ui.float_bg, bold = true },
    SnacksWinSeparator = { fg = t.ui.base3 },

    SnacksPickerDir = { fg = t.ui.fg_alt },
    SnacksPickerDirectory = { fg = t.syn.orange, bold = true },
    SnacksPickerFile = { fg = t.ui.fg },
    SnacksPickerLink = { fg = t.syn.orange, underline = true },
    SnacksPickerMatch = { fg = t.syn.orange, bold = true },
    SnacksPickerSpecial = { fg = t.syn.orange },
    SnacksPickerPrompt = { fg = t.syn.orange },
    SnacksPickerInput = { fg = t.ui.fg, bg = t.ui.float_bg },
    SnacksPickerList = { fg = t.ui.fg, bg = t.ui.bg },
    SnacksPickerPreview = { fg = t.ui.fg, bg = t.ui.bg },
    SnacksPickerBox = { fg = t.ui.fg, bg = t.ui.float_bg },
    SnacksPickerInputSearch = { fg = t.syn.coral },
    SnacksPickerSelected = { fg = t.ui.fg, bg = t.ui.visual },
    SnacksPickerUnselected = { fg = t.ui.fg_alt },
    SnacksPickerPathIgnored = { fg = t.ui.base5, italic = true },
    SnacksPickerPathHidden = { fg = t.ui.base5, italic = true },
    SnacksPickerIcon = { fg = t.syn.orange },
    SnacksPickerBold = { bold = true },
    SnacksPickerCode = { fg = t.syn.func },
    SnacksPickerItalic = { italic = true },
    SnacksPickerDelim = { fg = t.ui.base5 },
    SnacksPickerComment = { fg = t.syn.comment, italic = true },
    SnacksPickerDesc = { fg = t.ui.fg_alt },
    SnacksPickerLabel = { fg = t.syn.coral, bold = true },
    SnacksPickerLinkBroken = { fg = t.diag.error },
    SnacksPickerRule = { fg = t.ui.base3 },
    SnacksPickerDimmed = { fg = t.ui.base5 },
    SnacksPickerSpinner = { fg = t.syn.coral },
    SnacksPickerRow = { fg = t.ui.fg },
    SnacksPickerCol = { fg = t.ui.fg },
    SnacksPickerIdx = { fg = t.syn.mauve },
    SnacksPickerTree = { fg = t.syn.olive },
    SnacksPickerTime = { fg = t.syn.gold },
    SnacksPickerGit = { fg = t.syn.olive },
    SnacksPickerGitStatus = { fg = t.diff.change },
    SnacksPickerGitStatusAdded = { fg = t.diff.add },
    SnacksPickerGitStatusRemoved = { fg = t.diff.delete },
    SnacksPickerGitStatusModified = { fg = t.diff.change },
  }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Terminal Colors                                          │
-- ╰──────────────────────────────────────────────────────────╯

local function build_terminal_colors(p)
  return {
    [0] = p.bg,
    [1] = p.rose,
    [2] = p.olive,
    [3] = p.gold,
    [4] = p.steel,
    [5] = p.mauve,
    [6] = p.sage,
    [7] = p.fg,
    [8] = p.base4,
    [9] = p.rose,
    [10] = p.olive,
    [11] = p.gold,
    [12] = p.steel,
    [13] = p.mauve,
    [14] = p.sage,
    [15] = p.fg,
  }
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Load                                                     │
-- ╰──────────────────────────────────────────────────────────╯

M.palette = nil
M.theme = nil

function M.setup(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    if k == "styles" and type(v) == "table" then
      for sk, sv in pairs(v) do
        M.config.styles[sk] = sv
      end
    else
      M.config[k] = v
    end
  end
end

function M.load()
  vim.api.nvim_command("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.api.nvim_command("syntax reset")
  end

  local variant = M.config.variant
  local p = palettes[variant] or palettes.dark

  -- Call on_colors hook
  if M.config.on_colors then
    M.config.on_colors(p)
  end

  M.palette = p
  local theme = build_theme(p)
  M.theme = theme

  -- Collect highlights
  local highlights = make_groups(theme)

  -- Call on_highlights hook
  if M.config.on_highlights then
    M.config.on_highlights(highlights, theme)
  end

  -- Apply highlights
  for name, opts in pairs(highlights) do
    if not M.config.transparent or name ~= "Normal" then
      vim.api.nvim_set_hl(0, name, opts)
    else
      -- Transparent mode: remove background from Normal
      local o = vim.deepcopy(opts)
      o.bg = nil
      vim.api.nvim_set_hl(0, name, o)
    end
  end

  -- Apply terminal colors
  local tc = build_terminal_colors(p)
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = tc[i]
  end

  vim.g.colors_name = "emberbox"
end

-- ╭──────────────────────────────────────────────────────────╮
-- │ Lualine theme                                            │
-- ╰──────────────────────────────────────────────────────────╯

function M.lualine_theme()
  local t = M.theme or build_theme(palettes[M.config.variant] or palettes.dark)
  return {
    normal = {
      a = { fg = t.ui.bg, bg = t.syn.coral, gui = "bold" },
      b = { fg = t.ui.fg, bg = t.ui.statusline_bg },
      c = { fg = t.ui.fg, bg = t.ui.bg },
    },
    insert = {
      a = { fg = t.ui.bg, bg = t.syn.olive, gui = "bold" },
      b = { fg = t.ui.fg, bg = t.ui.statusline_bg },
      c = { fg = t.ui.fg, bg = t.ui.bg },
    },
    visual = {
      a = { fg = t.ui.bg, bg = t.syn.mauve, gui = "bold" },
      b = { fg = t.ui.fg, bg = t.ui.statusline_bg },
      c = { fg = t.ui.fg, bg = t.ui.bg },
    },
    replace = {
      a = { fg = t.ui.bg, bg = t.syn.rose, gui = "bold" },
      b = { fg = t.ui.fg, bg = t.ui.statusline_bg },
      c = { fg = t.ui.fg, bg = t.ui.bg },
    },
    command = {
      a = { fg = t.ui.bg, bg = t.syn.gold, gui = "bold" },
      b = { fg = t.ui.fg, bg = t.ui.statusline_bg },
      c = { fg = t.ui.fg, bg = t.ui.bg },
    },
    inactive = {
      a = { fg = t.ui.fg_alt, bg = t.ui.bg_alt },
      b = { fg = t.ui.fg_alt, bg = t.ui.bg_alt },
      c = { fg = t.ui.fg_alt, bg = t.ui.bg_alt },
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
    -- Map background to variant
    if vim.o.background == "light" then
      M.config.variant = "light"
    else
      M.config.variant = "dark"
    end
    M.load()
  end,
})

return M
