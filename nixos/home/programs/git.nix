{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    lazygit
  ];

  programs.git = {
    enable = true;
  };
}
