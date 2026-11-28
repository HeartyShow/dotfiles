{
  pkgs,
  inputs,
  ...
}: let
  opencodePkgs = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system};
  # Upstream nix/hashes.json does not match our bun on darwin; drop once upstream's hash builds.
  opencode =
    if pkgs.stdenv.hostPlatform.isDarwin
    then
      opencodePkgs.opencode.override {
        node_modules = opencodePkgs.node_modules_updater.override {
          hash = "sha256-5ZAz0jWNhW+7zGfqOLUFFFhMUMxo76djVwixfvcMPhY=";
        };
      }
    else opencodePkgs.opencode;
in {
  environment.systemPackages = with pkgs; [
    neovim
    opencode
    tuicr
    rtk
  ];
}
