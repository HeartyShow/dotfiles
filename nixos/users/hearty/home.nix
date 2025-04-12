{pkgs, ...}: {
  ##################################################################################################################
  #
  # All Hearty's Home Manager Configuration
  #
  ##################################################################################################################

  imports = [
    ../../home/core.nix
    ../../home/code
    ../../home/programs
    ../../home/shell
  ];

  programs.git = {
    userName = "Alexandre Vialar";
    userEmail = "alex.vialar@gmail.com";
  };
}
