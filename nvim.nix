{ pkgs, ... }:

let
  vim-sage = pkgs.vimUtils.buildVimPlugin {
    name = "vim-sage";
    src = pkgs.fetchFromGitHub {
      owner = "petRUShka";
      repo = "vim-sage";
      rev = "4b036eead948e3ae1d414efdeefe11f7543fc366";
      hash = "sha256-byWgNJE9BDW91WiUoRhMK1BK58tAFBHFcTiLGLHUt3I=";
    };
  };

  vim-system-copy = pkgs.vimUtils.buildVimPlugin {
    name = "vim-system-copy";
    src = pkgs.fetchFromGitHub {
      owner = "christoomey";
      repo = "vim-system-copy";
      rev = "8abd9ed21016bdc21b458c79da3b9ac0ee25c1ce";
      hash = "sha256-Z+5Kv1jzzmKSmTtswd1XIskPhmrIHTPmJ+F/gX5/TiE=";
    };
  };

  vim-rainbow = pkgs.vimUtils.buildVimPlugin {
    name = "vim-rainbow";
    src = pkgs.fetchFromGitHub {
      owner = "frazrepo";
      repo = "vim-rainbow";
      rev = "a6c7fd5a2b0193b5dbd03f62ad820b521dea3290";
      hash = "sha256-zha3BNZXJSgEWEyh8fcy1+x3Y+c1DV1eTMa/AQ+sj7M=";
    };
  };
in
{
  enable = true;
  vimAlias = true;
  defaultEditor = true;
  coc = {
    enable = true;
    settings = {
      coc.preferences.formatOnSaveFiletypes = [
        "nix"
        "rust"
        "python"
        "fsharp"
        "c"
      ];
      rust-analyzer.enable = true;
      rust-analyzer.cargo.allFeatures = true;
      languageserver = {
        nix = {
          command = "nixd";
          filetypes = [ "nix" ];
          settings.nixd.formatting.command = [ "nixfmt" ];
        };
        python = {
          command = "pyright";
          filetypes = [ "py" ];
        };
        c = {
          command = "clangd";
          filetypes = [ "c" ];
          settings.clangd.formatting.command = [
            "clang-format"
          ];
        };
      };
      snippets.ultisnips.directories = [ "~/.config/home-manager" ];
    };
    pluginConfig = ''
      " Use `[g` and `]g` to navigate diagnostics
      " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " GoTo code navigation
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

      " Use K to show documentation in preview window
      nnoremap <silent> K :call ShowDocumentation()<CR>

      function! ShowDocumentation()
        if CocAction('hasProvider', 'hover')
          call CocActionAsync('doHover')
        else
          call feedkeys('K', 'in')
        endif
      endfunction

      " Symbol renaming
      nmap <leader>rn <Plug>(coc-rename)

      " Remap keys for applying code actions at the cursor position
      nmap <leader>ac  <Plug>(coc-codeaction-cursor)

      " Remap keys for applying refactor code actions
      nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)

      " Apply the most preferred quickfix action to fix diagnostic on the current line
      nmap <leader>qf  <Plug>(coc-fix-current)
    '';
  };
  withPython3 = true;
  plugins = with pkgs.vimPlugins; [
    {
      plugin = coc-nvim;
      config = ''
        noremap <silent> <C-t> :10split <bar> :term <CR>
        tnoremap <Esc> <C-\><C-n>
      '';
      # "allow coc completion on tab
      # inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<TAB>"
    }
    coc-rust-analyzer
    # coc-nix
    coc-json
    coc-go
    coc-sh
    coc-pyright
    coc-vimtex
    {
      plugin = coc-snippets;
      config = ''
        inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#_select_confirm() : coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',\'\'])\<CR>" : CheckBackspace() ? "\<TAB>" : coc#refresh()

        function! CheckBackspace() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        let g:coc_snippet_next = '<tab>'
      '';
    }
    Ionide-vim
    vim-sage
    plenary-nvim
    indentLine
    vim-system-copy
    {
      plugin = vim-tmux-navigator;
      config = ''
        let g:tmux_navigator_disable_when_zoomed = 1
      '';
    }
    vim-obsession
    {
      plugin = vim-rainbow;
      config = "let g:rainbow_active = 1";
    }
    lualine-nvim
    nvim-web-devicons
    vim-commentary
    {
      plugin = vim-oscyank;
      config = ''
        let g:system_copy_enable_osc52 = 1
        let g:oscyank_term = 'tmux'
      '';
    }
    {
      plugin = vimtex;
      config = ''
        " Filter out some compilation warning messages from QuickFix display
        let g:vimtex_quickfix_ignore_filters = [
              \ 'Underfull \\hbox',
              \ 'Overfull \\hbox',
              \ 'Underfull \\vbox',
              \ 'Overfull \\vbox',
              \ 'LaTeX Warning: .\+ float specifier changed to',
              \ 'LaTeX hooks Warning',
              \ 'Package siunitx Warning: Detected the "physics" package:',
              \ 'Package hyperref Warning: Token not allowed in a PDF string',
              \ 'Missing ',
              \]
        let g:vimtex_view_method = 'zathura'
        let g:tex_conceal='abdmg'
        let g:vimtex_callback_progpath = '/home/jcl24/.nix-profile/bin/nvim'

        " Function to toggle vimtex_quickfix_mode
        function! ToggleVimtexQuickfixMode()
            if g:vimtex_quickfix_mode == 1
                let g:vimtex_quickfix_mode = 0
            else
                let g:vimtex_quickfix_mode = 1
            endif
            echo "vimtex_quickfix_mode is now " . g:vimtex_quickfix_mode
        endfunction

        " Map Shift-Q to toggle vimtex_quickfix_mode
        nnoremap <S-q> :call ToggleVimtexQuickfixMode()<CR>
      '';
    }
    {
      plugin = telescope-nvim;
      config = ''
        nnoremap <C-p> <cmd>lua require('telescope.builtin').git_files()<cr>
        nnoremap <C-g> <cmd>lua require('telescope.builtin').live_grep()<cr>
        nnoremap <C-b> <cmd>lua require('telescope.builtin').buffers()<cr>
        nnoremap <C-i> <cmd>lua require('telescope.builtin').find_files()<cr>
      '';
    }
    vim-multiple-cursors
    {
      plugin = gruvbox-material;
      config = "colorscheme gruvbox-material";
    }
    obsidian-nvim
  ];
  extraPackages = with pkgs; [
    rust-analyzer
    nixd
  ];
  extraConfig = ''
    set mouse=
    set guicursor=n-v-c-i:block

    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent
    syntax on
    set number relativenumber
    set shell=/usr/bin/zsh
    set laststatus=2
    set nohlsearch
    set showcmd
    set splitbelow
    set splitright

    nnoremap <S-Tab> :Lex<CR>
    let g:netrw_banner = 0
    let g:netrw_liststyle = 3
    let g:netrw_browse_split = 4
    let g:netrw_altv = 1
    let g:netrw_winsize = 25

    let g:netrw_fastbrowse = 0
    autocmd FileType netrw setl bufhidden=wipe
    function! CloseNetrw() abort
      for bufn in range(1, bufnr('$'))
        if bufexists(bufn) && getbufvar(bufn, '&filetype') ==# 'netrw'
          silent! execute 'bwipeout ' . bufn
          if getline(2) =~# '^" Netrw '
            silent! bwipeout
          endif
          return
        endif
      endfor
    endfunction
    augroup closeOnOpen
      autocmd!
      autocmd BufWinEnter * if getbufvar(winbufnr(winnr()), "&filetype") != "netrw"|call CloseNetrw()|endif
    aug END

    set listchars=tab:➤\ ,trail:◆ et listchars=tab:➤\ ,trail:◆

    let filetypes = ['json']
    if index(filetypes, &filetype) != -1
        set conceallevel=0
    endif
    autocmd BufEnter *.tex set conceallevel=1
    autocmd BufEnter *.tex set concealcursor=nc

    let g:fsharp#fsi_command = "/nix/store/2ashk2ig3vb8s54mpyc2w5dgr4saqcvj-dotnet-sdk-6.0.427/bin/dotnet fsi"
    set shell=/home/jcl24/.nix-profile/bin/zsh

    " set T to go to last buffer
    noremap T <C-^>
  '';
  extraLuaConfig = ''
    local config = {
        options = {
            icons_enabled = true,
            theme = 'gruvbox-material',
            component_separators = "",
            section_separators = "",
            disabled_filetypes = {
                statusline = {},
                winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            globalstatus = false,
            refresh = {
                statusline = 1000,
                tabline = 1000,
                winbar = 1000,
            }
        },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'buffers'},
            lualine_x = {'searchcount'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
    }
    require('lualine').setup(config)

    require('telescope').setup{
        defaults = {
            mappings = {
                i = {
                ["<CR>"] = "select_default",
                }
            }
        }
    }
  '';
}
