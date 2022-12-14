-- Settings for completion menu

-- Load auto-completion plugins
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end
luasnip.config.setup({ enable_autosnippets = true })

require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

-- Icons rendered in the menu
--   פּ ﯟ   some other good icons
local kind_icons = {
  Text = "",
  Method = "m",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = "",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet

cmp.setup ({

  -- Specify snippet engine
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },

  -- cmp sources
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" }, -- For `luasnip` users
    { name = "buffer" },
    { name = "path" },
  },

  -- key bindings for completion menu
  mapping = {
    -- Confirm selection with 'Return' or 'Ctrl-Return'
    ["<CR>"] = cmp.mapping.confirm(),

    -- Select next/prev item using tab/s-tab or c-j/c-k
		["<Tab>"]   = cmp.mapping.select_next_item(),
		["<C-j>"]   = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<C-k>"]   = cmp.mapping.select_prev_item(),

    -- Scroll documentation
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),

    -- Jump or Expand snippets with c-n/c-p
    ["<C-n>"] = cmp.mapping(function(fallback)
      if luasnip.expandable() then
        luasnip.expand({ select = true })
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<C-p>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),

    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
  },

  -- Display formats
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
      vim_item.menu = ({
        luasnip = "[S]",
        nvim_lsp = "[L]",
        buffer = "[B]",
        path = "[P]",
      })[entry.source.name]
      return vim_item
    end,
  },

  -- Menu borders
  window = {
    completion = { border = { "┌", "─", "┐",	"│", "┘", "─", "└",	"│" } },
    documentation = { border = { "┌", "─", "┐",	"│", "┘", "─", "└",	"│" } },
  },
})

-- Enable command-line completion 
cmp.setup.cmdline(':', {
  sources = {
    { name = 'cmdline', keyword_pattern = [[\!\@<!\w*]] },
    -- { name = 'path' },
  },
  formatting = {
    fields = { "kind", "abbr" },
  },
   -- Map Ctrl - j/k to select up/down
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
  },
})

