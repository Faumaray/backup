  
-- Globals
O = vim.o
BO = vim.bo
WO = vim.wo
G = vim.g
opt = vim.opt
CMD = vim.cmd

-- syntax and filetypes
CMD('syntax enable') 
CMD('filetype plugin indent on')
-- Options
opt.clipboard = "unnamedplus"
opt.confirm = true
opt.cursorline = true
opt.smarttab = true
opt.mouse = "a"
opt.relativenumber = true
opt.showmode = false
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.wildmode = "longest:full,full"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize"}
-- Global option vim.O
O.shortmess = "IToOlxfitn"
O.background ='dark'
O.incsearch = true
O.incsearch = true
O.showmatch = true
O.completeopt = "menuone,noselect"
-- Buffer Local Options
BO.autoindent = true
BO.expandtab = true
BO.smartindent = true
BO.swapfile = false
BO.undofile = true

-- Window Local Options
WO.cursorline = true
WO.number = true
WO.relativenumber = true
WO.wrap = false


require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages

  ensure_installed = { "c", "rust", "bash","cpp","css","html","json","json5","latex","lua","python","scss","toml","yaml" },
  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,
  indent = {
	  enable = true
  },
  -- List of parsers to ignore installing
  ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
vim.api.nvim_command [[autocmd! TextChangedI,TextChangedP * lua on_complete_check()]]
function on_complete_check()
 local line = vim.api.nvim_get_current_line()
 local cursor = vim.api.nvim_win_get_cursor(0)[2]

 local current = string.sub(line, cursor, cursor + 1)
 if current == "." or current == "," or current == " " then
    require('cmp').close()
 end

 local before_line = string.sub(line, 1, cursor + 1)
 local after_line = string.sub(line, cursor + 1, -1)
 if not string.match(before_line, '^%s+$') then
    if after_line == "" or string.match(before_line, " $") or string.match(before_line, "%.$") then
        require('cmp').complete()
    end
 end
end
local cmp = require'cmp'
  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  if client.resolved_capabilities.document_formatting then
        vim.api.nvim_command [[augroup Format]]
        vim.api.nvim_command [[autocmd! * <buffer>]]
	vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
	vim.api.nvim_command [[augroup END]]
  end
  vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.diagnostic.open_float()')
  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  update_in_insert = true,
  virtual_text = { spacing = 4, prefix = "●" },
  severity_sort = true,
})
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}  
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'cssls','html','jsonls','pylsp','rust_analyzer' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
CMD('colorscheme aurora')
-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`
require'nvim-tree'.setup {
  disable_netrw       = true,
  hijack_netrw        = true,
  open_on_setup       = true,
  ignore_ft_on_setup  = {},
  auto_close          = true,
  open_on_tab         = false,
  hijack_cursor       = false,
  update_cwd          = true,
  update_to_buf_dir   = {
    enable = true,
    auto_open = true,
  },
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = 'left',
    auto_resize = false,
    mappings = {
      custom_only = false,
      list = {}
    },
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  }
}
local function cmd(argument)
    return "<cmd>" .. argument .. "<CR>"
end
local opts = {noremap = true, silent = true}
local key = vim.api.nvim_set_keymap
key('n', '<leader>sv', -- vertical split
   cmd("vsplit"),
   opts)

key('n', '<leader>sh', -- horizontal split
   cmd("split"),
   opts)

key('n', '<leader>q', -- close a window
   cmd("quit"),
   opts)
key('n', '<leader>w', -- save the current session
   cmd("w"),
   opts)
key('n', '<leader>wq', -- save and exit
    cmd("wq"),
    opts)
-- Move between windows
key('n', '<C-h>', '<C-w>h', opts)
key('n', '<C-j>', '<C-w>j', opts)
key('n', '<C-k>', '<C-w>k', opts)
key('n', '<C-l>', '<C-w>l', opts)
key('n', '<C-n>', cmd('NvimTreeToggle'),opts)
