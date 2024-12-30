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
      testApp = lib.mkJanetApplication {
        name = "test";
        src = ./test;
        withJanetPackages = with packages; [spork posix-spawn sh jaylib];
        # TODO: figure out how to make this unnecessary.
        buildInputs = with pkgs; [xorg.libXrandr];
      };
      testScript = lib.mkJanetScript {
        name = "test";
        src = pkgs.writeTextDir "./test.janet" ''
          (defn main [&] (print "hello world"))
        '';
        # TODO: figure out how to make this unnecessary.
        withJanetPackages = with packages; [sh];
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
