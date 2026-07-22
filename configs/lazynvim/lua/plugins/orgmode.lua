-- Org-mode, configured for a LogSeq-shaped workflow:
--   * journal.org  - one datetree page per day (like LogSeq's daily journal)
--   * notes.org    - permanent facts/learnings, tagged, looked up via agenda tag search
--   * inbox.org    - quick-capture landing zone for anything you haven't filed yet
--
-- Everything under ~/org is picked up by org_agenda_files, so <leader>oa (agenda),
-- and its "m" (match tags) / "t" (todo list) / "s" (search) sub-views search across
-- all three files at once - that's your LogSeq-style "lookup by tag" and "all todos".
return {
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      "nvim-orgmode/org-bullets.nvim",
    },
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("orgmode").setup({
        org_agenda_files = "~/org/**/*",
        org_default_notes_file = "~/org/inbox.org",

        -- LogSeq-flavored TODO cycle: TODO -> DOING -> WAITING -> DONE/CANCELLED
        -- Fast-access shortcuts must be case-insensitively unique (t/i/w/d/c) -
        -- orgmode lowercases the keypress before matching, so DOING(d)/DONE(D) would collide.
        org_todo_keywords = { "TODO(t)", "DOING(i)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
        org_todo_keyword_faces = {
          DOING = ":foreground #7aa2f7 :weight bold",
          WAITING = ":foreground #e0af68 :weight bold",
          CANCELLED = ":foreground #565f89 :slant italic",
        },

        -- Bullet-outliner feel: conceal the leading `*`/`**` stars and the
        -- *bold*/_italic_ markup markers instead of showing raw org syntax.
        org_hide_leading_stars = true,
        org_hide_emphasis_markers = true,
        org_startup_folded = "inherit",

        org_capture_templates = {
          j = {
            description = "Journal entry (today's page)",
            template = "* %U %?",
            target = "~/org/journal.org",
            datetree = true,
          },
          t = {
            description = "Task / todo",
            template = "* TODO %?\n  %u",
          },
          n = {
            description = "Note / fact",
            template = "* %^{Note} :%^{tags}:\n  %u\n  %?",
            target = "~/org/notes.org",
          },
        },
      })

      require("org-bullets").setup()
    end,
  },

  -- Org needs its own tree-sitter grammar for folds/highlighting.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "org" } },
  },

  -- Completion for TODO keywords, tags, dates, links while editing org files.
  {
    "saghen/blink.cmp",
    dependencies = { "nvim-orgmode/orgmode" },
    opts = {
      sources = {
        per_filetype = { org = { "orgmode" } },
        providers = {
          orgmode = {
            name = "Orgmode",
            module = "orgmode.org.autocompletion.blink",
            fallbacks = { "buffer" },
          },
        },
      },
    },
  },
}
