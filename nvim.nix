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
            };
        };
    };
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
        {
            plugin = coc-nvim;
            config = ''
                noremap <silent> <C-t> :10split <bar> :term <CR>
                tnoremap <Esc> <C-\><C-n>
                "allow coc completion on tab
                inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<TAB>"
            '';
        }
        coc-rust-analyzer
        # coc-nix
        coc-json
        coc-go
        coc-sh
        coc-pyright
        coc-vimtex
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
        # {
        #     plugin = vim-rainbow;
        #     config = "let g:rainbow_active = 1";
        # }
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
                      \ 'LaTeX Warning: .\+ float specifier changed to',
                      \ 'LaTeX hooks Warning',
                      \ 'Package siunitx Warning: Detected the "physics" package:',
                      \ 'Package hyperref Warning: Token not allowed in a PDF string',
                      \]
                let g:vimtex_view_method = 'zathura'
                let g:tex_flavor='latex'
                let g:vimtex_quickfix_mode=0
                set conceallevel=1
                set concealcursor=nc
                let g:tex_conceal='abdmg'
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

        let g:netrw_banner = 0
        let g:netrw_liststyle = 3
        let g:netrw_browse_split = 4
        let g:netrw_altv = 1
        let g:netrw_winsize = 25

        set listchars=tab:➤\ ,trail:◆ et listchars=tab:➤\ ,trail:◆

        let filetypes = ['json', 'tex']
        if index(filetypes, &filetype) != -1
            set conceallevel=0
        endif
        autocmd BufEnter *.tex set conceallevel=1
        autocmd BufEnter *.tex set concealcursor=nc

        let g:fsharp#fsi_command = "/nix/store/2ashk2ig3vb8s54mpyc2w5dgr4saqcvj-dotnet-sdk-6.0.427/bin/dotnet fsi"
        set shell=/home/jcl24/.nix-profile/bin/zsh
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
