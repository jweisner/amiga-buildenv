#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io"
IMAGE="jweisner/amiga-buildenv"
SHA_TAG="sha-$(git rev-parse --short HEAD)"
ALL_PLATFORMS=(amd64 arm64)
MANIFEST_TAGS=("${REGISTRY}/${IMAGE}:main" "${REGISTRY}/${IMAGE}:${SHA_TAG}")

usage() {
    echo "Usage: $0 [amd64|arm64|manifest]"
    echo "  amd64|arm64  Build and push a single-arch image"
    echo "  manifest     Assemble and push the multi-arch manifest from pre-pushed arch images"
    echo "  (no arg)     Build all arches and push the manifest"
    exit 1
}

build_arch() {
    local arch=$1
    podman build \
        --platform "linux/${arch}" \
        -f Containerfile \
        -t "${REGISTRY}/${IMAGE}:main-${arch}" \
        .
    podman push "${REGISTRY}/${IMAGE}:main-${arch}"
}

push_manifest() {
    for TAG in "${MANIFEST_TAGS[@]}"; do
        podman manifest rm "${TAG}" 2>/dev/null || true
        podman manifest create "${TAG}"
        for ARCH in "${ALL_PLATFORMS[@]}"; do
            podman manifest add "${TAG}" "${REGISTRY}/${IMAGE}:main-${ARCH}"
        done
        podman manifest push --all "${TAG}"
    done

    for ARCH in "${ALL_PLATFORMS[@]}"; do
        podman rmi "${REGISTRY}/${IMAGE}:main-${ARCH}" 2>/dev/null || true
    done
}

case "${1:-all}" in
    amd64|arm64)
        build_arch "$1"
        ;;
    manifest)
        push_manifest
        ;;
    all)
        for ARCH in "${ALL_PLATFORMS[@]}"; do
            build_arch "${ARCH}"
        done
        push_manifest
        ;;
    *)
        usage
        ;;
esac
