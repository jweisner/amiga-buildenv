#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io"
IMAGE="jweisner/amiga-buildenv"
SHA_TAG="sha-$(git rev-parse --short HEAD)"
LOCAL_ARCH="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"

TAGS=("${REGISTRY}/${IMAGE}:main" "${REGISTRY}/${IMAGE}:${SHA_TAG}")
if [[ -n "${VERSION_TAG:-}" ]]; then
    TAGS+=("${REGISTRY}/${IMAGE}:${VERSION_TAG}")
    TAGS+=("${REGISTRY}/${IMAGE}:latest")
fi

build_and_push() {
    local arch=$1
    local primary_tag="${REGISTRY}/${IMAGE}:main"

    podman build \
        --platform "linux/${arch}" \
        -f Containerfile \
        -t "${primary_tag}" \
        .

    for TAG in "${TAGS[@]}"; do
        podman tag "${primary_tag}" "${TAG}"
        podman push "${TAG}"
    done
}

build_and_push "${LOCAL_ARCH}"
