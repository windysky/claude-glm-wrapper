#!/bin/bash
# smoke_test_models.sh
#
# Read-only probe of candidate Z.ai GLM model IDs against the Anthropic-compatible
# endpoint. Prints PASS/FAIL per model with the HTTP status and a truncated error
# body on failure. Does NOT create, modify, or delete any wrappers, aliases, or
# configuration files.
#
# Usage:
#   bash smoke_test_models.sh                 # auto-detect API key
#   ZAI_API_KEY=sk-... bash smoke_test_models.sh
#   bash smoke_test_models.sh --key sk-...
#   bash smoke_test_models.sh --models glm-5.1,glm-4.7  # override list
#
# Requires: curl. Optional: jq (nicer error snippets if present).

set -u

USER_BIN_DIR="$HOME/.local/bin"
ENDPOINT="${ZAI_ENDPOINT:-https://api.z.ai/api/anthropic/v1/messages}"
ANTHROPIC_VERSION="2023-06-01"
TIMEOUT_SECONDS=15

# Candidate models to probe. Override with --models a,b,c.
DEFAULT_MODELS=(
    "glm-5.1"
    "glm-5"
    "glm-5-turbo"
    "glm-4.7"
    "glm-4.7-flashx"
    "glm-4.6"
    "glm-4.5"
    "glm-4.5v"
    "glm-4.5-air"
)

# ---- Arg parsing ----
KEY_ARG=""
MODELS_OVERRIDE=""
while [ $# -gt 0 ]; do
    case "$1" in
        --key)
            KEY_ARG="$2"; shift 2 ;;
        --models)
            MODELS_OVERRIDE="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,20p' "$0"; exit 0 ;;
        *)
            echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

# ---- API key detection (same order as install.sh) ----
detect_key() {
    local candidate=""

    # 1. Explicit --key flag
    if [ -n "$KEY_ARG" ]; then
        printf '%s' "$KEY_ARG"; return 0
    fi

    # 2. Env var
    if [ -n "${ZAI_API_KEY:-}" ] && [ "$ZAI_API_KEY" != "YOUR_ZAI_API_KEY_HERE" ]; then
        printf '%s' "$ZAI_API_KEY"; return 0
    fi

    # 3. Existing wrapper scripts
    local wrapper_files=(
        "$USER_BIN_DIR/claude-glm-5.1"
        "$USER_BIN_DIR/claude-glm-5"
        "$USER_BIN_DIR/claude-glm-4.7"
        "$USER_BIN_DIR/claude-glm-4.6"
        "$USER_BIN_DIR/claude-glm-4.5"
        "$USER_BIN_DIR/claude-glm-fast"
    )
    for f in "${wrapper_files[@]}"; do
        if [ -f "$f" ]; then
            candidate=$(sed -n 's/^export ANTHROPIC_AUTH_TOKEN="\([^"]*\)".*/\1/p' "$f" | head -n 1)
            if [ -n "$candidate" ] && [ "$candidate" != "YOUR_ZAI_API_KEY_HERE" ]; then
                printf '%s' "$candidate"; return 0
            fi
        fi
    done

    # 4. settings.json in config dirs
    local settings_files=(
        "$HOME/.claude-glm-5/settings.json"
        "$HOME/.claude-glm-51/settings.json"
        "$HOME/.claude-glm-47/settings.json"
        "$HOME/.claude-glm-46/settings.json"
        "$HOME/.claude-glm-45/settings.json"
        "$HOME/.claude-glm-fast/settings.json"
    )
    for f in "${settings_files[@]}"; do
        if [ -f "$f" ]; then
            candidate=$(sed -n 's/.*"ANTHROPIC_AUTH_TOKEN"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$f" | head -n 1)
            if [ -n "$candidate" ] && [ "$candidate" != "YOUR_ZAI_API_KEY_HERE" ]; then
                printf '%s' "$candidate"; return 0
            fi
        fi
    done

    return 1
}

# ---- Single model probe ----
probe_model() {
    local model="$1"
    local key="$2"
    local tmp_body tmp_status
    tmp_body=$(mktemp)
    tmp_status=$(mktemp)

    # Minimal request, 16 max_tokens to keep cost trivial
    local payload
    payload=$(printf '{"model":"%s","max_tokens":16,"messages":[{"role":"user","content":"ok"}]}' "$model")

    local http_code
    http_code=$(curl -sS \
        --max-time "$TIMEOUT_SECONDS" \
        -o "$tmp_body" \
        -w "%{http_code}" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $key" \
        -H "anthropic-version: $ANTHROPIC_VERSION" \
        -X POST \
        "$ENDPOINT" \
        --data-binary "$payload" 2>"$tmp_status") || true

    if [ "$http_code" = "200" ]; then
        printf "  \033[32mPASS\033[0m  %-18s  HTTP 200\n" "$model"
    else
        local snippet
        if command -v jq >/dev/null 2>&1; then
            snippet=$(jq -r '.error.message // .message // .error.type // "(no error field)"' <"$tmp_body" 2>/dev/null | head -c 200)
        else
            snippet=$(head -c 200 "$tmp_body")
        fi
        # Collapse newlines for single-line output
        snippet=$(printf '%s' "$snippet" | tr '\n' ' ' | tr -s ' ')
        if [ -z "$http_code" ]; then
            local curl_err
            curl_err=$(head -c 200 "$tmp_status")
            printf "  \033[31mFAIL\033[0m  %-18s  (curl error) %s\n" "$model" "$curl_err"
        else
            printf "  \033[31mFAIL\033[0m  %-18s  HTTP %s  %s\n" "$model" "$http_code" "$snippet"
        fi
    fi

    rm -f "$tmp_body" "$tmp_status"
}

# ---- Main ----
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but not found in PATH." >&2
    exit 1
fi

KEY=$(detect_key) || {
    echo "ERROR: Could not detect Z.AI API key." >&2
    echo "Provide one via --key, the ZAI_API_KEY env var, or run install.sh first." >&2
    exit 1
}

# Resolve model list
if [ -n "$MODELS_OVERRIDE" ]; then
    IFS=',' read -r -a MODELS <<< "$MODELS_OVERRIDE"
else
    MODELS=("${DEFAULT_MODELS[@]}")
fi

MASKED_KEY="${KEY:0:6}...${KEY: -4}"
echo "Z.ai model smoke test"
echo "  Endpoint: $ENDPOINT"
echo "  API key:  $MASKED_KEY"
echo "  Models:   ${#MODELS[@]} candidates"
echo ""

for m in "${MODELS[@]}"; do
    probe_model "$m" "$KEY"
done

echo ""
echo "Done. PASS = model reachable on this key/plan. FAIL = unavailable or invalid ID."
