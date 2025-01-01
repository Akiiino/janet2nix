{pkgs, ...}: let
  callPackage = pkgs.lib.callPackageWith (pkgs // functions);
  functions = {
    mkJanetPackage = callPackage ./lib/mkJanetPackage.nix;
    mkJanetScript = callPackage ./lib/mkJanetScript.nix;
  };
in
  functions
