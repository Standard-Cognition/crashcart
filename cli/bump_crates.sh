#!/usr/bin/env bash
set -e

# Ask cargo to bump our Cargo.lock with new deps
nix run -f ../nixpkgs.nix cargo -c cargo update

# Regenerate the Cargo.nix sources
nix run -f https://github.com/kolloch/crate2nix/tarball/0.8.0  \
    -c crate2nix generate                                      \
    -n ../nixpkgs.nix                                          \
    -f ./Cargo.toml

