{
    enable = true;
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
            

