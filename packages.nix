{
  pkgs,
  lib,
}: rec {
  spork = lib.mkJanetPackage {
    name = "spork";
    src = fetchGit {
      url = "https://github.com/janet-lang/spork.git";
      rev = "08fdf9d3246db5c9aa2102bc3cb4e90e148780c0";
    };
  };
  posix-spawn = lib.mkJanetPackage {
    name = "posix-spawn";
    src = fetchGit {
      url = "https://github.com/andrewchambers/janet-posix-spawn.git";
      rev = "d73057161a8d10f27b20e69f0c1e2ceb3e145f97";
    };
  };
  sh = lib.mkJanetPackage {
    name = "sh";
    src = fetchGit {
      url = "https://github.com/andrewchambers/janet-sh.git";
      rev = "221bcc869bf998186d3c56a388c8313060bfd730";
    };
    withJanetPackages = [posix-spawn];
  };
  cmd = lib.mkJanetPackage {
    name = "cmd";
    src = fetchGit {
      url = "https://github.com/ianthehenry/cmd";
      rev = "b4308de361d0f90dd96cc0f9a8dc6881e0e851c6";
    };
  };
  judge = lib.mkJanetPackage {
    name = "judge";
    src = fetchGit {
      url = "https://github.com/ianthehenry/judge";
      rev = "a9db4af561f2bdcdc8dada35db7d8e8453262318";
    };
    withJanetPackages = [cmd];
  };
  jaylib = (lib.mkJanetPackage {
    name = "jaylib";
    src = fetchGit {
      url = "https://github.com/janet-lang/jaylib";
      rev = "4875309941972529777ef64555e73c600916e48f";
      submodules = true;
    };
    propagatedBuildInputs = with pkgs; [glfw];
  })
  .overrideAttrs {patches = [./patches/0001-jaylib-use-external-glfw.patch];};
}
