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
      testApp = lib.mkJanetPackage {
        name = "test";
        src = ./test;
        withJanetPackages = with packages; [spork sh jaylib judge];
      };
      testScript = lib.mkJanetScript {
        name = "test";
        src = builtins.toFile "main.janet" ''
          (defn main [&] (print "hello world"))
        '';
      };
    in {
      inherit lib packages;
      apps = builtins.mapAttrs (name: value: {
        type = "app";
        program = "${value}/bin/test";
      }) {inherit testApp testScript;};

      formatter = pkgs.alejandra;
    });
}
