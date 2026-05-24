#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io"
IMAGE="jweisner/amiga-buildenv"
SHA_TAG="sha-$(git rev-parse --short HEAD)"
ALL_PLATFORMS=(amd64 arm64)
MANIFEST_TAGS=("${REGISTRY}/${IMAGE}:main" "${REGISTRY}/${IMAGE}:${SHA_TAG}")
if [[ -n "${VERSION_TAG:-}" ]]; then
    MANIFEST_TAGS+=("${REGISTRY}/${IMAGE}:${VERSION_TAG}")
    MANIFEST_TAGS+=("${REGISTRY}/${IMAGE}:latest")
fi

LOCAL_ARCH="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"

usage() {
    echo "Usage: $0 [amd64|arm64|all|manifest]"
    echo "  amd64|arm64  Build and push a single-arch image"
    echo "  all          Build all arches and push the manifest"
    echo "  manifest     Assemble and push the multi-arch manifest from pre-pushed arch images"
    echo "  (no arg)     Build and push the local arch only (${LOCAL_ARCH})"
    echo ""
    echo "  VERSION_TAG=v1.2.3 $0  Also tag the manifest with a version and :latest"
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

case "${1:-local}" in
    amd64|arm64)
        build_arch "$1"
        ;;
    local)
        build_arch "${LOCAL_ARCH}"
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
