{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      function_overlay = import ./overlay/functions.nix;
      extra_packages = import ./overlay/extra-packages.nix;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          function_overlay
          extra_packages
        ];
      };
      janet2nix = pkgs.mkJanetApplication {
        name = "janet2nix";
        src = ./.;
        withJanetPackages = with pkgs.janetPackages; [spork posix-spawn sh jaylib];
        # TODO: figure out how to make this unnecessary.
        buildInputs = with pkgs; [xorg.libXrandr];
      };
    in {
      overlays = [
        function_overlay
        extra_packages
      ];
      packages = {
        janetPackages = pkgs.janetPackages;
        default = janet2nix;
      };

      devShells.default = pkgs.mkShell {
        packages = [
          (pkgs.mkJanetTree {
            name = "janet2nix-dev";
            withJanetPackages = with pkgs.janetPackages; [judge];
          })
        ];
      };
      formatter = pkgs.alejandra;
    });
}
