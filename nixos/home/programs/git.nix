{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    lazygit
    delta
  ];

  programs.git = {
    enable = true;
    userName = "HeartyShow";
    userEmail = "alex.vialar@gmail.com";
  };
}
