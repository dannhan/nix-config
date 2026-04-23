{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "ruyam";
  home.homeDirectory = "/home/ruyam";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    btop
    tree
    lazygit
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Kode Mono";
        size = 12;
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Ahmad Danun Hanani";
      user.email = "ahmadanun1@gmail.com";
    };
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
      set expandtab shiftwidth=2
      color wildcharm
    '';
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
  };

  programs.qutebrowser = {
    enable = true;
    extraConfig = ''
      c.colors.webpage.preferred_color_scheme = "dark"
      c.colors.webpage.darkmode.enabled = False
      c.colors.webpage.bg = "black"
    '';
  };

  programs.noctalia-shell = {
    enable = true;
  };

  xdg.configFile."niri/config.kdl".source = ./dotfiles/niri.kdl;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
