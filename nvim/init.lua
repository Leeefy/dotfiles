vim.cmd("set expandtab")
vim.cmd("set tabstop=3")
vim.cmd("set softtabstop=3")
vim.cmd("set shiftwidth=3")
vim.g.mapleader = ";"
vim.cmd("set undofile")
vim.cmd("set number")
vim.cmd("tnoremap <Esc><Esc> <C-\\><C-n>")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)




local plugins = {
   { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
   {
      'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' }
   },
   {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
   {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
         "nvim-lua/plenary.nvim",
         "nvim-tree/nvim-web-devicons",
         "MunifTanjim/nui.nvim",
      }
   },
   {
     'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' }
   },
   {
      "williamboman/mason.nvim"
   },
   {
      "williamboman/mason-lspconfig.nvim"
   },
   {"neovim/nvim-lspconfig"},
   {"nvim-telescope/telescope-ui-select.nvim"},
   {"hrsh7th/nvim-cmp"},
   {"L3MON4D3/LuaSnip"},
   {"saadparwaiz1/cmp_luasnip"},
   {"rafamadriz/friendly-snippets"},
   {"hrsh7th/cmp-nvim-lsp"},
   { "CRAG666/code_runner.nvim", config = true },
   {"nvim-telescope/telescope.nvim",
      dependencies = {
         "nvim-lua/plenary.nvim",
         "debugloop/telescope-undo.nvim",
      },
   },
   {"lambdalisue/vim-suda"},
}
local opts = {}

require ("lazy").setup(plugins,opts)




local builtin = require("telescope.builtin")

local config = require("nvim-treesitter.configs")
config.setup({
   auto_install = true,
   highlight = { enable = true },
   indent = { enable = true },
})

require('lualine').setup({
   options={
      theme='auto'
   }
})

require("telescope").setup {
   extensions = {
      ["ui-select"] = {
         require("telescope.themes").get_dropdown {
         }
      }
   }
}
require("telescope").load_extension("ui-select")

require('mason').setup()

require('mason-lspconfig').setup({
   ensure_installed = {"lua_ls", "ts_ls", "html", "cssls", "jedi_language_server", "jsonls"}
})

local cmp = require'cmp'
cmp.setup({
   snippet = {
      expand = function(args)
         require('luasnip').lsp_expand(args.body)
      end,
   },
   window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
   },
   mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
   }),
   sources = cmp.config.sources({
      -- { name = 'nvim_lsp' },
      { name = 'luasnip' },
   }, {
         { name = 'buffer' },
   })
})

require'cmp'.setup {
  sources = {
    { name = 'nvim_lsp' }
  }
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require("lspconfig")
lspconfig.lua_ls.setup({capabilities = capabilities})
lspconfig.ts_ls.setup({capabilities = capabilities})
lspconfig.html.setup({capabilities = capabilities})
lspconfig.cssls.setup({capabilities = capabilities})
lspconfig.jedi_language_server.setup({capabilities = capabilities})
lspconfig.jsonls.setup({capabilities = capabilities})

require("luasnip.loaders.from_vscode").lazy_load()

require('code_runner').setup({
  filetype = {
    java = {
      "cd $dir &&",
      "javac $fileName &&",
      "java $fileNameWithoutExt"
    },
    python = "python3 -u",
    typescript = "deno run",
    rust = {
      "cd $dir &&",
      "rustc $fileName &&",
      "$dir/$fileNameWithoutExt"
    },
    c = function(...)
      c_base = {
        "cd $dir &&",
        "gcc $fileName -o",
        "/tmp/$fileNameWithoutExt",
      }
      local c_exec = {
        "&& /tmp/$fileNameWithoutExt &&",
        "rm /tmp/$fileNameWithoutExt",
      }
      vim.ui.input({ prompt = "Add more args:" }, function(input)
        c_base[4] = input
        vim.print(vim.tbl_extend("force", c_base, c_exec))
        require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
      end)
    end,
  },
})

require("telescope").setup({})
require("telescope").load_extension("undo")

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin-latte"

vim.keymap.set('n', '<leader>f', builtin.find_files, {})
vim.keymap.set('n', '<leader>/', builtin.live_grep, {})
vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal left<CR>')
vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, {})
vim.keymap.set({'n', 'v'}, '<leader>a', vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
vim.keymap.set("n", "<leader>r", "<cmd>RunCode<cr>")
vim.keymap.set("n", "<leader>t", "<cmd>vsplit term://fish<cr>")
