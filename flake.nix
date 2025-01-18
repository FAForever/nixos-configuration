{
  description = "FAForever Nixos Configs";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05-small";
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    srvos.url = "github:nix-community/srvos";
    nixpkgs.follows = "srvos/nixpkgs";
    secrets = {
      url = "git+file:secrets"; # the submodule is in the ./secrets dir
      flake = false;
    };

  };

  outputs = { self, nixpkgs, secrets, srvos }: {
    nixosConfigurations = {
      "fafprod3" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./common/configuration.nix
          ./machines/prod3/configuration.nix
          srvos.nixosModules.server
          ( import (secrets + /networking-prod2.nix))
          ( import (secrets + /users-prod.nix))
        ];
      };
      "test1" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./common/configuration.nix
          ./machines/test1/configuration.nix
          srvos.nixosModules.server
          ( import (secrets + /users-test.nix))
        ];
      };
    };
  };
}
