{
  lib,
  ...
}:

let
  mod = "Mod4";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;

      fonts = {
        names = [ "Hack Nerd Font Mono" ];
        style = "Regular";
        size = 8.0;
      };

      focus.followMouse = false;

      startup = [
        {
          command = "dex --autostart --environment i3";
          notification = false;
        }
        {
          command = "xss-lock --transfer-sleep-lock -- i3lock --nofork -c 32302f";
          notification = false;
        }
        {
          command = "nm-applet";
          notification = false;
        }
        {
          command = "autorandr --change";
          notification = false;
        }
        {
          command = "autorandr-loader";
          notification = false;
        }
        {
          command = "feh --bg-fill /usr/share/backgrounds/DSC2943_by_kcpru.jpg";
          notification = false;
        }
        {
          command = "setxkbmap -option \"ctrl:nocaps\"";
          notification = false;
        }
        {
          command = "picom -b";
          notification = false;
        }
      ];

      keybindings = lib.mkOptionDefault {
        "${mod}+q" = "exec \"kitty tmux\"";
        "${mod}+f" = "exec firefox";
        "${mod}+space" = "exec \"rofi -show drun\"";
        "${mod}+g" = "exec \"rofi -show recursivebrowser\"";
        "${mod}+b" = "exec \"rofi -show window\"";
        "${mod}+t" = "exec teams-for-linux";
        "${mod}+m" = "exec thunderbird";

        "${mod}+c" = "kill";

        # Focus
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # Move
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Move workspace between monitors
        "${mod}+Ctrl+h" = "move workspace to output left; focus left";
        "${mod}+Ctrl+j" = "move workspace to output down";
        "${mod}+Ctrl+k" = "move workspace to output up";
        "${mod}+Ctrl+l" = "move workspace to output right";

        # Split in horizontal/vertical resp.
        "${mod}+Shift+-" = "split h";
        "${mod}+Shift+\\" = "split v";

        # Enter fullscreen for focused container
        "${mod}+Shift+f" = "fullscreen toggle";

        # Change container layout
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        # Toggle tiling/floating
        "${mod}+Shift+space" = "floating toggle";

        # Focus parent container
        "${mod}+a" = "focus parent";

        # Switch to workspace n
        "${mod}+1" = "workspace number \"1\"";
        "${mod}+2" = "workspace number \"2\"";
        "${mod}+3" = "workspace number \"3\"";
        "${mod}+4" = "workspace number \"4\"";
        "${mod}+5" = "workspace number \"5\"";
        "${mod}+6" = "workspace number \"6\"";
        "${mod}+7" = "workspace number \"7\"";
        "${mod}+8" = "workspace number \"8\"";
        "${mod}+9" = "workspace number \"9\"";
        "${mod}+0" = "workspace number \"0\"";

        # Toggle between workspaces
        "${mod}+Tab" = "workspace next_on_output";

        # Move focused container to workspace n
        "${mod}+Shift+1" = "workspace number \"1\"";
        "${mod}+Shift+2" = "workspace number \"2\"";
        "${mod}+Shift+3" = "workspace number \"3\"";
        "${mod}+Shift+4" = "workspace number \"4\"";
        "${mod}+Shift+5" = "workspace number \"5\"";
        "${mod}+Shift+6" = "workspace number \"6\"";
        "${mod}+Shift+7" = "workspace number \"7\"";
        "${mod}+Shift+8" = "workspace number \"8\"";
        "${mod}+Shift+9" = "workspace number \"9\"";
        "${mod}+Shift+r" = "restart";

        # Lock screen
        "${mod}+Ctrl+Shift+l" = "exec \"systemctl suspend\"";
        "${mod}+Ctrl+Shift+s" = "exec \"systemctl poweroff\"";

        # Resize
        "${mod}+r" = "resize";

        # Screenshot active window
        "${mod}+p" =
          "exec \"maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png\"";
      };

      modes = {
        resize = {
          Down = "resize grow height 10 px or 10 ppt";
          Escape = "mode default";
          Left = "resize shrink width 10 px or 10 ppt";
          Return = "mode default";
          Right = "resize grow width 10 px or 10 ppt";
          Up = "resize shrink height 10 px or 10 ppt";
        };
      };

      bars = [
        {
          statusCommand = "i3status";
        }
      ];

      floating.modifier = mod;
    };

    extraConfig = ''
      # Use pactl to adjust volume in PulseAudio.
      set $refresh_i3status killall -SIGUSR1 i3status
      bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
      bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
      bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
      bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

      # move tiling windows via drag & drop by left-clicking into the title bar,
      # or left-clicking anywhere into the window while holding the floating modifier.
      tiling_drag modifier titlebar
    '';
  };
}
