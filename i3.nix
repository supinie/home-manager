{
  lib,
  pkgs,
  ...
}:

let
  mod = "Mod4";

  # Wraps i3status to prepend a brightness block to the status line.
  # Refreshed by $refresh_i3status like the rest of the bar.
  # Enables the i3bar click-events protocol; clicks on the brightness block
  # adjust the backlight: left/scroll-up +5%, right/scroll-down -5%,
  # middle sets 50%.
  i3status-brightness = pkgs.writeShellScript "i3status-brightness" ''
    inject() {
      pct=$(brightnessctl -m | cut -d, -f4)
      printf '%s' "[{\"name\":\"brightness\",\"full_text\":\"☀ $pct\"},''${1#[}"
    }

    # Read click events sent by i3bar on stdin and act on those targeting
    # the brightness block.
    # stdin must be passed explicitly: background jobs otherwise have their
    # stdin reassigned to /dev/null.
    exec 3<&0
    {
      while read -r ev <&3; do
        case $ev in
          *'"name"'*'"brightness"'*)
            btn=$(printf '%s' "$ev" | sed -n 's/.*"button"[^0-9]*\([0-9]*\).*/\1/p')
            case $btn in
              1|4) brightnessctl -q set 5%+ ;;
              3|5) brightnessctl -n -q set 5%- ;;
              2) brightnessctl -q set 50% ;;
            esac
            killall -SIGUSR1 i3status
            ;;
        esac
      done
    } &

    i3status < /dev/null | {
      read -r header && printf '%s\n' '{"version":1,"click_events":true}'
      read -r open && printf '%s\n' "$open"
      read -r first && printf '%s\n' "$(inject "$first")"
      while read -r line; do
        printf ',%s\n' "$(inject "''${line#,}")"
      done
    }
  '';
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

      floating.criteria = [ { title = "Bluetooth Devices"; } ];

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
          # No system sleep on idle; lock and turn the screen off after 10 min instead.
          command = "xset s 600 600 dpms 0 0 600";
          notification = false;
        }
        {
          command = "nm-applet";
          notification = false;
        }
        {
          command = "pasystray";
          notification = false;
        }
        {
          command = "autorandr-loader";
          notification = false;
        }
        {
          command = "autorandr --change";
          notification = false;
        }
        {
          command = "feh --bg-fill --randomize ~/.config/home-manager/wallpapers/*";
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
        "${mod}+z" = "exec zotero";
        "${mod}+o" = "exec obsidian";

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
        # "${mod}+Shift+-" = "split h";
        # "${mod}+Shift+\\" = "split v";

        # Enter fullscreen for focused container
        "${mod}+Shift+f" = "fullscreen toggle";

        # Change container layout
        "${mod}+r" = "layout stacking";
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
        "${mod}+Shift+1" = "move container to workspace number \"1\"";
        "${mod}+Shift+2" = "move container to workspace number \"2\"";
        "${mod}+Shift+3" = "move container to workspace number \"3\"";
        "${mod}+Shift+4" = "move container to workspace number \"4\"";
        "${mod}+Shift+5" = "move container to workspace number \"5\"";
        "${mod}+Shift+6" = "move container to workspace number \"6\"";
        "${mod}+Shift+7" = "move container to workspace number \"7\"";
        "${mod}+Shift+8" = "move container to workspace number \"8\"";
        "${mod}+Shift+9" = "move container to workspace number \"9\"";
        "${mod}+Shift+r" = "restart";

        # Lock screen
        "${mod}+Ctrl+Shift+l" = "exec \"systemctl suspend\"";
        "${mod}+Ctrl+Shift+s" = "exec \"systemctl poweroff\"";

        # Resize
        "${mod}+Shift+q" = "resize";

        # Screenshot active window
        "${mod}+p" =
          "exec \"maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png\"";
        "${mod}+s" = " exec \"maim -s -u | xclip -selection clipboard -t image/png -i\"";

        # Control Spotify
        "${mod}+less" = "exec \"sp prev\"";
        "${mod}+greater" = "exec \"sp play\"";
        "${mod}+slash" = "exec \"sp next\"";

        # Make the currently focused window a scratchpad
        "${mod}+Shift+minus" = "move scratchpad";

        # Show the first scratchpad window
        "${mod}+minus" = "scratchpad show";
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
          statusCommand = "${i3status-brightness}";
          extraConfig = ''
            # Scroll on the bar to adjust screen brightness.
            bindsym button4 exec --no-startup-id brightnessctl -q set 5%+ && killall -SIGUSR1 i3status
            bindsym button5 exec --no-startup-id brightnessctl -n -q set 5%- && killall -SIGUSR1 i3status
          '';
          colors = {
            background = "#282828";
            separator = "#1b1b1b";

            focusedWorkspace = {
              border = "#a9b665";
              background = "#a9b665";
              text = "#282828";
            };

            inactiveWorkspace = {
              border = "#282828";
              background = "#282828";
              text = "#d4be98";
            };

            urgentWorkspace = {
              border = "#e78a4e";
              background = "#e78a4e";
              text = "#282828";
            };
          };
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

      # Use brightnessctl to adjust screen brightness.
      bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl -q set 5%+ && $refresh_i3status
      bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl -n -q set 5%- && $refresh_i3status

      # move tiling windows via drag & drop by left-clicking into the title bar,
      # or left-clicking anywhere into the window while holding the floating modifier.
      tiling_drag modifier titlebar

      # Color shemes for windows
      set $bgcolor    #a9b665
      set $in-bgcolor #282828
      set $text       #d4be98
      set $u-bgcolor  #e78a4e
      set $indicator  #d8a567
      set $in-text    #7c6f64
      #                       border          background      text            indicator (a line which shows where the next window will be placed)
      client.focused          $bgcolor        $bgcolor        $in-bgcolor     $bgcolor
      client.unfocused        $in-bgcolor     $in-bgcolor     $in-text        $in-bgcolor
      client.focused_inactive $in-bgcolor     $in-bgcolor     $in-text        $in-bgcolor
      client.urgent           $u-bgcolor      $u-bgcolor      $text           $u-bgcolor

      gaps inner 8px
      gaps outer 8px
    '';
  };

  # Copy of the system default /etc/i3status.conf, with output_format forced
  # to i3bar so the brightness wrapper can inject its JSON block.
  xdg.configFile."i3status/config".text = ''
    general {
            colors = true
            interval = 1
            output_format = "i3bar"
    }

    order += "ipv6"
    order += "wireless _first_"
    order += "ethernet _first_"
    order += "battery all"
    order += "disk /"
    order += "load"
    order += "memory"
    order += "tztime local"

    wireless _first_ {
            format_up = "W: (%quality at %essid) %ip"
            format_down = "W: down"
    }

    ethernet _first_ {
            format_up = "E: %ip (%speed)"
            format_down = "E: down"
    }

    battery all {
            format = "%status %percentage %remaining"
    }

    disk "/" {
            format = "%avail"
    }

    load {
            format = "%1min"
    }

    memory {
            format = "%used | %available"
            threshold_degraded = "1G"
            format_degraded = "MEMORY < %available"
    }

    tztime local {
            format = "%Y-%m-%d %H:%M:%S"
    }
  '';
}
