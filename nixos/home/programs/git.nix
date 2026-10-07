{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    delta
    gh
    gh-dash
    git
    lazygit
  ];
}
