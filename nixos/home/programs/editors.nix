{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    neovim
    # Remove once NixOS/nixpkgs#587973 lands: upstream node_modules hash is wrong on darwin.
    (opencode.overrideAttrs (old: {
      node_modules = old.node_modules.overrideAttrs {
        outputHash = "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc=";
      };
    }))
    tuicr
    rtk
  ];
}
