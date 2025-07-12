# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, username,... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # wsl.enable = true;
  # wsl.defaultUser = username;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.11";

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    vim
    wget
    docker
  ];

  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
  users.users.${username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "users";
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # wheel = sudo
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  # Setup for hardware acceleration
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    opengl.enable = true;

    firmware = with pkgs; [
      linux-firmware
    ];

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
        intel-media-driver       # VA-API iHD driver
        intel-vaapi-driver       # Optional legacy driver
        intel-compute-runtime    # Optional for tone mapping / OpenCL
        onevpl-intel-gpu         # Optional VPL runtime
        intel-gpu-tools          # For intel_gpu_top
      ];
    };
  };

  boot.kernelModules = [ "i915" ];
  boot.kernelParams = [
    "i915.enable_guc=3"
    "i915.fastboot=1"
    "i915.force_probe=46d4"   # Only necessary if your GPU is not auto-enabled
  ];

  networking.useDHCP = false;

  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.26";
      prefixLength = 24;
    }];
  };

  networking.defaultGateway = "192.168.1.1";

  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
}

