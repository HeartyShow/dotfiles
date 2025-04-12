{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    python3
    pyenv
    pyright
    ruff
    uv
  ];
}
