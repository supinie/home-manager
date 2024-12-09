{ config, pkgs, ... }:

{
    enable = true;
    package = config.lib.nixGL.wrap pkgs.kitty;
    font.name = "Hack Nerd Font Mono";
    themeFile = "GruvboxMaterialDarkMedium";
    shellIntegration.mode = "no-cursor";
    settings = {
        enable_audio_bell = false;
        cursor_shape = "block";
        shell = "zsh";
        confirm_os_window_close = 0;
    };
}
