{
  programs.qutebrowser = {
    enable = true;
    extraConfig = ''
      c.colors.webpage.preferred_color_scheme = "dark"
      c.colors.webpage.darkmode.enabled = False
      c.colors.webpage.bg = "black"
    '';
  };
}
