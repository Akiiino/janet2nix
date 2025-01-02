{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = import ./functions.nix pkgs;
      packages = import ./packages.nix {inherit pkgs lib;};
    in {
      inherit lib packages;

      checks = import ./tests/all.nix {inherit self pkgs lib packages;};

      formatter = pkgs.alejandra;
    });
}
