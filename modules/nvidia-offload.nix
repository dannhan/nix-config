{
  config,
  lib,
  pkgs,
  ...
}:
# PRIME render-offload config for the discrete NVIDIA GPU (GeForce MX450, Turing).
#
# The desktop stays on the Intel Iris Xe GPU; any program started via
# `nvidia-offload <cmd>` renders on the NVIDIA GPU instead. Fine-grained
# (RTD3) power management lets the dGPU drop back to sleep when nothing is
# using it, so battery/idle behaviour stays the same as today.
#
# Reverting: set `services.nvidia-offload-gaming.enable = false;` in
# configuration.nix (or drop this import) and rebuild. `nixos-rebuild
# switch` will return the machine to Mesa-only / nouveau state.
{
  options.services.nvidia-offload-gaming = {
    enable = lib.mkEnableOption ''
      NVIDIA PRIME render offload: keep the desktop on the Intel iGPU and let
      `nvidia-offload`-wrapped programs render on the disrete NVIDIA GPU.
    '';

    powerDownGpuWhenIdle = lib.mkEnableOption ''
      fine-grained power management (RTD3), so the NVIDIA GPU powers down
      when no offload program is running. Recommended; matches the
      laptop's previous idle behaviour.
    ''
    // {
      default = true;
    };
  };

  config = lib.mkIf config.services.nvidia-offload-gaming.enable {
    # `hardware.nvidia` keys off this list ("nvidia" must be present for the
    # driver module to activate); it has no effect on the graphical session
    # itself, which is niri/Wayland on the Intel GPU.
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      # Turing (incl. MX450) is supported by the open kernel modules, which the
      # NVIDIA module recommends for driver >= 560 (here: 595.104.02).
      open = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true; # provides `nvidia-offload` on PATH
        };

        intelBusId = "PCI:0@0:2:0";
        nvidiaBusId = "PCI:0@46:0:0";
      };

      # Stop nouveau claiming the GPU (also blacklisted inside the module,
      # but explicit here so this setting alone is self-documenting).
      modesetting.enable = lib.mkDefault true;
    };

    hardware.nvidia.powerManagement = {
      # Required for suspend/resume to preserve video memory.
      enable = true;
      finegrained = config.services.nvidia-offload-gaming.powerDownGpuWhenIdle;
    };

    # The NVIDIA module only autoloads these when services.xserver is
    # enabled; on a Wayland-only system they must be loaded explicitly so
    # offload can work without a headful X session.
    boot.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
    ];

    environment.systemPackages = with pkgs; [
      # Diagnostics for verifying which GPU an app actually landed on.
      mesa-demos # glxinfo/glxgears
    ];
  };
}
