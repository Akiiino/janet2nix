{
  pkgs,
  stdenvNoCC,
  src,
  name,
  mkJanetApplication,
  withJanetPackages ? [],
  propagatedBuildInputs ? [],
}: let
  janetProject = builtins.toFile "project.janet" ''
    (declare-project :name "${name}" :dependencies [])

    (declare-executable :name "${name}" :entry "${name}.janet" :install true)
  '';
  appSrc = stdenvNoCC.mkDerivation {
    inherit src;
    name = "${name}-src";
    buildPhase = ''
      cp ${janetProject} project.janet
    '';
    installPhase = ''
      cp -r . $out
    '';
  };
in
  (mkJanetApplication {
    inherit name propagatedBuildInputs withJanetPackages;
    src = appSrc;
  })
  .overrideAttrs {inherit propagatedBuildInputs;}
