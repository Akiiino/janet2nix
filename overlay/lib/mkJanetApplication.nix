{
  lib,
  stdenv,
  pkgs,
  name,
  src,
  buildInputs ? [],
  propagatedBuildInputs ? [],
  withJanetPackages ? []
}:
let
  janetEnv = pkgs.mkJanetTree {
    name = lib.strings.concatStrings [name "-dev"];
    withJanetPackages = withJanetPackages;
  };
in

stdenv.mkDerivation {
  inherit name src;
  nativeBuildInputs = [
    janetEnv
    pkgs.makeWrapper
  ];
  buildInputs = buildInputs ++ [
    janetEnv
    pkgs.makeWrapper
  ];
  buildPhase = ''
    set -o xtrace
    jpm build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/* $out/bin
    wrapProgram $out/bin/${name} \
        --prefix PATH : ${lib.makeBinPath propagatedBuildInputs}
  '';
}
