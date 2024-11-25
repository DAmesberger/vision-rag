{ pkgs, lib, config, inputs, ... }:
let
  system_versions = pkgs.writeShellScriptBin "get-versions" ''
    echo "CUDA_VERSION=$(nvidia-smi | grep "CUDA Version" | awk '{print $9}')"
    echo "DRIVER_VERSION=$(nvidia-smi | grep "Driver Version" | awk '{print $6}')"
  '';
in {
packages = [ pkgs.git 
    pkgs.cudatoolkit
    pkgs.cudaPackages.cuda_nvcc
    pkgs.cudaPackages.cuda_cudart
    pkgs.cudaPackages.libnvjitlink
    pkgs.gcc-unwrapped
    pkgs.poppler_utils
    pkgs.stdenv.cc.cc.lib
  ];
  
  env = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.cudaPackages.cuda_cudart}/lib:${pkgs.cudaPackages.libnvjitlink}/lib";
    CUDA_PATH = "${pkgs.cudatoolkit}";
  };

  # https://devenv.sh/languages/
  # languages.rust.enable = true;
  languages = {
    python = {
      enable = true;
      venv = {
        enable = true;
        requirements = ./requirements.txt;
      };
    };
  };
  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    echo "CUDA versions:"
    echo "cuda_nvcc: ${pkgs.cudaPackages.cuda_nvcc.version}"
    echo "cuda_cudart: ${pkgs.cudaPackages.cuda_cudart.version}"
    #echo "libcusparse: ${pkgs.cudaPackages.libcusparse.version}"
    echo "libnvjitlink: ${pkgs.cudaPackages.libnvjitlink.version}"
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
