let
  pkgs = import <nixpkgs> {};
in
  pkgs.buildEnv {
    name = "toolkit";
    paths = with pkgs; [
      busybox
    ];
  }
