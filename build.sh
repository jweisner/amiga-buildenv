#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io"
IMAGE="jweisner/amiga-buildenv"
SHA_TAG="sha-$(git rev-parse --short HEAD)"
PLATFORMS=(amd64 arm64)
MANIFEST_TAGS=("${REGISTRY}/${IMAGE}:main" "${REGISTRY}/${IMAGE}:${SHA_TAG}")

# Build per-arch images
for ARCH in "${PLATFORMS[@]}"; do
    podman build \
        --platform "linux/${ARCH}" \
        -f Containerfile \
        -t "${REGISTRY}/${IMAGE}:main-${ARCH}" \
        .
done

# Create and push multi-arch manifests
for TAG in "${MANIFEST_TAGS[@]}"; do
    podman manifest rm "${TAG}" 2>/dev/null || true
    podman manifest create "${TAG}"
    for ARCH in "${PLATFORMS[@]}"; do
        podman manifest add "${TAG}" "${REGISTRY}/${IMAGE}:main-${ARCH}"
    done
    podman manifest push --all "${TAG}"
done

# Clean up per-arch tags
for ARCH in "${PLATFORMS[@]}"; do
    podman rmi "${REGISTRY}/${IMAGE}:main-${ARCH}" 2>/dev/null || true
done
