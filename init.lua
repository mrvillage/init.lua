--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/

  And then you can explore or search through `:help lua-guide`


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.opt.spell = false
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "text", "plaintex", "tex", "markdown", "gitcommit", "mdx" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
  desc = "Enable spell checking for text files",
})

if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
    -- NOTE: First, some plugins that don't require any configuration

    -- Git related plugins
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
      -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      opts = {
        setup = {
          rust_analyzer = function()
            return true
          end,
        },
      },
      dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',

        -- Useful status updates for LSP
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        'folke/neodev.nvim',
      },
    },
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    {
      -- Autocompletion
      'hrsh7th/nvim-cmp',
      dependencies = {
        -- Snippet Engine & its associated nvim-cmp source
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',

        -- Adds LSP completion capabilities
        'hrsh7th/cmp-nvim-lsp',

        -- Adds a number of user-friendly snippets
        'rafamadriz/friendly-snippets',
      },
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',  opts = {} },
    {
      -- Adds git releated signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      opts = {
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          -- vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
          -- { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
          -- vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk,
          -- { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
          vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk,
            { buffer = bufnr, desc = '[P]review [H]unk' })
        end,
      },
    },

    {
      -- Theme inspired by Atom
      'navarasu/onedark.nvim',
      priority = 1000,
      config = function()
        vim.cmd.colorscheme 'onedark'
      end,
    },

    {
      -- Set lualine as statusline
      'nvim-lualine/lualine.nvim',
      -- See `:help lualine.txt`
      opts = {
        options = {
          icons_enabled = false,
          theme = 'onedark',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename', 'filesize' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
      },
    },

    {
      -- Add indentation guides even on blank lines
      'lukas-reineke/indent-blankline.nvim',
      -- Enable `lukas-reineke/indent-blankline.nvim`
      -- See `:help indent_blankline.txt`
      main = "ibl",
      opts = {},
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
      'nvim-telescope/telescope.nvim',
      branch = '0.1.x',
      dependencies = {
        'nvim-lua/plenary.nvim' }
    },
    {
      'nvim-telescope/telescope-live-grep-args.nvim',
      dependencies = { 'nvim-telescope/telescope.nvim' },
    },

    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build =
      'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
    },

    {
      -- Highlight, edit, and navigate code
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'JoosepAlviste/nvim-ts-context-commentstring',
      },
      build = ':TSUpdate',
      config = function(_, opts)
        require("nvim-treesitter.install").compilers = { "clang" }
      end,
    },
    -- 'nvim-treesitter/nvim-treesitter-context',

    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    require 'kickstart.plugins.autoformat',
    -- require 'kickstart.plugins.debug',

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
    --    up-to-date with whatever is in the kickstart repo.
    --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --
    --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
    -- { import = 'custom.plugins' },

    'github/copilot.vim',
    'akinsho/toggleterm.nvim',
    {
      'nvim-telescope/telescope-file-browser.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
      },
    },
    'ray-x/lsp_signature.nvim',
    'wakatime/vim-wakatime',
    'ThePrimeagen/harpoon',
    'RRethy/vim-illuminate',
    'chomosuke/term-edit.nvim',
    'mhartington/formatter.nvim',
    'ThePrimeagen/vim-be-good',
    {
      "lervag/vimtex",
      lazy = false, -- we don't want to lazy load VimTeX
      -- tag = "v2.15", -- uncomment to pin to a specific release
      init = function()
        -- VimTeX configuration goes here, e.g.
        vim.g.vimtex_view_method = "zathura"
      end
    },
    -- 'laytan/cloak.nvim',
    {
      'mrcjkb/rustaceanvim',
      version = '^5', -- Recommended
      lazy = false,   -- This plugin is already lazy
    },
    -- {
    --   "yetone/avante.nvim",
    --   event = "VeryLazy",
    --   version = false, -- Never set this value to "*"! Never!
    --   opts = {
    --   },
    --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    --   build = "make",
    --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    --   dependencies = {
    --     "nvim-treesitter/nvim-treesitter",
    --     "stevearc/dressing.nvim",
    --     "nvim-lua/plenary.nvim",
    --     "MunifTanjim/nui.nvim",
    --     --- The below dependencies are optional,
    --     "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    --     "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
    --     "ibhagwan/fzf-lua",              -- for file_selector provider fzf
    --     "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
    --     -- "zbirenbaum/copilot.lua",        -- for providers='copilot'
    --     {
    --       -- support for image pasting
    --       "HakonHarnes/img-clip.nvim",
    --       event = "VeryLazy",
    --       opts = {
    --         -- recommended settings
    --         default = {
    --           embed_image_as_base64 = false,
    --           prompt_for_file_name = false,
    --           drag_and_drop = {
    --             insert_mode = true,
    --           },
    --           -- required for Windows users
    --           use_absolute_path = true,
    --         },
    --       },
    --     },
    --     {
    --       -- Make sure to set this up properly if you have lazy=true
    --       'MeanderingProgrammer/render-markdown.nvim',
    --       opts = {
    --         file_types = { "markdown", "Avante" },
    --       },
    --       ft = { "markdown", "Avante" },
    --     },
    --   },
    -- }
  },
  {
    git = {
      url_format = "git@github.com:/%s.git",
    },
  }
)

vim.g.copilot_filetypes = { ['env'] = false }

-- Theme settings
require("onedark").setup {
  style = "warmer",
}
require("onedark").load()

-- require("treesitter-context").setup({
--   max_lines = 3,
-- })

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
-- vim.o.mouse = 'a'
vim.o.mouse = ''

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Tabs will be spaces
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.tabstop = 8
vim.o.softtabstop = 0

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

require("ibl").setup()

require('lsp_signature').setup({
  toggle_key = '<C-k>',
  select_signature_key = '<C-n>',

})

require('harpoon').setup({
  menu = {
    width = vim.api.nvim_win_get_width(0) - 60,
  },
  tabline = true,
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local telescope = require("telescope");
local telescopeConfig = require("telescope.config");

local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

table.insert(vimgrep_arguments, '--hidden')
table.insert(vimgrep_arguments, '--glob')
table.insert(vimgrep_arguments, '!**/.git/*')

telescope.load_extension("file_browser")
telescope.load_extension("live_grep_args")
telescope.load_extension("harpoon")

local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup({
  defaults = {
    vimgrep_arguments = vimgrep_arguments,
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-p>'] = require('telescope.actions.layout').toggle_preview
      },
    },
    path_display = { "truncate" },
    cache_picker = {
      num_pickers = 20,
    },
  },
  pickers = {
    find_files = {
      mappings = {
        n = {
          ["cd"] = function(prompt_bufnr)
            local selection = require("telescope.actions.state").get_selected_entry()
            if not selection then
              return
            end
            local dir = vim.fn.fnamemodify(selection.path, ":p:h")
            require("telescope.actions").close(prompt_bufnr)
            vim.cmd(string.format("silent cd %s", dir))
          end,
          ["cb"] = function(prompt_bufnr)
            local selection = vim.fn.getcwd()
            if not selection then
              return
            end
            local dir = vim.fn.fnamemodify(selection.path, ":p:h:h")
            require("telescope.actions").close(prompt_bufnr)
            vim.cmd(string.format("silent cd %s", dir))
          end,
        },
      },
      find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
    },
  },
  extensions = {
    live_grep_args = {
      auto_quoting = true,
      mappings = {
        i = {
          ["<C-k>"] = lga_actions.quote_prompt(),
          ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
        },
      },
    }
  }
})

require("Comment").setup({
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})
require('term-edit').setup({
  prompt_end = { '%$ ', '> ' },
})
require('formatter').setup({
  filetype = {
    javascript = require("formatter.filetypes.javascript").prettier,
    typescript = require("formatter.filetypes.typescript").prettier,
    javascriptreact = require("formatter.filetypes.javascriptreact").prettier,
    typescriptreact = require("formatter.filetypes.typescriptreact").prettier,
    graphql = require("formatter.filetypes.graphql").prettier,
    css = require("formatter.filetypes.css").prettier,
    markdown = require("formatter.filetypes.markdown").prettier,
  }
})

local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)

vim.keymap.set({ 'n', 'i' }, '<C-_>', require("Comment.api").toggle.linewise.current)
vim.keymap.set("v", '<C-_>', function()
  vim.api.nvim_feedkeys(esc, 'nx', false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end)

vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function()
    vim.cmd("setlocal wrap")
  end,
})

vim.api.nvim_set_keymap(
  "n",
  "<space>fb",
  ":Telescope file_browser<CR>",
  { noremap = true }
)

-- open file_browser with the path of the current buffer
vim.api.nvim_set_keymap(
  "n",
  "<space>fc",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>rs', require('telescope.builtin').resume, { desc = '[R]esume [S]earch' })
vim.keymap.set('n', '<leader>rp', require('telescope.builtin').resume, { desc = '[R]esume [P]icker' })
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').pickers, { desc = '[S]how [P]ickers' })

vim.keymap.set('n', '<leader>sr', require('telescope.builtin').registers, { desc = '[S]earch [R]egisters' })

vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, { desc = '[D]ocument [S]ymbols' })
vim.keymap.set('n', '<leader>dd', function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end,
  { desc = '[D]ocument [D]iagnostics' })
vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
  { desc = '[W]orkspace [S]ymbols' })
vim.keymap.set('n', '<leader>i', vim.lsp.buf.hover)
vim.keymap.set('i', '<C-i>', vim.lsp.buf.hover, { noremap = true })
vim.keymap.set('n', '<leader>so', require('telescope.builtin').oldfiles, { desc = '[S]earch [r]ecently opened files' })
vim.keymap.set('n', '<leader>sc', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Fuzzily [s]earch in [c]urrent buffer' })

vim.keymap.set({ 'n', 'v' }, '<C-k>', function()
    require('lsp_signature').toggle_float_win()
  end,
  { silent = true, noremap = true, desc = 'Toggle [K]eyboard signature' })

-- harpoon
vim.keymap.set("n", "<leader>hh", require("harpoon.ui").toggle_quick_menu,
  { noremap = true, silent = true, desc = '[H]arpoon [H]arpoon' })
vim.keymap.set("n", "<leader>ha", require("harpoon.mark").add_file,
  { noremap = true, silent = true, desc = '[H]arpoon [A]dd file' })
for idx = 1, 9 do
  vim.keymap.set("n", "<leader>t" .. idx,
    ':lua require("harpoon.term").gotoTerminal({idx = ' .. idx .. '})<CR>',
    { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>" .. idx, ':lua require("harpoon.ui").nav_file(' .. idx .. ')<CR>',
    { noremap = true, silent = true })
end
vim.keymap.set("n", "<leader>tc", require("harpoon.cmd-ui").toggle_quick_menu, { noremap = true, silent = true })


-- moving lines
vim.keymap.set("n", "m", function()
  local count = vim.v.count1
  -- move the line down
  vim.cmd("m .+" .. count)
end, { noremap = true, silent = true })
vim.keymap.set("n", "M", function()
  local count = vim.v.count1 + 1
  -- move the line up
  vim.cmd("m .-" .. count)
end, { noremap = true, silent = true })
vim.keymap.set("v", "m",
  ":'<,'>move '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "M",
  ":'<,'>move '<-2<CR>gv=gv", { noremap = true, silent = true })
-- function()
--   local count = vim.v.count1
--   -- move the selection down
--   vim.cmd("'<,'>move .+" .. count .. "<CR>gv=gv")
-- end
-- , { noremap = true, silent = true })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'bash', 'css', 'dart', 'dockerfile', 'gitignore', 'html', 'java', 'json', 'jsdoc', 'javascript', 'julia', 'latex', 'php', 'phpdoc', 'prisma', 'r', 'regex', 'sql', 'yaml', 'graphql', 'markdown', 'markdown_inline', 'lalrpop', 'toml', 'haskell', 'zig' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        -- ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        -- ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

vim.lsp.inlay_hint.enable(true)

vim.g.rustaceanvim = {
  tools = {
    test_executor = 'background',
  },
  server = {
    on_attach = function(_, bufnr)
      vim.keymap.set('n', '<leader>re', function()
        vim.cmd.RustLsp('expandMacro')
      end, { silent = true, buffer = bufnr, desc = '[R]ust [E]xpand Macro' })
      vim.keymap.set('n', '<leader>rb', function()
        vim.cmd.RustLsp('rebuildProcMacros')
      end, { silent = true, buffer = bufnr, desc = '[R]ust Re[b]uild Proc Macros' })
      vim.keymap.set('n', '<leader>ra', function()
        vim.cmd.RustLsp('codeAction')
      end, { silent = true, buffer = bufnr, desc = '[R]ust Code [A]ction' })
      vim.keymap.set('n', '<leader>rj', function()
        vim.cmd.RustLsp('joinLines')
      end, { silent = true, buffer = bufnr, desc = '[R]ust [J]oin Lines' })
      vim.keymap.set('v', '<leader>rj', function()
        vim.cmd.RustLsp('joinLines')
      end, { silent = true, buffer = bufnr, desc = '[R]ust [J]oin Lines' })
      vim.keymap.set('n', '<leader>rg', function()
        vim.cmd.RustLsp { 'crateGraph', '[backend]', '[output]' }
      end, { silent = true, buffer = bufnr, desc = '[R]ust Crate [G]raph' })
    end,
    default_settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
        },
        hover = {
          actions = {
            references = {
              enable = true,
            },
          },
        },
        checkOnSave = {
          command = 'clippy',
        },
        imports = {
          granularity = {
            enforce = true,
          },
        },
        lens = {
          enable = true,
          location = 'above_whole_item',
          references = {
            adt = {
              enable = true,
            },
            enumVariant = {
              enable = true,
            },
            method = {
              enable = true,
            },
            trait = {
              enable = true,
            },
          },
        },
        typing = {
          autoClosingAngleBrackets = {
            enable = true,
          },
        },
        procMacro = {
          enable = true,
        },
        semanticHighlighting = {
          punctuation = {
            enable = true,
          },
        },
        inlayHints = {
          lifetimeElisionHints = {
            enable = "always",
          },
          closureReturnTypeHints = {
            enable = "always",
          },
          expressionAdjustmentHints = {
            enable = "always",
          },
        },
        diagnostics = {
          refreshSupport = false,
        },
      },
    }
  }
}

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  clangd = {},
  -- gopls = {},
  pyright = {},
  -- rust_analyzer = {},
  ts_ls = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
    },
  },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  cssls = {},
  graphql = {},
  html = {},
  jsonls = {},
  intelephense = {},
  sqlls = {},
  tailwindcss = {},
  taplo = {},
  marksman = {},
  jdtls = {},
  julials = {},
  r_language_server = {},
  bashls = {},
  texlab = {},
  -- hls = {},
  zls = {},
}

local filetypes = {
  tailwindcss = { "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure", "django-html", "htmldjango", "edge",
    "eelixir", "elixir", "ejs", "erb", "eruby", "gohtml", "haml", "handlebars", "hbs", "html", "html-eex", "heex",
    "jade", "leaf", "liquid", "markdown", "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim", "twig", "css",
    "less", "postcss", "sass", "scss", "stylus", "sugarss", "javascript", "javascriptreact", "reason", "rescript",
    "typescript", "typescriptreact", "vue", "svelte", "rust" },
}
local init_options = {
  tailwindcss = {
    userLanguages = {
      rust = "html",
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'stylua', -- Used to format Lua code
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for server_name, server in pairs(servers) do
  -- This handles overriding only values explicitly passed
  -- by the server configuration above. Useful when disabling
  -- certain features of an LSP (for example, turning off formatting for ts_ls)
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  require('lspconfig')[server_name].setup {
    init_options = init_options[server_name] or nil,
    filetypes = filetypes[server_name] or nil,
    capabilities = capabilities,
    on_attach = on_attach,
    settings = server,
  }
end

require("lspconfig").dartls.setup({
  cmd = { "/home/village/.flutter/bin/dart", "language-server", "--protocol=lsp" },
  on_attach = on_attach,
  capabilities = capabilities,
})

-- require('mason-lspconfig').setup {
-- ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
-- automatic_installation = false,
-- handlers = {
--   function(server_name)
--     local server = servers[server_name] or {}
--     -- This handles overriding only values explicitly passed
--     -- by the server configuration above. Useful when disabling
--     -- certain features of an LSP (for example, turning off formatting for ts_ls)
--     server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
--     require('lspconfig')[server_name].setup {
--       init_options = init_options[server_name] or nil,
--       filetypes = filetypes[server_name] or nil,
--       capabilities = capabilities,
--       on_attach = on_attach,
--       settings = servers[server_name],
--     }
--   end,
-- },
-- }

-- require('cloak').setup({
--   enabled = true,
--   cloak_character = '*',
--   highlight_group = "Comment",
--   cloak_length = nil,
--   try_all_patterns = true,
--   patterns = {
--     {
--       file_pattern = ".env*",
--       cloak_pattern = "=.*",
--       replace = nil,
--     },
--   },
-- })

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = nil,
    -- cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_next_item()
    --   elseif luasnip.expand_or_locally_jumpable() then
    --     luasnip.expand_or_jump()
    --   else
    --     fallback()
    --   end
    -- end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip', entry_filter = function(entry)
      -- filter if the entry has the name "snippet"
      return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
    end
    },
  },
}

local Terminal = require('toggleterm.terminal').Terminal
local lazygit  = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "double",
  },
  -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
  -- function to run on closing the terminal
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _lazygit_toggle()
  lazygit:toggle()
end

vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })

vim.keymap.set('n', '<leader>q', function()
  vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(),
    { force = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()):find('term://', 1, true) == 1 })
end)
vim.keymap.set('n', '<leader>Q', function()
  vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(), { force = true })
end)

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(opts)
    if not opts.file:find('lazygit') then
      vim.keymap.set('t', '<ESC>', '<C-\\><C-N>', { buffer = opts.buf })
    end
  end
})

-- vim.api.nvim_create_autocmd('BufEnter', {
--  pattern = '*',
--  callback = function()
--    require('lazygit.utils').project_root_dir()
--  end,
-- })

-- Some keymaps to make me work a bit better
-- vim.keymap.set('i', '<C-BS>', 'db')
-- vim.keymap.set('i', '<C-Del>', 'dw')
-- vim.keymap.set('i', '<C-S>', ':w')

-- Settings for me
vim.wo.relativenumber = true

-- mrvillage-cli
vim.keymap.set('n', '<leader>mm', ':terminal mrvillage ')
vim.keymap.set('n', '<leader>mr', ':terminal mrvillage run ')
vim.keymap.set('n', '<leader>ps', ':terminal mrvillage run deploy-pnw -s<CR>')
vim.keymap.set('n', '<leader>pp', ':terminal mrvillage run deploy-pnw -ps<CR>')

-- avante
-- require("avante").setup({
--   debug = true,
--   provider = "claude",
--   -- provider = "ollama",
--   claude = {
--     endpoint = "https://api.anthropic.com",
--     model = "claude-sonnet-4-20250514",
--     -- model = "claude-3-7-sonnet-20250219",
--     temperature = 0,
--     max_tokens = 50000,
--   },
--   ollama = {
--     -- endpoint = "http://127.0.0.1:11434", -- Note that there is no /v1 at the end.
--     endpoint = "http://172.24.176.1:11434",
--     model = "qwq:latest",
--   },
-- })

-- vim.keymap.set('n', '<leader>al', function() vim.cmd(':AvanteClear') end, { desc = '[A]vante C[l]ear' })
-- Some shortcuts to resolve common typos
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Qa', 'qa', {})
vim.api.nvim_create_user_command('QA', 'qa', {})
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
