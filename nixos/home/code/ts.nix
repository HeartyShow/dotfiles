{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bun
    # eslint_d
    # prettierd
  ];
}
