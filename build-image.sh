#!/usr/bin/bash

# Convenience script for building images locally.
# Usage: ./build-image.sh <recipe.yml>

if command -v bluebuild >/dev/null 2>&1; then
    bluebuild build --build-driver=podman "$1"
else
    echo "Bluebuild is not installed — run 'cargo install bluebuild' or use the GitHub Actions workflow."
    exit 1
fi