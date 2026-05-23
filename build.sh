#!/usr/bin/env bash
set -euo pipefail

REGISTRY="ghcr.io"
IMAGE="jweisner/amiga-buildenv"
SHA_TAG="sha-$(git rev-parse --short HEAD)"

podman build \
    -f Containerfile \
    -t "${REGISTRY}/${IMAGE}:main" \
    -t "${REGISTRY}/${IMAGE}:${SHA_TAG}" \
    .

podman push "${REGISTRY}/${IMAGE}:main"
podman push "${REGISTRY}/${IMAGE}:${SHA_TAG}"
