{
  config,
  pkgs,
  lib,
  ...
}:

let
  autorandr-launcher = pkgs.callPackage ./autorandr-launcher.nix { };
  i3Imports = [ ./i3.nix ];
in
{
  imports = i3Imports;

  targets.genericLinux.nixGL = {
    packages = import <nixgl> { inherit pkgs; };
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jcl24";
  home.homeDirectory = "/home/jcl24";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # terminal
    # kitty
    ghostty
    kitty-themes
    zsh
    oh-my-zsh
    tmux
    texlab

    # cmd utils
    wget
    curl
    gnupg
    git
    neofetch
    htop
    bottom
    bat
    eza
    ripgrep
    ripgrep-all
    jaq
    gh
    nixpkgs-review
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
    picom
    _7zz-rar
    webcamoid
    brightnessctl

    # nix utils
    nh
    any-nix-shell
    direnv
    nixpkgs-review
    gnomeExtensions.window-calls
    nixfmt-rfc-style

    # # rust
    # rustup
    # gcc
    # bacon

    # # python
    # python3
    pyright

    # apps
    firefox
    obsidian
    teams-for-linux
    zathura
    libreoffice
    thunderbird
    gnome-tweaks
    rofi
    # mathematica
    servo
    librewolf
    signal-desktop
    feh
    discord

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # nerdfonts.override { fonts = [ "Hack" ]; }

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "mathematica"
      "7zz"
      "discord"
    ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jcl24/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Override kitty.desktop to launch with tmux
  xdg = import ./xdg.nix;

  # Let Home Manager install and manage itself.
  programs = {
    bacon = import ./bacon.nix;
    direnv = import ./direnv.nix;
    ghostty = import ./ghostty.nix;
    git = import ./git.nix;
    diff-so-fancy = import ./diff-so-fancy.nix;
    kitty = import ./kitty.nix {
      inherit config;
      inherit pkgs;
    };
    neovim = import ./nvim.nix { inherit pkgs; };
    rofi = import ./rofi.nix;
    tmux = import ./tmux.nix { inherit pkgs; };
    zathura = import ./zathura.nix;
    zsh = import ./zsh.nix;

    home-manager.enable = true;
  };

  services.picom = import ./picom.nix;

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
