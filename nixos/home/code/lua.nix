{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    lua
    stylua
    lua-language-server
    luajitPackages.luarocks
  ];
}
