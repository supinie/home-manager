{
  config,
  pkgs,
  lib,
  ...
}:

let
  autorandr-launcher = pkgs.callPackage ./autorandr-launcher.nix { };
  sp = pkgs.fetchurl {
    url = "https://gist.githubusercontent.com/supinie/c58a8c302053534e24a4dc3f0570d41d/raw/ebf1a351da5948ec519606f959bda16efd4135bf/sp";
    hash = "sha256-QVqjy8Evmq9Ji+FjMrT+C1LD5wN7y0/Xh7uYmiNHoCg=";
  };
  savepoint =
    (builtins.getFlake "github:NamtaoProductions/savepoint")
    .packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [
    ./bacon.nix
    ./diff-so-fancy.nix
    ./direnv.nix
    ./dunst.nix
    ./ghostty.nix
    ./git.nix
    ./i3.nix
    ./kitty.nix
    ./nix-clean.nix
    ./nvim.nix
    # ./picom.nix
    ./rofi.nix
    ./tmux.nix
    ./xdg.nix
    ./zathura.nix
    ./zsh.nix
  ];

  targets.genericLinux.nixGL = {
    packages = import <nixgl> { inherit pkgs; };
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  home = {
    username = "jcl24";
    homeDirectory = "/home/jcl24";

    # Do not change without first reading the Home Manager release notes.
    stateVersion = "24.05";

    # Packages with a programs.* or services.* module are installed by that
    # module and are not listed here.
    packages = with pkgs; [
      # terminal
      kitty-themes
      oh-my-zsh
      texlab

      # cmd utils
      wget
      curl
      gnupg
      htop
      bottom
      bat
      eza
      ripgrep
      ripgrep-all
      jaq
      gh
      tdf
      ddgr
      w3m
      wmctrl
      fd
      hexyl
      autorandr
      autorandr-launcher
      maim
      xclip
      xdotool
      # picom
      _7zz-rar
      webcamoid
      brightnessctl
      pomodoro
      claude-code
      (writeShellScriptBin "sp" (builtins.readFile sp))
      savepoint

      # audio: clickable tray applet to pick the output device + full mixer
      pasystray
      pavucontrol

      # nix utils
      nh
      any-nix-shell
      nixpkgs-review
      gnomeExtensions.window-calls

      # # rust
      # rustup
      # gcc

      # # python
      # python3
      pyright

      # apps
      (config.lib.nixGL.wrap firefox)
      obsidian
      teams-for-linux
      libreoffice
      thunderbird
      gnome-tweaks
      # mathematica
      servo
      librewolf
      signal-desktop
      feh
      # discord
      chromium
      gimp
      spotify
      zotero
      # zotero plugin deps
      djvulibre
      ocrmypdf
      tesseract
      qpdf
      pngquant
    ];
  };

  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "obsidian"
        "mathematica"
        "7zz"
        "discord"
        "spotify"
        "uasm"
        "claude-code"
        "firefox-esr-140-bin-unwrapped"
      ];
    permittedInsecurePackages = [
      "firefox-esr-140-bin-unwrapped-140.17.0esr"
    ];
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc.automatic = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Started from i3 (see i3.nix): graphical-session.target is never reached under i3.
  services.protonmail-bridge.enable = true;

  dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        window-calls.extensionUuid
      ];
    };
  };
}
