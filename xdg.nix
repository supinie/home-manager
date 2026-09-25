{
    enable = true;
    # Sourced after plugin/rainbow.vim, so these autocmds run after rainbow's
    # own Syntax/ColorScheme hooks (autocmds fire in definition order).
    # rainbow's operator matches swallow the $ delimiters, so vimtex's $...$
    # maths zones never start and inline maths is not concealed; remove
    # rainbow from tex buffers every time it re-hooks itself.
    configFile."nvim/after/plugin/rainbow-tex.vim".text = ''
        augroup RainbowTexOff
            autocmd!
            autocmd Syntax tex silent! call rainbow#clear()
            autocmd ColorScheme * if &filetype ==# 'tex' | silent! call rainbow#clear() | endif
        augroup END
    '';
    desktopEntries = {
        kitty = {
            type = "Application";
            name = "kitty";
            genericName = "Terminal emulator";
            comment = "Fast, feature-rich, GPU based terminal";
            startupNotify = true;
            exec = "kitty tmux new-session zsh";
            icon = "kitty";
            categories = [ "System" "TerminalEmulator" ];
        };
    };
}
            

