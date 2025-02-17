{
    enable = true;
    enableCompletion = true;

    shellAliases = {
        # update = "sudo nixos-rebuild switch";
        # update-home = "nix-shell -p home-manager --run 'home-manager switch'";
        hmu = "home-manager switch";
        cat = "bat";
        ls = "eza";
        la = "ls -al --git";
        ":q" = "exit";
        cdg = "git rev-parse --is-inside-work-tree &>/dev/null && cd $(git rev-parse --show-toplevel)";
        shell_init = "$HOME/.config/home-manager/setup_nix.sh";
        ignore_init = "$HOME/.config/home-manager/gitignore.sh";
    };

    # To get around apparmor on Ubuntu 24.04
        # echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns
    initExtra = ''
        unalias gap
        source $HOME/git/.dotfiles/cargo/.config/eza_theme.sh
        any-nix-shell zsh --info-right | source /dev/stdin
        eval "$(direnv hook zsh)"
    '';

    oh-my-zsh = {
        enable = true;
        plugins = [ "git" "git-auto-fetch" ];
        custom = "$HOME/git/.dotfiles/ohmyzsh/.oh-my-zsh/custom";
        theme = "darkblood_upstream";
    };
}
