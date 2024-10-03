{
  description = "FAForever Nixos Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    #nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    srvos.url = "github:nix-community/srvos";
  };

  outputs = { self, nixpkgs, srvos }: {
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
