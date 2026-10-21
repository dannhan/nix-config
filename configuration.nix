# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  # Keep only the 5 newest generations' kernels/initrds on the 296M ESP.
  # Without a limit the installer keeps every generation and /boot fills up.
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager = {
      enable = true;
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "ter-v32n";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
    packages = with pkgs; [ terminus_font ];
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account.
  users.users.ruyam = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
      # "docker"
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-runtime"
      "steam-run"
      "steam-unwrapped"
    ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    git
    tmux

    home-manager
    # niri is not listed here: `programs.niri` below installs the wrapped
    # package. Adding plain `pkgs.niri` too would put a second, unwrapped
    # `bin/niri-session` in the system profile.
    xwayland-satellite
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    kode-mono
    jetbrains-mono

    nerd-fonts._0xproto
  ];

  programs.niri.enable = true;
  # niri's session script runs `systemctl --user import-environment` with no
  # variable list. systemd >= 256 deprecates that and writes
  # "Calling import-environment without a list of variable names is deprecated."
  # straight to the raw VT on every login, flashing over the greeter hand-off
  # (upstream niri-wm/niri#254, still open). Wrap the package to pass the names
  # explicitly, the same way niri-session's own dinit branch does, so the whole
  # login-manager environment still reaches the systemd user manager.
  #
  # symlinkJoin, not overrideAttrs: only the tiny niri-session shell script
  # changes, so niri itself is not rebuilt. providedSessions is preserved
  # because `services.displayManager.sessionPackages` requires it and the
  # default session is validated against it.
  programs.niri.package =
    let
      niri = pkgs.niri;
      importLoginEnvironment = lib.escapeShellArg (
        "awk 'BEGIN{for(v in ENVIRON) if (v != \"AWKPATH\" && v != \"AWKLIBPATH\") print v}' 2>/dev/null"
        + " | xargs -r systemctl --user import-environment"
      );
    in
    pkgs.symlinkJoin {
      pname = "${niri.pname}-session-env";
      inherit (niri) version;
      paths = [ niri ];
      passthru = niri.passthru // {
        unwrapped = niri;
      };
      postBuild = ''
        rm "$out/bin/niri-session"
        cp -p "${niri}/bin/niri-session" "$out/bin/niri-session"
        substituteInPlace "$out/bin/niri-session" \
          --replace-fail 'systemctl --user import-environment' ${importLoginEnvironment}
      '';
    };
  programs.nix-ld.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  # AppImages (e.g. `pane`) self-mount via libfuse.so.2, which outside the
  # Nix store is nowhere a bare binary can dlopen() it. `enable` installs
  # appimage-run (an FHS env that does provide libfuse) and programs.fuse
  # (SUID fusermount wrappers + /etc/fuse.conf); `binfmt` registers
  # appimage-run as a kernel interpreter matched on AppImage magic bytes, so
  # executing an AppImage directly is transparently rerun inside that env
  # instead of its own runtime dying on the missing libfuse.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    # openssh.enable = true;

    # Enable power-profile
    power-profiles-daemon.enable = true;

    # Enable battery monitoring
    upower.enable = true;

    # Wayland login screen: Noctalia Greeter (greetd-based), replacing SDDM.
    # The module installs the greeter and enables greetd, Polkit and
    # AccountsService. Do NOT enable another display manager (e.g. SDDM)
    # alongside it, or both will fight over the login screen.
    displayManager.noctalia-greeter = {
      enable = true;
      # Allow this user to push the session's appearance (wallpaper, palette,
      # theme, font, layout) to the greeter without an admin prompt. Then use
      # Noctalia: Settings -> Security -> Noctalia Greeter -> Sync Now.
      passwordlessSyncUsers = [ "ruyam" ];
      settings = {
        cursor.size = 24;
        keyboard.layout = "us";
      };
    };
  };

  # Enable docker
  # virtualisation.docker.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
