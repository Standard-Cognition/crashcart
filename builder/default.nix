{ bash, cacert, coreutils, dockerTools, gitMinimal, gnutar, gzip, iana-etc, nix, openssh, utillinux, xz }:

let
  nix' = nix.override {
    storeDir = "/dev/crashcart/store";
    stateDir = "/dev/crashcart/var";
  };
in dockerTools.buildImage {
    name = "builder";
    contents = [
      ./rootfs
      bash coreutils gitMinimal gnutar gzip iana-etc nix' openssh utillinux xz
    ];

    extraCommands = "mkdir -p tmp";

    config.Env = [
      #"USER=nobody"
      "NIX_PATH=nixpkgs=https://channels.nixos.org/nixos-20.03/nixexprs.tar.xz"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
}
