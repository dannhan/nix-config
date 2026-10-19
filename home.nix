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
    inputs.hermes-agent.homeManagerModules.default
    inputs.omp.homeManagerModules.default

    ./modules/nixvim.nix
    ./modules/ranger.nix
    ./modules/qutebrowser.nix
    ./modules/ueberzugpp.nix
    ./modules/noctalia.nix
  ];

  home.username = "ruyam";
  home.homeDirectory = "/home/ruyam";
  home.shellAliases = {
    inbox = "nvim ${config.home.homeDirectory}/docs/working/inbox.md";
  };
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.local/share/go/bin"
    "${config.home.homeDirectory}/.opencode/bin"
  ];
  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
    LEDGER_FILE = "${config.home.homeDirectory}/docs/finance/ledger.journal";
    TERMINAL = "ghostty";
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

  # Default terminal for desktop apps that honour the XDG terminal spec
  # (xdg-terminal-exec, used by file managers and launchers).
  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
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
      # Follow the wallpaper-derived palette that Noctalia writes to
      # ~/.config/alacritty/themes/noctalia.toml.
      general.import = [ "~/.config/alacritty/themes/noctalia.toml" ];
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
      # Login shell so ~/.profile is read: home-manager's sessionPath and
      # sessionVariables (GOPATH, TERMINAL, ...) only export there, and a
      # plain interactive bash never sources it.
      command = "bash -l";
      font-size = 14;
      font-family = "Kode Mono";
      background-opacity = 0.96;
      # Follow the wallpaper-derived palette that Noctalia writes to
      # ~/.config/ghostty/themes/noctalia.
      theme = "noctalia";
    };
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
