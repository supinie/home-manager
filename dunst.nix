{
  enable = true;
  settings = {
    global = {
      width = "(200,300)";
      height = "(0,150)";
      offset = "(30,50)";
      origin = "top-right";
      transparency = 10;
      frame_color = "#43402f";
      font = "Hack Nerd Font Mono";
    };

    urgency_normal = {
      background = "#a9b665";
      foreground = "#282828";
      timeout = 10;
    };

    urgency_critical = {
      background = "#ea6962";
      foreground = "#282828";
      timeout = 10;
    };
  };
}
