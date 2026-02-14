#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE_NAME="${OPENCLAW_IMAGE:-openclaw:local}"
APT_PACKAGES="${OPENCLAW_DOCKER_APT_PACKAGES:-}"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)    IMAGE_NAME="$2"; shift 2 ;;
    --apt-packages) APT_PACKAGES="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Missing dependency: docker" >&2
  exit 1
fi

echo "==> Building Docker image: $IMAGE_NAME"
docker build \
  --build-arg "OPENCLAW_DOCKER_APT_PACKAGES=${APT_PACKAGES}" \
  -t "$IMAGE_NAME" \
  -f "$ROOT_DIR/Dockerfile" \
  "$ROOT_DIR"

echo "==> Build complete: $IMAGE_NAME"
