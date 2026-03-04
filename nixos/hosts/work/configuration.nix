{ config, lib, pkgs, username, ... }: 

{
  # Nix-darwin state version
  system.stateVersion = 6;

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    git vim wget pinentry_mac
  ];

  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = "I584830";

  system.defaults = {
    loginwindow.LoginwindowText = username;
  };

  users.users.${username}.shell = pkgs.zsh;
}
