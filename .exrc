let s:cpo_save=&cpo
set cpo&vim
cnoremap <silent> <C-R> <Cmd>lua require("which-key").show("\18", {mode = "c", auto = true})
inoremap <silent> <C-G>Þ <Nop>
inoremap <silent> <C-G> <Cmd>lua require("which-key").show("\7", {mode = "i", auto = true})
inoremap <silent> <C-R> <Cmd>lua require("which-key").show("\18", {mode = "i", auto = true})
inoremap <C-G>S <Plug>(nvim-surround-insert-line)
inoremap <C-G>s <Plug>(nvim-surround-insert)
inoremap <C-J> <Down>
inoremap <C-H> <Left>
inoremap <C-B> ^i
inoremap <C-K> <Up>
inoremap <C-L> <Right>
inoremap <C-W> u
inoremap <C-U> u
nnoremap  <Cmd> %y+ 
nnoremap  h
nnoremap <NL> j
nnoremap  k
nnoremap  l
nnoremap  <Cmd> NvimTreeToggle 
nnoremap  <Cmd> w 
nnoremap <silent> Þ <Nop>
nnoremap <silent>  <Cmd>lua require("which-key").show("\23", {mode = "n", auto = true})
tnoremap  
nnoremap  :noh 
nnoremap <silent>  Þ <Nop>
nnoremap <silent>   <Cmd>lua require("which-key").show(" ", {mode = "n", auto = true})
xnoremap <silent>  Þ <Nop>
xnoremap <silent>   <Cmd>lua require("which-key").show(" ", {mode = "v", auto = true})
nnoremap <silent>  pÞ <Nop>
nnoremap <silent>  mÞ <Nop>
nnoremap <silent>  rÞ <Nop>
nnoremap <silent>  wÞ <Nop>
nnoremap <silent>  gÞ <Nop>
nnoremap <silent>  cÞ <Nop>
nnoremap <silent>  fÞ <Nop>
nnoremap <silent>  tÞ <Nop>
vnoremap  / <Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())
nnoremap  fz <Cmd> Telescope current_buffer_fuzzy_find 
nnoremap  th <Cmd> Telescope themes 
nnoremap  fb <Cmd> Telescope buffers 
nnoremap  fo <Cmd> Telescope oldfiles 
nnoremap  fw <Cmd> Telescope live_grep 
nnoremap  cm <Cmd> Telescope git_commits 
nnoremap  fa <Cmd> Telescope find_files follow=true no_ignore=true hidden=true 
nnoremap  gt <Cmd> Telescope git_status 
nnoremap  ff <Cmd> Telescope find_files 
nnoremap  ma <Cmd> Telescope marks 
nnoremap  pt <Cmd> Telescope terms 
nnoremap  fh <Cmd> Telescope help_tags 
nnoremap  e <Cmd> NvimTreeFocus 
nnoremap  b <Cmd> enew 
nnoremap  n <Cmd> set nu! 
nnoremap  ch <Cmd> NvCheatsheet 
nnoremap  rn <Cmd> set rnu! 
nnoremap <silent> !aÞ <Nop>
nnoremap <silent> !iÞ <Nop>
nnoremap <silent> !Þ <Nop>
nnoremap <silent> ! <Cmd>lua require("which-key").show("!", {mode = "n", auto = true})
xnoremap <silent> " <Cmd>lua require("which-key").show("\"", {mode = "v", auto = true})
nnoremap <silent> " <Cmd>lua require("which-key").show("\"", {mode = "n", auto = true})
xnoremap # y?\V"
nnoremap & :&&
nnoremap <silent> ' <Cmd>lua require("which-key").show("'", {mode = "n", auto = true})
xnoremap * y/\V"
nnoremap <silent> <aÞ <Nop>
nnoremap <silent> <iÞ <Nop>
nnoremap <silent> <Þ <Nop>
nnoremap <silent> < <Cmd>lua require("which-key").show("<", {mode = "n", auto = true})
nnoremap <silent> >aÞ <Nop>
nnoremap <silent> >iÞ <Nop>
nnoremap <silent> >Þ <Nop>
nnoremap <silent> > <Cmd>lua require("which-key").show(">", {mode = "n", auto = true})
nnoremap <silent> @Þ <Nop>
nnoremap <silent> @ <Cmd>lua require("which-key").show("@", {mode = "n", auto = true})
xnoremap S <Plug>(nvim-surround-visual)
nnoremap Y y$
nnoremap <silent> [Þ <Nop>
nnoremap <silent> [ <Cmd>lua require("which-key").show("[", {mode = "n", auto = true})
nnoremap <silent> ]Þ <Nop>
nnoremap <silent> ] <Cmd>lua require("which-key").show("]", {mode = "n", auto = true})
nnoremap <silent> ` <Cmd>lua require("which-key").show("`", {mode = "n", auto = true})
nnoremap <silent> ciÞ <Nop>
nnoremap <silent> ci <Cmd>lua require("which-key").show("ci", {mode = "n", auto = true})
nnoremap <silent> cÞ <Nop>
nnoremap <silent> c <Cmd>lua require("which-key").show("c", {mode = "n", auto = true})
nnoremap <silent> caÞ <Nop>
nnoremap cS <Plug>(nvim-surround-change-line)
nnoremap cs <Plug>(nvim-surround-change)
nnoremap <silent> dÞ <Nop>
nnoremap <silent> d <Cmd>lua require("which-key").show("d", {mode = "n", auto = true})
nnoremap <silent> daÞ <Nop>
nnoremap <silent> diÞ <Nop>
nnoremap ds <Plug>(nvim-surround-delete)
xnoremap <silent> gÞ <Nop>
xnoremap <silent> g <Cmd>lua require("which-key").show("g", {mode = "v", auto = true})
nnoremap <silent> gUaÞ <Nop>
nnoremap <silent> gUiÞ <Nop>
nnoremap <silent> gUÞ <Nop>
nnoremap <silent> gbÞ <Nop>
nnoremap <silent> gcÞ <Nop>
nnoremap <silent> g~aÞ <Nop>
nnoremap <silent> g~iÞ <Nop>
nnoremap <silent> g~Þ <Nop>
nnoremap <silent> guaÞ <Nop>
nnoremap <silent> guiÞ <Nop>
nnoremap <silent> guÞ <Nop>
nnoremap <silent> gÞ <Nop>
nnoremap <silent> g <Cmd>lua require("which-key").show("g", {mode = "n", auto = true})
xnoremap gS <Plug>(nvim-surround-visual-line)
nnoremap <expr> j v:count || mode(1)[0:1] == "no" ? "j" : "gj"
xnoremap <expr> j v:count || mode(1)[0:1] == "no" ? "j" : "gj"
nnoremap <expr> k v:count || mode(1)[0:1] == "no" ? "k" : "gk"
xnoremap <expr> k v:count || mode(1)[0:1] == "no" ? "k" : "gk"
xnoremap <silent> p p:let @+=@0:let @"=@0
nnoremap <silent> viÞ <Nop>
nnoremap <silent> vi <Cmd>lua require("which-key").show("vi", {mode = "n", auto = true})
nnoremap <silent> vÞ <Nop>
nnoremap <silent> v <Cmd>lua require("which-key").show("v", {mode = "n", auto = true})
nnoremap <silent> vaÞ <Nop>
nnoremap <silent> yÞ <Nop>
nnoremap <silent> y <Cmd>lua require("which-key").show("y", {mode = "n", auto = true})
nnoremap <silent> yiÞ <Nop>
nnoremap <silent> yi <Cmd>lua require("which-key").show("yi", {mode = "n", auto = true})
nnoremap <silent> yaÞ <Nop>
nnoremap ySS <Plug>(nvim-surround-normal-cur-line)
nnoremap yS <Plug>(nvim-surround-normal-line)
nnoremap yss <Plug>(nvim-surround-normal-cur)
nnoremap ys <Plug>(nvim-surround-normal)
nnoremap <silent> zfaÞ <Nop>
nnoremap <silent> zfiÞ <Nop>
nnoremap <silent> zfÞ <Nop>
nnoremap <silent> zÞ <Nop>
nnoremap <silent> z <Cmd>lua require("which-key").show("z", {mode = "n", auto = true})
nnoremap <silent> <C-W>Þ <Nop>
nnoremap <silent> <C-W> <Cmd>lua require("which-key").show("\23", {mode = "n", auto = true})
xnoremap <silent> <Plug>(nvim-surround-visual-line) <Cmd>lua require'nvim-surround'.visual_surround({ line_mode = true })
xnoremap <silent> <Plug>(nvim-surround-visual) <Cmd>lua require'nvim-surround'.visual_surround({ line_mode = false })
nnoremap <C-N> <Cmd> NvimTreeToggle 
tnoremap <C-X> 
vnoremap <expr> <Up> v:count || mode(1)[0:1] == "no" ? "k" : "gk"
vnoremap <expr> <Down> v:count || mode(1)[0:1] == "no" ? "j" : "gj"
nnoremap <C-C> <Cmd> %y+ 
nnoremap <C-S> <Cmd> w 
nnoremap <C-K> k
nnoremap <C-J> j
nnoremap <expr> <Down> v:count || mode(1)[0:1] == "no" ? "j" : "gj"
nnoremap <C-H> h
nnoremap <expr> <Up> v:count || mode(1)[0:1] == "no" ? "k" : "gk"
nnoremap <C-L> l
inoremap  ^i
inoremap <silent> Þ <Nop>
inoremap <silent>  <Cmd>lua require("which-key").show("\7", {mode = "i", auto = true})
inoremap S <Plug>(nvim-surround-insert-line)
inoremap s <Plug>(nvim-surround-insert)
inoremap  <Left>
inoremap <NL> <Down>
inoremap  <Up>
inoremap  <Right>
cnoremap <silent>  <Cmd>lua require("which-key").show("\18", {mode = "c", auto = true})
inoremap <silent>  <Cmd>lua require("which-key").show("\18", {mode = "i", auto = true})
inoremap  u
inoremap  u
inoremap kj 
let &cpo=s:cpo_save
unlet s:cpo_save
set clipboard=unnamedplus
set expandtab
set fillchars=eob:\ 
set helplang=en
set ignorecase
set indentkeys=0{,0},0),0],:,0#,!^F,o,O,e,[,(,{,),},],&,=^s*\\bibitem,=\\item
set laststatus=3
set noloadplugins
set mouse=a
set packpath=/usr/share/nvim/runtime
set noruler
set runtimepath=~/.config/nvim,~/.local/share/nvim/lazy/lazy.nvim,~/.local/share/nvim/lazy/base46,~/.local/share/nvim/lazy/nvterm,~/.local/share/nvim/lazy/which-key.nvim,~/.local/share/nvim/lazy/cmp-path,~/.local/share/nvim/lazy/cmp-buffer,~/.local/share/nvim/lazy/cmp-nvim-lsp,~/.local/share/nvim/lazy/cmp-nvim-lua,~/.local/share/nvim/lazy/cmp_luasnip,~/.local/share/nvim/lazy/nvim-autopairs,~/.local/share/nvim/lazy/friendly-snippets,~/.local/share/nvim/lazy/LuaSnip,~/.local/share/nvim/lazy/nvim-cmp,~/.local/share/nvim/lazy/nvim-lspconfig,~/.local/share/nvim/lazy/gitsigns.nvim,~/.local/share/nvim/lazy/nvim-colorizer.lua,~/.local/share/nvim/lazy/indent-blankline.nvim,~/.local/share/nvim/lazy/nvim-treesitter,~/.local/share/nvim/lazy/nvim-web-devicons,~/.local/share/nvim/lazy/nvim-tree.lua,~/.local/share/nvim/lazy/nvim-surround,~/.local/share/nvim/lazy/ui,/usr/share/nvim/runtime,~/.local/state/nvim/lazy/readme,~/.local/share/nvim/lazy/cmp-path/after,~/.local/share/nvim/lazy/cmp-buffer/after,~/.local/share/nvim/lazy/cmp-nvim-lsp/after,~/.local/share/nvim/lazy/cmp-nvim-lua/after,~/.local/share/nvim/lazy/cmp_luasnip/after
set shiftwidth=2
set shortmess=ifnITFstOolx
set noshowmode
set showtabline=2
set smartcase
set smartindent
set softtabstop=2
set splitbelow
set splitright
set statusline=%!v:lua.require('nvchad_ui.statusline.default').run()
set tabline=%!v:lua.require('nvchad_ui.tabufline.modules').run()
set tabstop=2
set termguicolors
set timeoutlen=400
set undofile
set updatetime=250
set whichwrap=<>[]hl,b,s
set window=37
" vim: set ft=vim :
