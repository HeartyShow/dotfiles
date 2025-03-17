{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Dotfiles
    stow

    # Utils
    bat
    zoxide
    eza
    fzf
    ripgrep
    fd
    gcc
    gnumake
    zip
    unzip

    docker

    nodejs
    python3
    lua

    # Nvim
    luajitPackages.luarocks
  ];

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      # Language server packages (executables)
      sumneko-lua-language-server
      rust-analyzer
      pyright
    ];
  };
}
