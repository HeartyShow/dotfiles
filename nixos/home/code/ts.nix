{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bun
    fnm
    # eslint_d
    # prettierd
  ];
}
