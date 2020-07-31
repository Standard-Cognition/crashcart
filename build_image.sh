#!/usr/bin/env bash
set -euo pipefail

builderTar=$(nix-build ./nixpkgs.nix -A builder)
dockerOut=$(docker load -i $builderTar)
image=$(echo $dockerOut | sed 's|Loaded image: ||')

echo $image

docker run --privileged --rm -i               \
    -v "${PWD}"/vol:/dev/crashcart            \
    $image /dev/crashcart/build_crashcart.sh

mv -f vol/crashcart.img .
