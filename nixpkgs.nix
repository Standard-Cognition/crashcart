{ sources ? import ./nix/sources.nix }:

let
  thisRepository = import ./overlay.nix;
  rustChannelsOverlay = import "${sources.nixpkgs-mozilla}/rust-overlay.nix";
  rustChannelsSrcOverlay = import "${sources.nixpkgs-mozilla}/rust-src-overlay.nix";

  rustOverlay = self: super:
    let channel =
      super.rustChannelOf {
        rustToolChain = "nightly-2020-04-21";
        sha256 = "1ffhardy4xqs3h49wwlbry2hgl0qjfd1kza9bsrk92xvb25yaw2x";
      };
      rustNightly = channel.rust.override {
        extensions = [
          "clippy-preview"
          "rls-preview"
          "rust-analysis"
          "rustfmt-preview"
          "rust-src"
          "rust-std"
        ];
      };
    in {
      rust = rustNightly;
      cargo = channel.rust;
      rustc = channel.rust;
    };
in
import sources.nixpkgs {
  overlays = [
      rustChannelsOverlay
      rustChannelsSrcOverlay
      rustOverlay
      thisRepository
  ];
}

