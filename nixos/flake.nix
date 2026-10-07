{
  description = "Hearty's NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, nix-darwin, ... }@inputs: 
  let
    username = "hearty";
    specialArgs = { inherit inputs username; };

  in {
    nixosConfigurations = {
      "media-server" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          ./hosts/media-server/configuration.nix
          ./hosts/media-server/home.nix
        ];
      };

      "wsl" = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.wsl
          ./hosts/wsl/configuration.nix
          ./hosts/wsl/home.nix
        ];
      };
    };

    darwinConfigurations = {
      "work" = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        system = "aarch64-darwin";

        modules = [
          {
            nix.enable = false;
            nixpkgs.config.allowUnfree = true;
          }
          ({ pkgs, ... }: {
            environment.systemPackages = with pkgs; [
              databricks-cli
            ];
          })
          ./darwin
          ./hosts/work/configuration.nix
          ./hosts/work/homebrew.nix
          ./home/code
          ./home/code/java.nix
          ./home/programs/docker.nix
          ./home/programs/commons.nix
          ./home/programs/editors.nix
          ./home/programs/git.nix
          ./home/shell/shells.nix
        ];
      };
    };
  };
}
