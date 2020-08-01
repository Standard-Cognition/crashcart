#!/bin/nix-shell
#! nix-shell -i bash -p coreutils e2fsprogs

pushd /dev/crashcart

# Clean up any stale image that might exist
rm -rf crashcart.img

# Build an empty filesystem
truncate -s 1G crashcart.img
mkfs.ext3 crashcart.img

# Mount the filesystem
mkdir -p out
mount -t ext2 -o loop crashcart.img out

# Build the requested debug tools
tools=$(nix-build ./tools.nix -o tools)

# Place the resulting binaries on path; bin sbin
ln -s $tools out/profile
ln -s $tools/bin out/bin
ln -s $tools/sbin out/sbin

# Copy the requisite nix store paths into the image
mkdir -p out/store
for dep in $(nix-store -qR tools); do
  cp -a "${dep#/dev/crashcart/*}" out/store/
done

# Cleanup by umounting the filesystem and verifying the image
umount out
rm -rf out

# Fail if the image has any errors
set +e
e2fsck -f crashcart.img
set -e
resize2fs -M crashcart.img
