{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  notifyDone = pkgs.writeShellScript "hermes-notify-done" ''
    ${pkgs.libnotify}/bin/notify-send -a hermes "Hermes" "Task finished"
  '';
  notifyAsk = pkgs.writeShellScript "hermes-notify-ask" ''
    ${pkgs.libnotify}/bin/notify-send -a hermes -u critical "Hermes" "Waiting for your input"
  '';
in
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.hermes-agent.homeManagerModules.default
    inputs.omp.homeManagerModules.default

    ./modules/nixvim.nix
    ./modules/ranger.nix
    ./modules/qutebrowser.nix
    ./modules/ueberzugpp.nix
  ];

  home.username = "ruyam";
  home.homeDirectory = "/home/ruyam";
  home.shellAliases = {
    inbox = "nvim ${config.home.homeDirectory}/docs/working/inbox.md";
  };
  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
    LEDGER_FILE = "${config.home.homeDirectory}/docs/finance/ledger.journal";
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
    ffmpeg
    lazygit
    libnotify
    ranger
    ripgrep
    scrcpy
    tree
    ueberzugpp
    wl-clipboard

    hledger
    hledger-ui
    hledger-web

    libreoffice
    whatsapp-electron

    android-tools
    bun
    gcc
    go
    gopls
    gotools
    nodejs
    platformio
    python3

    nixfmt-rfc-style

    python3Packages.markitdown

    codex
  ];

  programs.hermes-agent.enable = true;

  # No gateway/backend daemon: this only merges `settings` into ~/.hermes/config.yaml
  # (deep merge, existing keys are kept).
  services.hermes-agent = {
    enable = true;
    settings = {
      hooks_auto_accept = true;
      hooks.post_llm_call = [
        {
          command = "${notifyDone}";
          timeout = 10;
        }
      ];
      # Clarify questions, command approvals, sudo prompts.
      hooks.on_human_input_request = [
        {
          command = "${notifyAsk}";
          timeout = 10;
        }
      ];
    };
  };

  programs.omp = {
    enable = true;
    settings = {
      startup.quiet = true;
      completion.notify = "on";
      ask.notify = "on";
    };
  };

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
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-size = 14;
      font-family = "Kode Mono";
      background-opacity = 0.96;
    };
  };

  programs.noctalia = {
    enable = true;
    # Whole shell config lives here (migrated from the GUI state file).
    # settings.toml in ~/.local/state/noctalia overrides this, so keep it
    # renamed/removed. Wallhaven is an official plugin: enable + widget + bar slot.
    settings = ''
      config_version = 15

      [bar.default]
      capsule = true
      center = [ "workspaces" ]
      end = [ "tray", "notifications", "clipboard", "group:g2", "volume", "battery", "brightness", "control-center", "session" ]
      font_family = "Kode Mono Medium"
      margin_edge = 8
      margin_ends = 8
      start = [ "group:g1", "wallpaper", "wallhaven", "clock", "group:g4", "media" ]
      widget_spacing = 4

          [[bar.default.capsule_group]]
          fill = "surface_variant"
          id = "g1"
          members = [ "launcher" ]
          opacity = 1.0
          padding = 6.0

          [[bar.default.capsule_group]]
          fill = "surface_variant"
          id = "g2"
          members = [ "network", "bluetooth" ]
          opacity = 1.0
          padding = 6.0

          [[bar.default.capsule_group]]
          fill = "surface_variant"
          id = "g4"
          members = [ "sysmon", "temp", "ram" ]
          opacity = 1.0
          padding = 6.0

      [brightness]
      minimum_brightness = 0.099999997764825821

      [lockscreen_widgets]
      enabled = false
      schema_version = 2
      widget_order = [ "lockscreen-login-box@HDMI-A-1", "lockscreen-login-box@eDP-1" ]

          [lockscreen_widgets.grid]
          cell_size = 16
          major_interval = 4
          visible = true

          [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-1"]
          box_height = 196.0
          box_width = 720.0
          cx = 683.0
          cy = 649.0
          output = "HDMI-A-1"
          placement_height = 1080.0
          placement_width = 1920.0
          rotation = 0.0
          type = "login_box"

              [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-1".settings]
              background_color = "surface_variant"
              background_opacity = 0.88
              background_radius = 12.0
              center_password_text = false
              input_opacity = 1.0
              input_radius = 6.0
              layout = "regular"
              show_caps_lock = true
              show_keyboard_layout = true
              show_login_button = true
              show_media = true
              show_session_buttons = true
              show_unlock_hint = true
              show_weather = true

          [lockscreen_widgets.widget."lockscreen-login-box@eDP-1"]
          box_height = 196.0
          box_width = 720.0
          cx = 768.0
          cy = 745.0
          output = "eDP-1"
          placement_height = 864.0
          placement_width = 1536.0
          rotation = 0.0
          type = "login_box"

              [lockscreen_widgets.widget."lockscreen-login-box@eDP-1".settings]
              background_color = "surface_variant"
              background_opacity = 0.88
              background_radius = 12.0
              center_password_text = false
              input_opacity = 1.0
              input_radius = 6.0
              layout = "regular"
              show_caps_lock = true
              show_keyboard_layout = true
              show_login_button = true
              show_media = true
              show_session_buttons = true
              show_unlock_hint = true
              show_weather = true

      [nightlight]
      enabled = true

      [plugins]
      enabled = [ "noctalia/timer", "noctalia/bongocat", "noctalia/wallhaven" ]

      [shell]
      app_icon_color = "shadow"
      avatar_path = "/home/ruyam/media/pictures/Screenshots/Screenshot from 2026-06-11 11-46-14.png"
      font_family = "JetBrains Mono"
      settings_show_advanced = false

      [theme]
      builtin = "Eldritch"
      community_palette = "Catppuccin Frappe Lavender"
      custom_palette = "go-if-err-light-wallpaper-1-mc"
      mode = "light"
      source = "wallpaper"
      wallpaper_scheme = "m3-tonal-spot"

          [theme.templates]
          builtin_ids = [
              "btop",
              "cava",
              "emacs",
              "foot",
              "gtk3",
              "gtk4",
              "ghostty",
              "helix",
              "kcolorscheme",
              "kitty",
              "labwc",
              "mango",
              "niri",
              "qt",
              "scroll",
              "starship",
              "sway",
              "wezterm"
          ]
          enable_builtin_templates = false

      [wallpaper]
      directory = "/home/ruyam/media/pictures/Wallpapers"
      transition_on_startup = true

          [wallpaper.default]
          path = "/home/ruyam/media/pictures/Wallpapers/wallhaven_1pj2d1.jpg"


      [widget.wallhaven]
      type = "noctalia/wallhaven:wallhaven"

      [widget.media]
      max_length = 100
      title_scroll = "on_hover"
    '';
  };

  programs.opencode = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;

    terminal = "tmux-256color";
    extraConfig = ''
      set -g escape-time 0
      set -ga terminal-overrides ",*:Tc"

      set -g history-limit 100000
      set -g set-clipboard on

      set -g allow-passthrough on

      # Better copy mode
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

      # New Tmux Windows and Panes go to the same directory as the current pane
      bind  c  new-window      -c "#{pane_current_path}"
      bind  %  split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
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
