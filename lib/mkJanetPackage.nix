{
  lib,
  stdenv,
  pkgs,
  name,
  src,
  propagatedBuildInputs ? [],
  withJanetPackages ? [],
}: let
  jpmTree = pkgs.symlinkJoin {
    name = "jpm_tree";
    paths = withJanetPackages;
  };
in
  stdenv.mkDerivation {
    inherit name src;
    propagatedBuildInputs = propagatedBuildInputs ++ [pkgs.janet];
    # TODO: We probably need to allow the caller to add entries to both these
    # lists, but I'm waiting until I have an example to support it.
    nativeBuildInputs = [pkgs.jpm];
    buildInputs = withJanetPackages;
    buildPhase = ''
      set -o xtrace

      if [[ -d ${jpmTree}/jpm_tree ]]; then
        cp -r ${jpmTree}/jpm_tree .
        chmod +w -R jpm_tree
      fi
      jpm install -l --headerpath=${pkgs.janet}/include --libpath=${pkgs.janet}/lib
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp -r ./jpm_tree $out/
      for file in $out/jpm_tree/bin/*; do
        if isScript $file; then
          # We support :hardcode-syspath like this:
          # Any binary we built will have $(pwd)/jpm_tree. Replace the version
          # in jpm_tree/bin with @syspath@/jpm_tree.  Copy all binaries in
          # jpm_tree/bin (including those from our dependencies) to $out/bin
          # replacing @syspath@ with our complete jpm_tree.
          if [[ ! -L $file ]]; then
            substituteInPlace $file --replace-quiet $(pwd)/jpm_tree @syspath@/jpm_tree
          fi
          dest=$out/bin/$(basename $file)
          substitute $file $dest --replace-quiet @syspath@/jpm_tree $out/jpm_tree
          chmod +x $dest
        else
          cp $file $out/bin/
        fi
      done
    '';
  }
