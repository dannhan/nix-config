{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default

    ./modules/nixvim.nix
  ];

  home.username = "ruyam";
  home.homeDirectory = "/home/ruyam";
  home.shellAliases = {
    inbox = "nvim ${config.home.homeDirectory}/docs/working/inbox.md";
  };
  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # Standard overrides
    desktop = config.home.homeDirectory;
    download = "${config.home.homeDirectory}/downloads";
    documents = "${config.home.homeDirectory}/docs";
    pictures = "${config.home.homeDirectory}/media/pictures";
    videos = "${config.home.homeDirectory}/media/videos";
    music = "${config.home.homeDirectory}/media/music";

    # Note: Setting a directory to null will often "disable" it
    # or prevent it from being created.
    publicShare = null;
    templates = null;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    btop
    lazygit
    ripgrep
    scrcpy
    tree
    wl-clipboard

    hledger
    hledger-ui
    hledger-web

    android-tools
    go
    gopls
    gotools
    nodejs
    platformio

    nixfmt-rfc-style

    gh

    gcc
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.95;
      font = {
        # normal.family = "0xProto Nerd Font";
        normal.family = "Kode Mono";
        size = 12;
      };
    };
  };

  programs.bash = {
    enable = true;

    historySize = 100000;
    historyFileSize = 100000;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historyIgnore = [
      "clear"
      "pwd"
      "ls"
      "history"
      "exit"
      "cd *"
    ];

    shellOptions = [ "histappend" ];

    initExtra = ''
      export HISTTIMEFORMAT="%F %T "
      PROMPT_COMMAND='history -a'

      export NPM_CONFIG_PREFIX="$HOME/.npm-packages"
      export PATH="$HOME/.npm-packages/bin:$PATH"
      export NODE_PATH="$HOME/.npm-packages/lib/node_modules"
    '';
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      settings = {
        "app.update.auto" = false;
        "browser.startup.homepage" = "https://lobste.rs";
        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        vimium
      ];
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

  programs.noctalia = {
    enable = true;
  };

  programs.opencode = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;

    terminal = "screen-256color";
    extraConfig = ''
      set -g escape-time 0

      set -g history-limit 100000
      set -g set-clipboard on

      # Better copy mode
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

      # New Tmux Windows and Panes go to the same directory as the current pane
      bind  c  new-window      -c "#{pane_current_path}"
      bind  %  split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
    '';
  };

  programs.qutebrowser = {
    enable = true;
    extraConfig = ''
      c.colors.webpage.preferred_color_scheme = "dark"
      c.colors.webpage.darkmode.enabled = False
      c.colors.webpage.bg = "black"
    '';
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
