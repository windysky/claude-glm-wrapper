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
#   bash smoke_test_models.sh --models glm-5.1,glm-4.7  # override list
#
# The API key comes from the ZAI_API_KEY env var, or is auto-detected from the
# wrappers and settings.json files install.sh writes. A --key sk-... flag still
# works for backward compatibility but is not the recommended path: the value
# lands in your shell history.
#
# The key is never passed to curl as a command-line argument -- it is fed to
# curl on stdin, so it does not appear in the process table, where any local
# user can read it.
#
# Requires: curl. Optional: jq (nicer error snippets if present).

set -u

USER_BIN_DIR="$HOME/.local/bin"
ENDPOINT="${ZAI_ENDPOINT:-https://api.z.ai/api/anthropic/v1/messages}"
ANTHROPIC_VERSION="2023-06-01"
# 60s, not 15s: reasoning models (glm-5.3) emit a thinking block before any
# content, so time-to-first-byte can exceed 15s and curl returns HTTP 000 --
# a timeout that reads as a model failure. Observed 2026-08-16: glm-5.3 timed
# out at 15s but returned HTTP 200 on 3/3 retries at 90s.
TIMEOUT_SECONDS=60

# Candidate models to probe. Override with --models a,b,c.
#
# These are base model IDs. The default wrapper asks for the bracketed
# context-route form "glm-5.3[1m]", which is a Claude-Code-side convention the
# client translates before the request goes out -- the raw API rejects the
# bracket form with HTTP 400 [1214][modelCode: does not exist]. Do NOT add
# "glm-5.3[1m]" (or any [...] variant) to this list: it would report a
# permanent, misleading FAIL. Only the base ID can be probed here.
DEFAULT_MODELS=(
    # Models this project ships a wrapper for. Each base ID is verified to
    # serve itself rather than being rerouted to a successor.
    "glm-5.3"
    "glm-5-turbo"
    "glm-4.7"
    "glm-4.6"
    "glm-4.5"
    "glm-4.5v"
    # Retired IDs, probed on purpose: they still return HTTP 200 but are served
    # by a successor. Expect REROUTED. If one of these ever reports PASS again,
    # Z.AI un-retired it and it may deserve a wrapper back.
    "glm-5.2"
    "glm-5.1"
    "glm-5"
    "glm-4.5-air"
    # Not covered by the GLM Coding Plan -- expect HTTP 429 (needs pay-as-you-go
    # balance). Kept as the control that proves a 200 above is real plan access.
    "glm-4.7-flashx"
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
            sed -n '2,23p' "$0"; exit 0 ;;
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
        "$USER_BIN_DIR/claude-glm-5.3"
        "$USER_BIN_DIR/claude-glm-5.2"
        "$USER_BIN_DIR/claude-glm-5.1"
        "$USER_BIN_DIR/claude-glm-5-turbo"
        "$USER_BIN_DIR/claude-glm-5"
        "$USER_BIN_DIR/claude-glm-4.7"
        "$USER_BIN_DIR/claude-glm-4.6"
        "$USER_BIN_DIR/claude-glm-4.5"
        "$USER_BIN_DIR/claude-glm-4.5v"
        "$USER_BIN_DIR/claude-glm-4.5-air"
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
        "$HOME/.claude-glm-53/settings.json"
        "$HOME/.claude-glm-52/settings.json"
        "$HOME/.claude-glm-5/settings.json"
        "$HOME/.claude-glm-5-turbo/settings.json"
        "$HOME/.claude-glm-51/settings.json"
        "$HOME/.claude-glm-47/settings.json"
        "$HOME/.claude-glm-46/settings.json"
        "$HOME/.claude-glm-45/settings.json"
        "$HOME/.claude-glm-45v/settings.json"
        "$HOME/.claude-glm-45-air/settings.json"
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

# ---- API key validation ----
# The key is handed to curl as a config file (-K -), and a config file is a
# parser, not an opaque string: a newline in the key starts a fresh curl
# directive. A hostile key can therefore inject output = / url = and make curl
# write an attacker-chosen file with attacker-chosen content. Accept only the
# charset install.sh accepts, and bound the length -- a real Z.AI key is well
# under 100 characters. Applied to detect_key's result, so every source (--key,
# ZAI_API_KEY, wrappers, settings.json) is covered.
validate_key() {
    local key="$1"
    local LC_ALL=C  # byte-wise matching so the charset stays strictly ASCII

    case "$key" in
        *[!A-Za-z0-9._-]*)
            echo "ERROR: API key contains unexpected characters." >&2
            echo "Allowed: letters, digits, dot (.), underscore (_), hyphen (-)" >&2
            return 1 ;;
    esac

    if [ "${#key}" -gt 200 ]; then
        echo "ERROR: API key is ${#key} characters; the limit is 200." >&2
        return 1
    fi

    return 0
}

# ---- Temp file cleanup ----
# Paths of the temp files for the probe currently in flight. Tracked at script
# scope so the trap can remove them when the run is interrupted (Ctrl-C), not
# only when probe_model returns normally.
TMP_BODY=""
TMP_STATUS=""
cleanup_tmp() {
    rm -f "$TMP_BODY" "$TMP_STATUS"
}
trap cleanup_tmp EXIT
trap 'cleanup_tmp; exit 130' INT
trap 'cleanup_tmp; exit 143' TERM

# ---- Single model probe ----
probe_model() {
    local model="$1"
    local key="$2"
    TMP_BODY=$(mktemp)
    TMP_STATUS=$(mktemp)

    # Minimal request, 16 max_tokens to keep cost trivial
    local payload
    payload=$(printf '{"model":"%s","max_tokens":16,"messages":[{"role":"user","content":"ok"}]}' "$model")

    # The key goes to curl on stdin via -K (config file), NOT as an argument:
    # process arguments are world-readable through /proc/<pid>/cmdline, so an
    # -H "x-api-key: ..." here would leak the key to every local user for the
    # duration of each probe. printf is a bash builtin, so it spawns no process
    # of its own and the key never reaches any command line. Only the config may
    # come from stdin -- the payload stays on argv (it holds no secret).
    local http_code
    http_code=$(printf 'header = "x-api-key: %s"\n' "$key" | curl -sS \
        --max-time "$TIMEOUT_SECONDS" \
        -o "$TMP_BODY" \
        -w "%{http_code}" \
        -H "Content-Type: application/json" \
        -K - \
        -H "anthropic-version: $ANTHROPIC_VERSION" \
        -X POST \
        "$ENDPOINT" \
        --data-binary "$payload" 2>"$TMP_STATUS") || true

    if [ "$http_code" = "200" ]; then
        # HTTP 200 alone is NOT proof the model you asked for answered. Z.AI
        # silently reroutes retired IDs to a successor (glm-5/5.1/5.2 ->
        # glm-5.3, glm-4.5-air -> glm-4.7) and still returns 200, so a
        # status-only check reports a dead model as healthy. The response body
        # echoes the model that actually served -- compare it.
        local served
        if command -v jq >/dev/null 2>&1; then
            served=$(jq -r '.model // ""' <"$TMP_BODY" 2>/dev/null)
        else
            served=$(sed -n 's/.*"model"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <"$TMP_BODY" | head -n 1)
        fi

        if [ -z "$served" ]; then
            # Reachable, but nothing was echoed back to compare against, so the
            # serving model was never established. Calling this PASS would
            # re-admit the status-only false positive this comparison exists to
            # catch -- a rerouted model looks identical from here.
            printf "  \033[33mUNKNOWN\033[0m  %-15s  HTTP 200  (served-by not reported)\n" "$model"
        elif [ "$served" = "$model" ]; then
            printf "  \033[32mPASS\033[0m  %-18s  HTTP 200  served-by %s\n" "$model" "$served"
        else
            printf "  \033[33mREROUTED\033[0m  %-14s  HTTP 200  served-by \033[33m%s\033[0m  (this model ID no longer runs its own model)\n" "$model" "$served"
        fi
    else
        local snippet
        if command -v jq >/dev/null 2>&1; then
            snippet=$(jq -r '.error.message // .message // .error.type // "(no error field)"' <"$TMP_BODY" 2>/dev/null | head -c 200)
        else
            snippet=$(head -c 200 "$TMP_BODY")
        fi
        # Collapse newlines for single-line output
        snippet=$(printf '%s' "$snippet" | tr '\n' ' ' | tr -s ' ')
        if [ -z "$http_code" ]; then
            local curl_err
            curl_err=$(head -c 200 "$TMP_STATUS")
            printf "  \033[31mFAIL\033[0m  %-18s  (curl error) %s\n" "$model" "$curl_err"
        else
            printf "  \033[31mFAIL\033[0m  %-18s  HTTP %s  %s\n" "$model" "$http_code" "$snippet"
        fi
    fi

    rm -f "$TMP_BODY" "$TMP_STATUS"
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

validate_key "$KEY" || exit 1

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
echo "Done."
echo "  PASS     = reachable AND served by the model you asked for."
echo "  UNKNOWN  = reachable, but the reply named no model, so which one served"
echo "             it could not be determined -- neither confirmed nor rerouted."
echo "  REROUTED = reachable but a DIFFERENT model answered; this ID is retired."
echo "  FAIL     = unavailable, invalid ID, or not covered by your plan."
