{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nodejs
    eslint_d
    prettierd
  ];
}
