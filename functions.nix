{pkgs, ...}: let
  callPackage = pkgs.lib.callPackageWith (pkgs // functions);
  functions = {
    mkJanetPackage = callPackage ./lib/mkJanetPackage.nix;
    mkJanetApplication = callPackage ./lib/mkJanetApplication.nix;
    mkJanetTree = callPackage ./lib/mkJanetTree.nix;
    mkJanetScript = callPackage ./lib/mkJanetScript.nix;
  };
in
  functions
