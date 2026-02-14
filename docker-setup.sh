#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================"
echo "  DEPRECATED: docker-setup.sh"
echo "  Use docker-build.sh and docker-start.sh instead."
echo "  This wrapper will be removed in a future release."
echo "========================================================"
echo ""

"$ROOT_DIR/docker-build.sh" "$@"
"$ROOT_DIR/docker-start.sh"
