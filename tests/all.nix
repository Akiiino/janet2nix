{
  self,
  pkgs,
  lib,
  packages,
}:
with lib; let
  lib = pkgs.lib;
  inherit (builtins) toFile map listToAttrs;

  # Take attrset of (string) file name to (string) contents and create a src
  # directory with those files in it.
  mkSrc = args: let
    files = lib.attrsToList (builtins.mapAttrs toFile args);
    cpFile = {
      name,
      value,
    }: "cp ${value} $out/${name}\n";
  in
    pkgs.runCommandLocal "test-src" {} ''
      mkdir -p $out
      ${lib.concatMapStrings cpFile files}'';

  # Build a source derivation for a janet module with name and a single file
  # with contents.
  moduleSrc = name: contents:
    mkSrc {
      "project.janet" = ''
        (declare-project :name "${name}" :dependencies [])
        (declare-source :source "${name}.janet")
      '';
      "${name}.janet" = contents;
    };

  # Packages which, if successfully built, put an executable that prints
  # SUCCESS with their package name in the PATH which.
  tests = {
    all-pkgs = mkJanetScript {
      name = "all-pkgs";
      withJanetPackages = with packages; [judge sh spork jaylib];
      src = toFile "main.janet" ''
        (use jaylib)
        (use judge)
        (use spork/math)
        (use sh)
        (defn main [&] ($ echo "SUCCESS"))
      '';
    };
    binscript = mkJanetPackage {
      name = "binscript";
      src = mkSrc {
        "project.janet" = ''
          (declare-project :name "binscript" :dependencies [])
          (declare-binscript :main "binscript")
        '';
        "binscript" = "#!/usr/bin/env janet\n(print \"SUCCESS\")";
      };
    };
    hardcode-syspath = mkJanetPackage {
      name = "hardcode-syspath";
      src = mkSrc {
        "project.janet" = ''
          (declare-project :name "hardcode-syspath" :dependencies [])
          (declare-binscript :main "hardcode-syspath" :hardcode-syspath)
        '';
        "hardcode-syspath" = "#!/usr/bin/env janet\n(print \"SUCCESS\")";
      };
    };
    judgeDep = let
      # A judge built anywhere in the dependency tree should be able to test
      # files (anywhere) that import any dependency in the tree.
      depWithJudge = mkJanetPackage rec {
        name = "dep-with-judge";
        withJanetPackages = with packages; [judge];
        src = moduleSrc name ''(def name "dep-with-judge")'';
      };
      depNoJudge = mkJanetPackage rec {
        name = "dep-no-judge";
        src = moduleSrc name ''(def result "SUCCESS")'';
      };
      fileToTest = toFile "test.janet" ''
        (use judge)
        (import dep-with-judge)
        (import dep-no-judge)
        (test dep-with-judge/name "dep-with-judge")
        (test dep-no-judge/result "SUCCESS")
      '';
    in
      mkJanetScript {
        name = "client-pkg";
        withJanetPackages = with packages; [sh depWithJudge depNoJudge];
        src = toFile "main.janet" ''
          (use sh)
          (import dep-no-judge)
          (defn main [&]
            ($ judge ${fileToTest})
            ($ echo ,dep-no-judge/result))
        '';
      };
    propagates-inputs = let
      depWithJaylib = mkJanetPackage rec {
        name = "dep-with-jaylib";
        withJanetPackages = with packages; [jaylib spork];
        src = moduleSrc name ''(print "loading ${name}")'';
      };
      intermediate = mkJanetPackage rec {
        name = "intermediate";
        withJanetPackages = with packages; [depWithJaylib];
        src = moduleSrc name ''(print "loading ${name}")'';
      };
    in
      mkJanetScript {
        name = "propagates-inputs";
        withJanetPackages = with packages; [intermediate];
        src = toFile "main.janet" ''(defn main[&] (print "SUCCESS"))'';
      };
  };

  testsRun = lib.flip lib.attrsets.concatMapAttrs tests (name: p: {
    "${name}" = p;
    "test-${name}-runs" =
      pkgs.runCommandLocal name {nativeBuildInputs = [p];}
      ''${p.name} | grep "SUCCESS" > $out'';
  });
in
  testsRun
  // {
    jaylib-demo = mkJanetScript {
      name = "jaylib-demo";
      withJanetPackages = with packages; [jaylib];
      src = toFile "main.janet" ''
        (use jaylib)

        (defn main [& args]
          (when ((os/environ) "DISPLAY")
            (init-window 800 600 "Jaylib Demo")
            (set-target-fps 60)
            (while (not (window-should-close))
              (begin-drawing)
              (clear-background :black)
              (draw-text "Hello World" 190 200 20 :white)
              (end-drawing))
            (close-window)))
      '';
    };
    conflictingDep = let
      # This currently resolves the conflict by arbitrarily picking one.
      # TODO: it should probably error.
      depv1 = mkJanetPackage rec {
        name = "dep";
        src = moduleSrc name ''(def v 1)'';
      };
      depv2 = mkJanetPackage rec {
        name = "dep";
        src = moduleSrc name ''(def v 2)'';
      };
    in
      mkJanetScript {
        name = "conflicting-deps";
        withJanetPackages = [depv1 depv2];
        src = toFile "main.janet" ''
          (import dep)
          (defn main [&] (print "SUCCESS" dep/v))
        '';
      };
  }
