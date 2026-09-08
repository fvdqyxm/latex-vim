" ============================================================================
" Neovim configuration — Keshav Ramamurthy
"
" Purpose: coding (C/C++/Python/Lua) + LaTeX course notes (VimTeX).
"
" File map:
"   §1  Core editor settings
"   §2  Keymaps — leader, windows, tabs, buffers, terminal, navigation
"   §3  Plugins (vim-plug)
"   §4  Theme
"   §5  LaTeX workflow — VimTeX, template seeding, debounced autosave
"   §6  Autocommands — writing mode, tree startup, misc guards
"   §7  Lua plugin setup — UI, nav, completion, formatting, lint, LSP
"   §8  Compatibility commands
"
" Notes:
"   • TeX snippets live in after/plugin/luasnip.lua (single source of truth).
"   • New .tex buffers are seeded from textemplate.tex (see §5).
"   • LaTeX builds land NEXT TO the .tex source (no out_dir), matching
"     fa26_books/scripts/sync.sh, so VimTeX and sync.sh produce one PDF.
" ============================================================================

" ============================================================================
" §1  Core editor settings
" ============================================================================
if has('nvim')
  " Python provider for plugins that need it (jupytext, etc.)
  let g:python3_host_prog = "/Users/keshavramamurthy/Berkeley/research/venv/bin/python"
endif

" --- Editing / indentation ---
set nocompatible
set encoding=utf-8
set fileencoding=utf-8
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

" --- Appearance / scrolling ---
set number
set relativenumber
set cursorline
set signcolumn=yes
set scrolloff=6
set sidescrolloff=8
set nowrap
set termguicolors
set pumblend=0
set winblend=0

" --- Search ---
set ignorecase
set smartcase
set incsearch
set nohlsearch

" --- Completion / timers / messages ---
set completeopt=menu,menuone,noselect
set updatetime=200
set timeoutlen=400
set shortmess+=c

" --- Files / sessions ---
set hidden
set undofile
set noswapfile
set nobackup
set nowritebackup

" --- Misc ---
set mouse=a
set nospell
set conceallevel=0
set concealcursor=
set noshowmatch
set splitbelow
set splitright
set clipboard=unnamedplus

" If nvim is launched from a dead cwd, fall back to $HOME so project
" commands and the file tree behave predictably.
lua << EOF
local startup_cwd = vim.loop.cwd()
if not startup_cwd or startup_cwd == "" then
  local home = vim.loop.os_homedir()
  if home and home ~= "" then
    pcall(vim.cmd.cd, vim.fn.fnameescape(home))
  end
end
EOF

syntax enable
filetype plugin indent on

" Avoid noisy bracket flash overlays (matchparen is superseded here).
let g:loaded_matchparen = 1

" ============================================================================
" §2  Keymaps
" ============================================================================
let mapleader = " "
inoremap jk <Esc>

" --- §2.1 Save / quit ---
nnoremap <silent> <leader>w <cmd>write<CR>
nnoremap <silent> <leader>q <cmd>quit<CR>
nnoremap <silent> <leader>Q <cmd>qa!<CR>
nnoremap <silent> <leader>nh <cmd>nohlsearch<CR>

" --- §2.2 Windows and splits (VSCode-like) ---
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <silent> <leader>sv <cmd>vsplit<CR>
nnoremap <silent> <leader>sh <cmd>split<CR>
nnoremap <silent> <leader>se <cmd>wincmd =<CR>
nnoremap <silent> <leader>sx <cmd>close<CR>
nnoremap <silent> <leader><Tab> <C-w>w
" Swap the focused code pane left/right (commands defined in §7.2)
nnoremap <silent> <leader>, <cmd>CodeWinMoveLeft<CR>
nnoremap <silent> <leader>. <cmd>CodeWinMoveRight<CR>

" Fast split resizing
nnoremap <silent> <leader><Left> <cmd>vertical resize -6<CR>
nnoremap <silent> <leader><Right> <cmd>vertical resize +6<CR>
nnoremap <silent> <leader><Up> <cmd>resize -3<CR>
nnoremap <silent> <leader><Down> <cmd>resize +3<CR>

" --- §2.3 Tabs ---
nnoremap <silent> <leader>to <cmd>tabnew<CR>
nnoremap <silent> <leader>tx <cmd>tabclose<CR>
nnoremap <silent> <leader>tn <cmd>tabnext<CR>
nnoremap <silent> <leader>tp <cmd>tabprevious<CR>
nnoremap <silent> <leader>] <cmd>tabnext<CR>
nnoremap <silent> <leader>[ <cmd>tabprevious<CR>
nnoremap <silent> <leader>1 1gt
nnoremap <silent> <leader>2 2gt
nnoremap <silent> <leader>3 3gt
nnoremap <silent> <leader>4 4gt
nnoremap <silent> <leader>5 5gt
nnoremap <silent> <leader>6 6gt
nnoremap <silent> <leader>7 7gt
nnoremap <silent> <leader>8 8gt
nnoremap <silent> <leader>9 9gt
" Browser-style tab cycling (works in terminals that emit Ctrl-Tab codes)
nnoremap <silent> <C-Tab> <cmd>tabnext<CR>
nnoremap <silent> <C-S-Tab> <cmd>tabprevious<CR>
inoremap <silent> <C-Tab> <C-o><cmd>tabnext<CR>
inoremap <silent> <C-S-Tab> <C-o><cmd>tabprevious<CR>

" --- §2.4 Buffers ---
nnoremap <silent> <S-l> <cmd>bnext<CR>
nnoremap <silent> <S-h> <cmd>bprevious<CR>
nnoremap <silent> <leader>bn <cmd>bnext<CR>
nnoremap <silent> <leader>bp <cmd>bprevious<CR>
nnoremap <silent> <leader>bd <cmd>bdelete<CR>

" --- §2.5 Terminal mode ---
" Keep Ctrl-w hjkl pane navigation muscle memory from terminal buffers.
tnoremap <C-w>h <C-\><C-n><C-w>h
tnoremap <C-w>j <C-\><C-n><C-w>j
tnoremap <C-w>k <C-\><C-n><C-w>k
tnoremap <C-w>l <C-\><C-n><C-w>l
tnoremap <silent> <C-Tab> <C-\><C-n>:tabnext<CR>
tnoremap <silent> <C-S-Tab> <C-\><C-n>:tabprevious<CR>
tnoremap <Esc><Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
tnoremap <silent> <leader><Left> <C-\><C-n>:vertical resize -6<CR>i
tnoremap <silent> <leader><Right> <C-\><C-n>:vertical resize +6<CR>i
tnoremap <silent> <leader><Up> <C-\><C-n>:resize -3<CR>i
tnoremap <silent> <leader><Down> <C-\><C-n>:resize +3<CR>i
tnoremap <silent> <leader><Tab> <C-\><C-n><C-w>w
tnoremap <silent> <leader>, <C-\><C-n>:CodeWinMoveLeft<CR>
tnoremap <silent> <leader>. <C-\><C-n>:CodeWinMoveRight<CR>

" --- §2.6 Project navigation (tree, telescope, diagnostics) ---
nnoremap <silent> <leader>e <cmd>NvimTreeToggle<CR>
nnoremap <silent> <leader>o <cmd>NvimTreeFocus<CR>
nnoremap <silent> <leader>ff <cmd>Telescope find_files hidden=true<CR>
nnoremap <silent> <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <silent> <leader>fb <cmd>Telescope buffers<CR>
nnoremap <silent> <leader>fr <cmd>Telescope oldfiles<CR>
nnoremap <silent> <leader>fh <cmd>Telescope help_tags<CR>
nnoremap <silent> <leader>fs <cmd>Telescope lsp_document_symbols<CR>
nnoremap <silent> <leader>fS <cmd>Telescope lsp_dynamic_workspace_symbols<CR>
nnoremap <silent> <C-f> <cmd>Telescope live_grep<CR>
nnoremap <silent> <C-S-f> <cmd>Telescope find_files hidden=true<CR>

" Diagnostics panel (trouble.nvim)
nnoremap <silent> <leader>xx <cmd>Trouble diagnostics toggle<CR>
nnoremap <silent> <leader>xq <cmd>Trouble qflist toggle<CR>
nnoremap <silent> <leader>xl <cmd>Trouble loclist toggle<CR>
nnoremap <silent> <leader>xs <cmd>Trouble symbols toggle focus=false<CR>

" --- §2.7 Legacy mapping compatibility ---
" Ctrl-C toggles a comment like the VSCode muscle memory expects.
nmap <C-c> gcc
vmap <C-c> gc

" ============================================================================
" §3  Plugins (vim-plug)
" ============================================================================
call plug#begin('~/.config/nvim/autoload/plugged')

" --- UI / navigation ---
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'stevearc/aerial.nvim', { 'branch': 'nvim-0.11' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'folke/trouble.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'folke/tokyonight.nvim'
Plug 'EdenEast/nightfox.nvim'
Plug 'NLKNguyen/papercolor-theme'

" --- Editing / git ---
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'

" --- LaTeX / writing ---
Plug 'lervag/vimtex'
Plug 'junegunn/goyo.vim'
Plug 'preservim/vim-pencil'
Plug 'micangl/cmp-vimtex'
Plug 'kdheepak/cmp-latex-symbols'

" --- Completion / snippets / diagnostics / formatting / LSP ---
" (The friendly-snippets library is intentionally NOT installed: nothing
"  loads it — TeX snippets are defined directly in after/plugin/luasnip.lua.)
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'}
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'windwp/nvim-autopairs'
Plug 'folke/which-key.nvim'
Plug 'mfussenegger/nvim-lint'
Plug 'stevearc/conform.nvim'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'Civitasv/cmake-tools.nvim'

" --- Utilities ---
Plug '907th/vim-auto-save'
Plug 'goerz/jupytext.vim'
" NOTE: classlayout is NOT lazy-loaded with {'for': ['c','cpp']}; lazy loading
" prevented the setup() call below from ever running.
Plug 'J-Cowsert/classlayout.nvim'
call plug#end()

" ============================================================================
" §4  Theme
" ============================================================================
set background=light
silent! colorscheme morning

" ============================================================================
" §5  LaTeX workflow (VimTeX + snippets + template + debounced autosave)
" ============================================================================

" --- §5.1 VimTeX ---
let g:tex_flavor = 'latex'
let g:tex_conceal = ''
let g:vimtex_syntax_enabled = 1
let g:vimtex_matchparen_enabled = 0
let g:vimtex_imaps_enabled = 0
let g:vimtex_complete_enabled = 1
" Do not open or resize a quickfix pane during background compiles.
" Use <leader>le (or :VimtexErrors) when you want to inspect errors.
let g:vimtex_quickfix_mode = 0
let g:vimtex_compiler_method = 'latexmk'
" NOTE: no 'out_dir' — PDFs land next to the .tex source, exactly like
" ./scripts/sync.sh in fa26_books. One build location, one PDF.
let g:vimtex_compiler_latexmk = {
      \ 'continuous': 1,
      \ 'options': ['-file-line-error', '-interaction=nonstopmode', '-synctex=1'],
      \}
let g:vimtex_compiler_latexmk_engines = {
      \ '_': '-lualatex',
      \ 'pdflatex': '-pdf',
      \ 'lualatex': '-lualatex',
      \ 'xelatex': '-xelatex',
      \}
if isdirectory('/Applications/Skim.app')
  let g:vimtex_view_method = 'skim'
else
  let g:vimtex_view_method = 'general'
endif
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_automatic = 1

" --- §5.2 General auto-save (disabled for TeX, which has its own debounce) ---
let g:auto_save = 1
let g:auto_save_silent = 1
let g:auto_save_events = ['InsertLeave', 'TextChanged', 'TextChangedI']
let g:jupytext_command = '/Users/keshavramamurthy/Berkeley/research/venv/bin/jupytext'

" --- §5.3 Debounced TeX autosave ---
" TeX gets a debounced save so VimTeX does not rebuild and refresh the viewer
" on every keystroke while a command or environment is half-typed.
lua << EOF
local tex_autosave_group = vim.api.nvim_create_augroup("TexDebouncedAutosave", { clear = true })
local tex_save_timers = {}

local function stop_tex_timer(buf)
  local timer = tex_save_timers[buf]
  if timer then
    pcall(timer.stop, timer)
    pcall(timer.close, timer)
    tex_save_timers[buf] = nil
  end
end

local function save_tex(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modified then return end
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent update")
  end)
end

vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
  group = tex_autosave_group,
  pattern = "*.tex",
  callback = function(args)
    local buf = args.buf
    stop_tex_timer(buf)
    tex_save_timers[buf] = vim.defer_fn(function()
      save_tex(buf)
      tex_save_timers[buf] = nil
    end, 650)
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = tex_autosave_group,
  pattern = "*.tex",
  callback = function(args)
    stop_tex_timer(args.buf)
    save_tex(args.buf)
  end,
})
EOF

" --- §5.4 New .tex files are seeded from this template ---
function! s:InsertTexTemplate() abort
  let l:template = expand('~/.config/nvim/textemplate.tex')
  if filereadable(l:template)
    execute '0read ' . fnameescape(l:template)
  endif
endfunction

" --- §5.5 TeX buffer workflow ---
augroup TexWorkflow
  autocmd!
  autocmd BufRead,BufNewFile *.tex setfiletype tex
  autocmd BufNewFile *.tex call s:InsertTexTemplate()
  " Start continuous compile shortly after opening a TeX buffer.
  autocmd FileType tex call timer_start(300, {-> execute('silent! VimtexCompile')})
  " TeX relies on the debounced saver above instead of vim-auto-save.
  autocmd FileType tex let b:auto_save = 0
  " Half-typed inline/display math gets its closing delimiter immediately.
  autocmd FileType tex inoremap <silent><buffer> \( \(\)<Left><Left>
  autocmd FileType tex inoremap <silent><buffer> \[ \[\]<Left><Left>
  " Fast lecture-note formatting: type the trigger in Insert mode.
  autocmd FileType tex inoremap <silent><buffer> ;b <C-g>u\textbf{}<Left>
  autocmd FileType tex inoremap <silent><buffer> ;i <C-g>u\emph{}<Left>
  " spalign column vectors / matrices: type e.g. ;v then "1; 2; 3}" inside.
  autocmd FileType tex inoremap <silent><buffer> ;v <C-g>u\spalignvector{}<Left>
  autocmd FileType tex inoremap <silent><buffer> ;m <C-g>u\spalignmat{}<Left>
  autocmd FileType tex inoremap <silent><buffer> ;c <C-g>u<CR><CR>\noindent\textit{Claim.}<Space>
  autocmd FileType tex inoremap <silent><buffer> ;p <C-g>u<CR><CR>\noindent\textit{Proof.}<Space>
  autocmd FileType tex inoremap <silent><buffer> ;r <C-g>u<CR><CR>\noindent\textit{Remark.}<Space>
  autocmd FileType tex setlocal spell spelllang=en_us wrap linebreak breakindent textwidth=88 colorcolumn=89
  autocmd FileType tex setlocal formatoptions+=jcroql nocursorline conceallevel=0 concealcursor=

  " Compile / view / inspect (see reference/lecture_latex_vimtex_cheatsheet.pdf)
  autocmd FileType tex nnoremap <silent><buffer> <leader>ll <cmd>VimtexCompile<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>la <cmd>update<CR><cmd>VimtexCompile<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>lv <cmd>VimtexView<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>lk <cmd>VimtexStop<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>le <cmd>VimtexErrors<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>lt <cmd>VimtexTocToggle<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>lc <cmd>VimtexClean<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>li <cmd>VimtexInfo<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>lm <cmd>VimtexCompileSS<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>lo <cmd>VimtexCompileOutput<CR>
  autocmd FileType tex nnoremap <silent><buffer> <leader>ts <cmd>setlocal spell!<CR>
augroup END

" ============================================================================
" §6  Autocommands (non-TeX)
" ============================================================================

" Delete .DS_Store buffers if the tree ever opens one.
augroup BinaryJunkGuard
  autocmd!
  autocmd BufReadPost *.DS_Store bdelete!
augroup END

" Distraction-free writing for prose (Markdown + Goyo).
augroup WritingMode
  autocmd!
  autocmd FileType markdown call pencil#init({'wrap': 'soft'})
  autocmd User GoyoEnter setlocal spell spelllang=en_us wrap linebreak
  autocmd User GoyoLeave setlocal nospell nowrap
augroup END
nnoremap <silent> <leader>zw <cmd>Goyo<CR>

" Open the project tree on startup when nvim is launched without a file.
augroup NvimTreeStartup
  autocmd!
  autocmd VimEnter * if argc() == 0 | NvimTreeOpen | endif
  " If nvim starts on a directory, cd into it and open the tree.
  autocmd VimEnter * if argc() == 1 && isdirectory(argv(0)) | execute 'cd ' . fnameescape(argv(0)) | NvimTreeOpen | endif
augroup END

" Ctrl-F inside the tree also opens live grep.
augroup NvimTreeCtrlF
  autocmd!
  autocmd FileType NvimTree nnoremap <silent><buffer> <C-f> :Telescope live_grep<CR>
augroup END

" ============================================================================
" §7  Lua plugin setup
" ============================================================================
lua << EOF
local function safe_require(name)
  local ok, mod = pcall(require, name)
  if ok then
    return mod
  end
  return nil
end

local keymap = vim.keymap.set

-- ===== §7.1 Diagnostics + which-key =====
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many" },
})

local wk = safe_require("which-key")
if wk then
  wk.setup({})
end

-- ===== §7.2 Project window workflow =====
-- Swap code panes left/right and open files in the right-most code pane
-- (nvim-tree stays on the left, terminals are ignored).

local nvim_tree_api = safe_require("nvim-tree.api")
local function is_nvim_tree_win(winid)
  if not winid or winid == 0 or not vim.api.nvim_win_is_valid(winid) then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(winid)
  return vim.bo[buf].filetype == "NvimTree"
end

local function is_project_edit_win(winid)
  if not winid or winid == 0 or not vim.api.nvim_win_is_valid(winid) then
    return false
  end

  if is_nvim_tree_win(winid) then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(winid)
  local bt = vim.bo[buf].buftype
  return bt == ""
end

local refresh_project_window_layout

local function ordered_project_windows()
  local wins = {}
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_project_edit_win(winid) then
      local pos = vim.api.nvim_win_get_position(winid)
      table.insert(wins, { winid = winid, row = pos[1], col = pos[2] })
    end
  end

  table.sort(wins, function(left, right)
    if left.col == right.col then
      return left.row < right.row
    end
    return left.col < right.col
  end)

  return wins
end

local function swap_project_windows(direction)
  local current = vim.api.nvim_get_current_win()
  if not is_project_edit_win(current) then
    vim.notify("Focus a code window before reordering panes", vim.log.levels.INFO)
    return
  end

  local wins = ordered_project_windows()
  local current_index = nil
  for index, item in ipairs(wins) do
    if item.winid == current then
      current_index = index
      break
    end
  end

  if not current_index then
    return
  end

  local target_index = direction == "left" and (current_index - 1) or (current_index + 1)
  if target_index < 1 or target_index > #wins then
    return
  end

  local target = wins[target_index].winid
  local current_buf = vim.api.nvim_win_get_buf(current)
  local target_buf = vim.api.nvim_win_get_buf(target)
  local current_view = vim.api.nvim_win_call(current, function()
    return vim.fn.winsaveview()
  end)
  local target_view = vim.api.nvim_win_call(target, function()
    return vim.fn.winsaveview()
  end)

  vim.api.nvim_win_set_buf(current, target_buf)
  vim.api.nvim_win_set_buf(target, current_buf)
  vim.api.nvim_win_call(current, function()
    pcall(vim.fn.winrestview, target_view)
  end)
  vim.api.nvim_win_call(target, function()
    pcall(vim.fn.winrestview, current_view)
  end)
  vim.api.nvim_set_current_win(target)
  refresh_project_window_layout()
end

refresh_project_window_layout = function()
  vim.cmd("wincmd =")
end

local function pick_project_anchor_window()
  local alternate = vim.fn.win_getid(vim.fn.winnr("#"))
  if is_project_edit_win(alternate) then
    return alternate
  end

  local best_win = nil
  local best_col = -1
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_project_edit_win(winid) then
      local pos = vim.api.nvim_win_get_position(winid)
      if pos[2] > best_col then
        best_col = pos[2]
        best_win = winid
      end
    end
  end

  return best_win
end

local function open_in_project_window(path)
  local anchor = pick_project_anchor_window()
  if anchor then
    vim.api.nvim_set_current_win(anchor)
  end

  vim.cmd("edit " .. vim.fn.fnameescape(path))
  refresh_project_window_layout()
end

vim.api.nvim_create_user_command("CodeWinMoveLeft", function()
  swap_project_windows("left")
end, { desc = "Move active code pane left" })

vim.api.nvim_create_user_command("CodeWinMoveRight", function()
  swap_project_windows("right")
end, { desc = "Move active code pane right" })

keymap("n", "<M-h>", function()
  swap_project_windows("left")
end, { desc = "Move code pane left" })
keymap("n", "<M-l>", function()
  swap_project_windows("right")
end, { desc = "Move code pane right" })

-- ===== §7.3 nvim-tree =====
local function nvim_tree_on_attach(bufnr)
  if not nvim_tree_api then
    return
  end

  nvim_tree_api.map.on_attach.default(bufnr)
  vim.wo[vim.api.nvim_get_current_win()].winfixwidth = true

  local function opts(desc)
    return {
      desc = "nvim-tree: " .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  local function open_project_file()
    local node = nvim_tree_api.tree.get_node_under_cursor()
    if not node then
      return
    end

    if node.type ~= "file" then
      nvim_tree_api.node.open.edit(node)
      return
    end

    local path = node.link_to or node.absolute_path
    if not path or path == "" then
      return
    end

    open_in_project_window(path)
  end

  vim.keymap.set("n", "<CR>", open_project_file, opts("Open in Current Window"))
  vim.keymap.set("n", "o", open_project_file, opts("Open in Current Window"))
  vim.keymap.set("n", "l", open_project_file, opts("Open in Current Window"))
  vim.keymap.set("n", "v", nvim_tree_api.node.open.vertical, opts("Open: Vertical Split"))
  vim.keymap.set("n", "s", nvim_tree_api.node.open.horizontal, opts("Open: Horizontal Split"))
  vim.keymap.set("n", "t", nvim_tree_api.node.open.tab, opts("Open: New Tab"))
  vim.keymap.set("n", "<Tab>", nvim_tree_api.node.open.preview, opts("Open Preview"))
end

local nvim_tree = safe_require("nvim-tree")
if nvim_tree then
  nvim_tree.setup({
    on_attach = nvim_tree_on_attach,
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    update_focused_file = { enable = true, update_root = true },
    view = {
      width = 36,
      preserve_window_proportions = true,
    },
    renderer = {
      group_empty = true,
      highlight_git = true,
      icons = {
        show = {
          file = false,
          folder = false,
          folder_arrow = false,
          git = false,
        },
      },
    },
    filters = {
      dotfiles = true,
      git_ignored = false,
      custom = {
        "^%.DS_Store$",
        "^%.Spotlight%-V100$",
        "^%.fseventsd$",
        "^%.Trashes$",
        "^%.pytest_cache$",
        "^%.pycache__$",
        "^__pycache__$",
      },
    },
    git = { enable = true, ignore = false },
    actions = {
      open_file = {
        quit_on_open = false,
        resize_window = true,
        window_picker = {
          enable = false,
        },
      },
    },
  })
end

-- ===== §7.4 Status line / tabs / outline =====
local bufferline = safe_require("bufferline")
if bufferline then
  bufferline.setup({
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      show_buffer_icons = false,
      separator_style = "slant",
      show_buffer_close_icons = true,
      show_close_icon = false,
      offsets = {
        {
          filetype = "NvimTree",
          text = "Project",
          text_align = "left",
          separator = true,
        },
      },
    },
  })
end

local aerial = safe_require("aerial")
if aerial then
  aerial.setup({
    backends = { "lsp", "treesitter" },
    layout = {
      default_direction = "prefer_right",
      placement = "edge",
      min_width = 28,
      max_width = { 42, 0.25 },
      resize_to_content = true,
      preserve_equality = true,
    },
    attach_mode = "global",
    filter_kind = false,
    highlight_mode = "split_width",
    close_on_select = false,
    show_guides = true,
  })

  keymap("n", "<leader>so", "<cmd>AerialToggle!<CR>", { desc = "Structure outline" })
end

local lualine = safe_require("lualine")
if lualine then
  lualine.setup({
    options = {
      theme = "auto",
      globalstatus = true,
      section_separators = { left = "", right = "" },
      component_separators = { left = "|", right = "|" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        { "filename", path = 1 },
      },
      lualine_x = { "aerial", "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

-- ===== §7.5 Git signs / trouble =====
local gitsigns = safe_require("gitsigns")
if gitsigns then
  gitsigns.setup({
    current_line_blame = false,
  })
end

local trouble = safe_require("trouble")
if trouble then
  trouble.setup({})
end

-- ===== §7.6 Treesitter =====
-- Highlighting stays off: Vim's regex syntax (and VimTeX for TeX) is the
-- preferred engine; treesitter is here for indentation, textobjects, aerial.
local ts = safe_require("nvim-treesitter.configs")
if ts then
  ts.setup({
    ensure_installed = {
      "lua", "vim", "vimdoc", "query", "bash",
      "python", "javascript", "typescript", "tsx",
      "json", "yaml", "toml", "markdown", "markdown_inline",
      "c", "cpp", "cmake", "java", "rust", "go", "latex", "bibtex"
    },
    highlight = {
      enable = false,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
      },
    },
  })
end

-- ===== §7.7 Telescope =====
local telescope = safe_require("telescope")
if telescope then
  local actions = safe_require("telescope.actions")
  local rg_bin = vim.fn.exepath("rg")
  if rg_bin == "" and vim.fn.executable("/Applications/Codex.app/Contents/Resources/rg") == 1 then
    rg_bin = "/Applications/Codex.app/Contents/Resources/rg"
  end

  telescope.setup({
    defaults = {
      vimgrep_arguments = rg_bin ~= "" and {
        rg_bin,
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      } or nil,
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
        preview_width = 0.55,
        width = 0.95,
        height = 0.90,
      },
      sorting_strategy = "ascending",
      path_display = { "smart" },
      file_ignore_patterns = { "%.git/", "node_modules/" },
      mappings = actions and {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      } or nil,
    },
    pickers = {
      find_files = { hidden = true },
      live_grep = {
        additional_args = function()
          return { "--hidden" }
        end,
      },
    },
  })
  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "aerial")

  local builtin = safe_require("telescope.builtin")

  local function grep_current_symbol()
    if not builtin then
      return
    end

    local symbol = vim.fn.expand("<cword>")
    if symbol == nil or symbol == "" then
      vim.notify("No symbol under cursor", vim.log.levels.INFO)
      return
    end

    builtin.grep_string({
      search = symbol,
      word_match = "-w",
    })
  end

  local function grep_current_file_mentions()
    if not builtin then
      return
    end

    local full_path = vim.api.nvim_buf_get_name(0)
    if full_path == "" then
      vim.notify("Current buffer is not file-backed", vim.log.levels.WARN)
      return
    end

    local cwd = vim.loop.cwd() or ""
    local search = vim.fn.fnamemodify(full_path, ":t")
    local include_prefix = cwd ~= "" and (cwd .. "/include/") or ""
    local src_prefix = cwd ~= "" and (cwd .. "/src/") or ""

    if include_prefix ~= "" and full_path:sub(1, #include_prefix) == include_prefix then
      search = full_path:sub(#include_prefix + 1)
    elseif src_prefix ~= "" and full_path:sub(1, #src_prefix) == src_prefix then
      search = full_path:sub(#src_prefix + 1)
    end

    builtin.grep_string({
      search = search,
      use_regex = false,
    })
  end

  if builtin then
    keymap("n", "<leader>ss", function()
      local aerial_ext = telescope.extensions and telescope.extensions.aerial
      if aerial_ext and aerial_ext.aerial then
        aerial_ext.aerial()
      else
        builtin.lsp_document_symbols()
      end
    end, { desc = "Structure symbols" })
    keymap("n", "<leader>sr", builtin.lsp_references, { desc = "Symbol references" })
    keymap("n", "<leader>sm", grep_current_symbol, { desc = "Mention current symbol" })
    keymap("n", "<leader>si", grep_current_file_mentions, { desc = "Mention current file" })
  end
end

-- ===== §7.8 classlayout (C/C++ memory layout) =====
local classlayout = safe_require("classlayout")
if classlayout then
  classlayout.setup({
    keymap = "<Plug>(ClassLayoutShowRaw)",
    compiler = "clang",
    args = {},
    compile_commands = true,
  })

  local function show_class_layout()
    if vim.bo.filetype ~= "c" and vim.bo.filetype ~= "cpp" then
      vim.notify("ClassLayout is only available in C/C++ buffers", vim.log.levels.INFO)
      return
    end

    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" then
      vim.notify("ClassLayout requires a file-backed buffer", vim.log.levels.WARN)
      return
    end

    if vim.bo.modified then
      vim.cmd("silent write")
    end

    classlayout.show()
  end

  vim.api.nvim_create_user_command("ClassLayoutSaved", show_class_layout, {
    desc = "Save current C/C++ file and show memory layout under cursor",
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(ev)
      local opts = { buffer = ev.buf, silent = true }
      keymap("n", "<leader>cl", show_class_layout, vim.tbl_extend("force", opts, {
        desc = "Class layout (save + show)",
      }))
      keymap("n", "<leader>cL", "<cmd>ClassLayout<CR>", vim.tbl_extend("force", opts, {
        desc = "Class layout (raw plugin command)",
      }))
    end,
  })
end

-- ===== §7.9 Completion (nvim-cmp) =====
-- TeX snippets themselves live in after/plugin/luasnip.lua.
local luasnip = safe_require("luasnip")

local cmp = safe_require("cmp")
if cmp then
  cmp.setup({
    snippet = {
      expand = function(args)
        if luasnip then
          luasnip.lsp_expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    }),
  })

  local cmp_vimtex = safe_require("cmp_vimtex")
  if cmp_vimtex and cmp_vimtex.setup then
    cmp_vimtex.setup({})
  end

  -- TeX gets VimTeX completion + LaTeX symbols first.
  cmp.setup.filetype("tex", {
    sources = cmp.config.sources({
      { name = "vimtex" },
      { name = "latex_symbols" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    }),
  })

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
  })
end

-- ===== §7.10 Autopairs =====
local autopairs = safe_require("nvim-autopairs")
if autopairs then
  autopairs.setup({})
  local cmp_ap = safe_require("nvim-autopairs.completion.cmp")
  if cmp and cmp_ap then
    cmp.event:on("confirm_done", cmp_ap.on_confirm_done())
  end
end

-- ===== §7.11 Formatting (conform.nvim) =====
local conform = safe_require("conform")
if conform then
  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "black" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      java = { "google-java-format" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      tex = { "latexindent" },
    },
  })
  keymap("n", "<leader>cf", function()
    conform.format({ async = true, lsp_fallback = true })
  end, { silent = true, desc = "Format buffer" })
end

-- ===== §7.12 Linting (nvim-lint + chktex for TeX) =====
local lint = safe_require("lint")
if lint then
  lint.linters_by_ft = {}
  if vim.fn.executable("chktex") == 1 then
    lint.linters_by_ft.tex = { "chktex" }
  end

  local function run_lint()
    if vim.bo.buftype ~= "" then
      return
    end

    local filename = vim.api.nvim_buf_get_name(0)
    if filename == "" or vim.fn.filereadable(filename) == 0 then
      return
    end

    local ok, err = pcall(lint.try_lint)
    if ok or not err or tostring(err):match("ENOENT") then
      return
    end

    vim.schedule(function()
      vim.notify("Lint failed: " .. tostring(err), vim.log.levels.WARN)
    end)
  end

  local lint_group = vim.api.nvim_create_augroup("LiveLint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "TextChanged", "BufWritePost" }, {
    group = lint_group,
    callback = run_lint,
  })

  keymap("n", "<leader>lx", run_lint, { silent = true, desc = "Run lint" })
end

-- ===== §7.13 CMake (C/C++ projects) =====
local cmake_tools = safe_require("cmake-tools")
if cmake_tools then
  local cmake_startup_cwd = vim.loop.cwd()
  local cmake_build_terminal = {
    name = "CMake Build Terminal",
    prefix_name = "[CMake]: ",
    split_direction = "horizontal",
    split_size = 14,
    single_terminal_per_instance = true,
    single_terminal_per_tab = true,
    keep_terminal_static_location = true,
    auto_resize = true,
    start_insert = false,
    focus = false,
    do_not_add_newline = false,
  }

  local cmake_run_terminal = vim.tbl_extend("force", cmake_build_terminal, {
    name = "CMake Run Terminal",
    focus = true,
    use_shell_alias = true,
  })

  if cmake_startup_cwd and cmake_startup_cwd ~= "" then
    cmake_tools.setup({
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_use_preset = true,
      cmake_regenerate_on_save = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = {
        action = "lsp",
      },
      cmake_build_directory = "build",
      cmake_executor = {
        name = "terminal",
        opts = cmake_build_terminal,
      },
      cmake_runner = {
        name = "terminal",
        opts = cmake_run_terminal,
      },
    })
  end

  keymap("n", "<leader>cp", "<cmd>CMakeSelectConfigurePreset<CR>", { desc = "CMake configure preset" })
  keymap("n", "<leader>cP", "<cmd>CMakeSelectBuildPreset<CR>", { desc = "CMake build preset" })
  keymap("n", "<leader>ct", "<cmd>CMakeSelectTestPreset<CR>", { desc = "CMake test preset" })
  keymap("n", "<leader>cg", "<cmd>CMakeGenerate<CR>", { desc = "CMake generate" })
  keymap("n", "<leader>cb", "<cmd>CMakeBuild<CR>", { desc = "CMake build" })
  keymap("n", "<leader>cr", "<cmd>CMakeRun<CR>", { desc = "CMake run" })
  keymap("n", "<leader>cT", "<cmd>CMakeRunTest<CR>", { desc = "CMake test" })
end

-- ===== §7.14 LSP (Mason + lspconfig) =====
local mason = safe_require("mason")
if mason then
  mason.setup()
end

local mason_lsp = safe_require("mason-lspconfig")
if mason_lsp then
  mason_lsp.setup({
    ensure_installed = { "clangd", "pyright", "jdtls", "lua_ls", "bashls", "jsonls", "marksman" },
  })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp = safe_require("cmp_nvim_lsp")
if cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local on_attach = function(client, bufnr)
  if client and client.server_capabilities then
    client.server_capabilities.semanticTokensProvider = nil
    client.server_capabilities.documentHighlightProvider = false
  end

  local map = function(mode, lhs, rhs)
    keymap(mode, lhs, rhs, { buffer = bufnr, silent = true })
  end

  local telescope_builtin = safe_require("telescope.builtin")

  map("n", "gd", vim.lsp.buf.definition)
  map("n", "gD", vim.lsp.buf.declaration)
  map("n", "gr", telescope_builtin and telescope_builtin.lsp_references or vim.lsp.buf.references)
  map("n", "gi", telescope_builtin and telescope_builtin.lsp_implementations or vim.lsp.buf.implementation)
  map("n", "K", vim.lsp.buf.hover)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>ca", vim.lsp.buf.code_action)
  map("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end)
  map("n", "[d", vim.diagnostic.goto_prev)
  map("n", "]d", vim.diagnostic.goto_next)
  map("n", "<leader>ld", vim.diagnostic.open_float)

  if client and client.server_capabilities and client.server_capabilities.documentHighlightProvider then
    local hl_group = vim.api.nvim_create_augroup("LspDocumentHighlight" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = hl_group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
      group = hl_group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  if client and client.name == "clangd" then
    if vim.lsp.inlay_hint and client.server_capabilities and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    map("n", "<leader>ch", function()
      if vim.fn.exists(":LspClangdSwitchSourceHeader") == 2 then
        vim.cmd("LspClangdSwitchSourceHeader")
      elseif vim.fn.exists(":ClangdSwitchSourceHeader") == 2 then
        vim.cmd("ClangdSwitchSourceHeader")
      else
        vim.notify("No clangd source/header switch command is available", vim.log.levels.WARN)
      end
    end)
  end
end

local servers = { "clangd", "pyright", "jdtls", "lua_ls", "bashls", "jsonls", "marksman" }
local server_settings = {
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    },
  },
}

if vim.lsp and vim.lsp.config and vim.lsp.enable then
  -- Neovim 0.11+ native LSP API
  for _, server in ipairs(servers) do
    local config = vim.tbl_deep_extend("force", {
      capabilities = capabilities,
      on_attach = on_attach,
    }, server_settings[server] or {})
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end
else
  -- Older Neovim: fall back to lspconfig.setup
  local lspconfig = safe_require("lspconfig")
  if lspconfig then
    for _, server in ipairs(servers) do
      if lspconfig[server] then
        local config = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, server_settings[server] or {})
        lspconfig[server].setup(config)
      end
    end
  end
end

EOF

" ============================================================================
" §8  Compatibility commands
" ============================================================================
" NERDTree muscle-memory compatibility (nvim-tree backend).
command! NERDTreeToggle NvimTreeToggle
command! NERDTreeFocus NvimTreeFocus
