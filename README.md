# amiga-buildenv

A containerized Amiga cross-compilation environment built on Debian Bookworm slim, using the [bebbo/amiga-gcc](https://codeberg.org/bebbo/amiga-gcc) toolchain.

## What it does

Builds a two-stage container image:

1. **Builder stage** compiles the amiga-gcc toolchain (m68k-amigaos GCC, binutils, libnix, NDK 3.2) from source
2. **Runtime stage** copies only the compiled toolchain into a lean Debian image

The result is a ready-to-use m68k cross-compiler accessible via `/opt/amiga/bin`, with `PATH` pre-configured.

## Pre-built image

```sh
podman pull ghcr.io/jweisner/amiga-buildenv:main
```

## Building and publishing

The image is built and pushed to GHCR locally. Requires an existing `podman login ghcr.io` session.

```sh
./build.sh
```

This builds the image, tags it as `main` and `sha-<short>`, and pushes both tags to GHCR.

## Usage

Run an interactive shell with your project mounted:

```sh
podman run --rm -it -v $(pwd):/work ghcr.io/jweisner/amiga-buildenv:main
```

Inside the container, the full amiga-gcc toolchain is on `PATH`:

```sh
m68k-amigaos-gcc --version
```

## License

Apache 2.0 — see [LICENSE](LICENSE).
