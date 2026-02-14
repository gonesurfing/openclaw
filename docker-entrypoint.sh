#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="/home/node/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
WORKSPACE_DIR="$CONFIG_DIR/workspace"

GATEWAY_BIND="${OPENCLAW_GATEWAY_BIND:-lan}"

# ── Reset support ───────────────────────────────────────────────
RESET_FLAG=""
if [[ "${OPENCLAW_RESET:-}" == "1" ]]; then
  echo "[entrypoint] OPENCLAW_RESET=1 — forcing re-onboarding" >&2
  RESET_FLAG="--reset"
fi

# ── First-run detection ────────────────────────────────────────
if [[ -n "$RESET_FLAG" ]] || [[ ! -f "$CONFIG_FILE" ]]; then
  if [[ -z "$RESET_FLAG" ]]; then
    echo "[entrypoint] No config found at $CONFIG_FILE — running first-time onboarding" >&2
  fi

  # Generate a gateway token if one wasn't provided via env var
  if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ]]; then
    OPENCLAW_GATEWAY_TOKEN="$(node -e "process.stdout.write(require('crypto').randomBytes(32).toString('hex'))")"
    echo "[entrypoint] Generated gateway token: $OPENCLAW_GATEWAY_TOKEN" >&2
  else
    echo "[entrypoint] Using provided OPENCLAW_GATEWAY_TOKEN" >&2
  fi

  mkdir -p "$WORKSPACE_DIR"

  node dist/index.js onboard \
    --non-interactive \
    --accept-risk \
    --auth-choice skip \
    --gateway-bind "$GATEWAY_BIND" \
    --gateway-auth token \
    --gateway-token "$OPENCLAW_GATEWAY_TOKEN" \
    --skip-channels \
    --skip-skills \
    --skip-health \
    --skip-ui \
    --no-install-daemon \
    --workspace "$WORKSPACE_DIR" \
    $RESET_FLAG

  echo "[entrypoint] Onboarding complete" >&2
else
  echo "[entrypoint] Config exists at $CONFIG_FILE — skipping onboarding" >&2
fi

# Hand off to CMD (gateway process replaces this shell)
exec "$@"
