{ config, pkgs, ... }:

let
  nix-weekly-clean = pkgs.writeShellApplication {
    name = "nix-weekly-clean";
    runtimeInputs = [
      config.nix.package
      pkgs.coreutils
      pkgs.findutils
      pkgs.libnotify
    ];
    text = ''
      # home-manager itself comes from the profile
      export PATH="${config.home.profileDirectory}/bin:$PATH"

      summary="Finished"
      finish() {
        if [ "$?" -eq 0 ]; then
          notify-send "Nix weekly clean" "$summary"
        else
          notify-send -u critical "Nix weekly clean" "Failed; see journalctl --user -u nix-weekly-clean"
        fi
      }
      trap finish EXIT
      notify-send "Nix weekly clean" "Started"

      if ! { nix-channel --update && home-manager switch; }; then
        echo "update failed; cleaning anyway"
        summary="Finished, but the channel update or home-manager switch failed"
      fi

      # nix-direnv sources .direnv/*.rc on every load, so its atime tracks last use
      find "$HOME/git" "$HOME/research" -maxdepth 5 -type d -name .direnv -prune -print0 |
        while IFS= read -r -d "" d; do
          if [ -z "$(find "$d" -maxdepth 1 -name '*.rc' -atime -14 -print -quit)" ]; then
            echo "removing $d"
            rm -rf "$d"
          fi
        done

      nix-collect-garbage --delete-older-than 14d
    '';
  };
in

{
  home.packages = [ nix-weekly-clean ];

  systemd.user.services.nix-weekly-clean = {
    Unit = {
      Description = "Update channels, switch home-manager, prune stale direnvs, collect garbage";
      # the switch inside this job must not restart the job itself
      X-SwitchMethod = "keep-old";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${nix-weekly-clean}/bin/nix-weekly-clean";
    };
  };

  systemd.user.timers.nix-weekly-clean = {
    Unit.Description = "Weekly Nix clean-up";
    Timer = {
      OnCalendar = "Mon *-*-* 14:30:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
