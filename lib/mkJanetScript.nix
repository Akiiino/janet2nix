{
  pkgs,
  stdenvNoCC,
  src,
  name,
  mkJanetPackage,
  withJanetPackages ? [],
}: let
  janetProject = builtins.toFile "project.janet" ''
    (declare-project :name "${name}" :dependencies [])

    (declare-executable :name "${name}" :entry "main.janet" :install true)
  '';
in
  mkJanetPackage {
    inherit name withJanetPackages;
    src = pkgs.runCommand "${name}-src" {} ''
      if [[ -d ${src} ]]; then
        cp -r ${src} $out
        chmod +w -R $out
      else
        mkdir -p $out
        cp ${src} $out/main.janet
      fi

      cp ${janetProject} $out/project.janet
    '';
  }
