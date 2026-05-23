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

Requires an existing `podman login ghcr.io` session.

### All-in-one (single machine)

```sh
./build.sh
```

Builds both `amd64` and `arm64`, then assembles and pushes the multi-arch manifest tagged `main` and `sha-<short>`.

### Split builds (native build on each machine)

Cross-compilation is slow. Build each arch natively on the appropriate host, then assemble the manifest from either machine.

On Apple Silicon (arm64):
```sh
./build.sh arm64
```

On Linux (amd64):
```sh
./build.sh amd64
```

Once both arch images are pushed, assemble the manifest from either machine:
```sh
./build.sh manifest
```

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
