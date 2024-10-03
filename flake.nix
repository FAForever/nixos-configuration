{
  description = "FAForever Nixos Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    srvos.url = "github:nix-community/srvos";
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
          ./machines/prod3/configuration.nix
        ];
      };
    };
  };
}
