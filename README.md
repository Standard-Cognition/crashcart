# `crashcart` - microcontainer debugging tool #

![crashcart](https://github.com/oracle/crashcart/raw/master/crashcart.png
"crashcart")

## What is `crashcart`? ##

`crashcart` is a simple command line utility that lets you sideload an image
with linux binaries into an existing container.

## Building `crashcart` ##

Building can be done via nix:

    nix build -f ./nixpkgs.nix crashcart

To put crashcart on path:

    nix run -f ./nixpkgs.nix crashcart

## Building `crashcart.img` ##

Image build dependencies:

    sudo
    nix
    docker

`crashcart` will load binaries from an image file into a running container. To
build the image, you just need docker installed and then you can use
`build_image.sh`:

    build_image.sh

The build image script will build a `crashcart_builder` image using the
nix image defined in the builder directory. It will then run this builder as a
privileged container. It needs to be privileged because the image is created by
loopback mounting an ext3 filesystem and copying files in. It may be possible
to do this without root privileges using something like e2tools, but this has
yet to be tested.

The `crashcart_builder` will take a very long time the first time it is run.
The relocated binaries are built from source via the nix package manager. To prevent
binary collisions, the toolchain is built under a non standard prefix. As a result
nix cannot exploit any upstream build caches. Later builds should go much more quickly
because the nix store is cached in a in the vol directory and bind mounted into the builder.

To add to the list of packages in the resulting image, simply extend the buildEnv in `vol/tools.nix`.

## Using `crashcart` ##

To run a command from the `crashcart` image, pass the full path:

    sudo ./crashcart $PID /dev/crashcart/bin/tcpdump

Where PID is the process ID of the container. You can retrieve the PID by running
docker inspect -f "{{.State.Pid}}" <id of running container>`

## Manually Running Binaries from the `crashcart` Image ##

To manually mount the `crashcart` image into a container, use the -m flag.

    sudo ./crashcart -m $PID

To manually unmount the `crashcart` image from a container, use the -u flag.

    sudo ./crashcart -u $PID

Once you have manually mounted the image, you can use `docker exec` or
`nsenter` to run things inside the container.  `crashcart` locates its binaries
in `/dev/crashcart/bin` or `/dev/crashcart/sbin`. To execute
`tcpdump` for example, you can use (assuming you have added it to the `buildEnv`):

    docker exec -it $CONTAINER_ID /dev/crashcart/bin/tcpdump

`crashcart` leaves the image mounted as a loopback device. If there are no
containers still using the `crashcart` image, you can remove the device as
follows:

    sudo losetup -d `readlink crashcart.img.lnk`; sudo rm crashcart.img.lnk

## Known Issues ##

`crashcart` doesn't work with user namespaces prior to kernel 4.8. In earlier
versions of the kernel, when you attempt to mount a device inside a mount
namespace that is a child of a user namespace, the kernel returns EPERM. The
logic was changed in 4.8 so that it is possible as long as the caller of mount
is in the init userns.

## License ##

`crashcart` is dual licensed under the Universal Permissive License 1.0 and the
Apache License 2.0.

See [LICENSE](LICENSE.txt) for more details.
