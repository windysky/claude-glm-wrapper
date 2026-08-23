#!/bin/bash
# Claude-GLM Server-Friendly Installer
# Works without sudo, installs to user's home directory
#
# Usage:
#   Test error reporting:
#     CLAUDE_GLM_TEST_ERROR=1 bash <(curl -fsSL https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.sh)
#     OR: ./install.sh --test-error
#
#   Enable debug mode:
#     CLAUDE_GLM_DEBUG=1 bash <(curl -fsSL https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.sh)
#     OR: ./install.sh --debug

# Parse command-line arguments
TEST_ERROR=false
DEBUG=false

for arg in "$@"; do
    case $arg in
        --test-error)
            TEST_ERROR=true
            shift
            ;;
        --debug)
            DEBUG=true
            shift
            ;;
        *)
            # Unknown option
            ;;
    esac
done

# Support environment variables for parameters
if [ "$CLAUDE_GLM_TEST_ERROR" = "1" ] || [ "$CLAUDE_GLM_TEST_ERROR" = "true" ]; then
    TEST_ERROR=true
fi

if [ "$CLAUDE_GLM_DEBUG" = "1" ] || [ "$CLAUDE_GLM_DEBUG" = "true" ]; then
    DEBUG=true
fi

# Debug tracing for --debug / CLAUDE_GLM_DEBUG=1, both documented in the header
# above. Mirrors Write-DebugLog in install.ps1 so the two installers trace the
# same decisions.
#
# The `if` form is load-bearing: `[ "$DEBUG" = "true" ] && echo ...` returns 1
# when debug is OFF, and this script runs under `set -eE` (see the bottom of the
# file), so every call site would abort the install for the majority of users who
# never pass --debug. `if ... fi` returns 0 either way. Verified, not assumed.
#
# Output goes to stderr so it never contaminates a function's stdout — several
# of these functions return values by printing them.
#
# No call site below touches $ZAI_API_KEY or ANTHROPIC_AUTH_TOKEN: these trace
# paths, counts and branch decisions only. Keep it that way when adding more.
debug_log() {
    if [ "$DEBUG" = "true" ]; then
        echo "DEBUG: $*" >&2
    fi
}

# Configuration
USER_BIN_DIR="$HOME/.local/bin"
GLM_45_CONFIG_DIR="$HOME/.claude-glm-45"
GLM_45V_CONFIG_DIR="$HOME/.claude-glm-45v"
GLM_45AIR_CONFIG_DIR="$HOME/.claude-glm-45-air"
GLM_46_CONFIG_DIR="$HOME/.claude-glm-46"
GLM_47_CONFIG_DIR="$HOME/.claude-glm-47"
GLM_5_CONFIG_DIR="$HOME/.claude-glm-5"
GLM_5T_CONFIG_DIR="$HOME/.claude-glm-5-turbo"
GLM_51_CONFIG_DIR="$HOME/.claude-glm-51"
GLM_52_CONFIG_DIR="$HOME/.claude-glm-52"
GLM_53_CONFIG_DIR="$HOME/.claude-glm-53"
GLM_FAST_CONFIG_DIR="$HOME/.claude-glm-fast"
ZAI_API_KEY="YOUR_ZAI_API_KEY_HERE"

# Every file this installer writes is private to the user: the wrappers embed
# the Z.AI API key, the rc temp file holds the user's shell rc. `cat >` creates
# under the ambient umask (644 with the usual 022), so without this they exist
# world-readable for the instant before the chmod that follows. The chmod calls
# stay in place as defence in depth.
umask 077

# Report installation errors to GitHub
report_error() {
    local error_msg="$1"
    local error_line="$2"
    local error_code="$3"

    echo ""
    echo "============================================="
    echo "❌ Installation failed!"
    echo "============================================="
    echo ""

    # Collect system information
    local os_info="$(uname -s) $(uname -r) ($(uname -m))"
    local shell_info="bash $BASH_VERSION"
    local timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

    # Sanitize error message (remove API keys)
    local sanitized_error=$(echo "$error_msg" | sed \
        -e 's/ANTHROPIC_AUTH_TOKEN="[^"]*"/ANTHROPIC_AUTH_TOKEN="[REDACTED]"/g' \
        -e 's/ZAI_API_KEY="[^"]*"/ZAI_API_KEY="[REDACTED]"/g' \
        -e 's/\$ZAI_API_KEY="[^"]*"/\$ZAI_API_KEY="[REDACTED]"/g')

    # The patterns above only match NAME="value". The key is also stored bare —
    # as a settings.json value, in a request header, in an unquoted assignment —
    # so redact the value itself too. Skipped while the key is still the
    # placeholder, which would otherwise redact a harmless literal.
    if [ -n "$ZAI_API_KEY" ] && [ "$ZAI_API_KEY" != "YOUR_ZAI_API_KEY_HERE" ]; then
        sanitized_error="${sanitized_error//"$ZAI_API_KEY"/[REDACTED]}"
    fi

    # Display error details to user
    echo "Error Details:"
    echo "$sanitized_error"
    if [ -n "$error_line" ]; then
        echo "Location: $error_line"
    fi
    echo ""

    # Ask if user wants to report error
    echo "Would you like to report this error to GitHub?"
    echo "This will open your browser with a pre-filled issue report."
    read -p "Report error? (y/n): " report_choice
    echo ""

    if [ "$report_choice" != "y" ] && [ "$report_choice" != "Y" ]; then
        echo "Error not reported. You can get help at:"
        echo "  https://github.com/windysky/claude-glm-wrapper/issues"
        echo ""
        echo "Press Enter to finish..."
        read
        return
    fi

    # Get additional context
    local claude_found="No"
    if command -v claude &> /dev/null; then
        claude_found="Yes ($(which claude))"
    fi

    # Build error report
    local issue_body="## Installation Error (Unix/Linux/macOS)

**OS:** $os_info
**Shell:** $shell_info
**Timestamp:** $timestamp

### Error Details:
\`\`\`
$sanitized_error
\`\`\`
"

    if [ -n "$error_line" ]; then
        issue_body+="
**Error Location:** $error_line
"
    fi

    if [ -n "$error_code" ]; then
        issue_body+="
**Exit Code:** $error_code
"
    fi

    issue_body+="
### System Information:
- Installation Location: $USER_BIN_DIR
- Claude Code Found: $claude_found
- PATH: \`$(echo $PATH | sed 's/:/\n  /g')\`

---
*This error was automatically reported by the installer. Please add any additional context below.*
"

    # URL encode using Python (most compatible) - using stdin to prevent command injection
    local encoded_body=""
    local encoded_title=""

    if command -v python3 &> /dev/null; then
        encoded_body=$(printf '%s' "$issue_body" | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read()))" 2>/dev/null)
        encoded_title=$(printf '%s' "Installation Error: Unix/Linux/macOS" | python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read()))" 2>/dev/null)
    elif command -v python &> /dev/null; then
        encoded_body=$(printf '%s' "$issue_body" | python -c "import urllib,sys; print urllib.quote(sys.stdin.read())" 2>/dev/null)
        encoded_title=$(printf '%s' "Installation Error: Unix/Linux/macOS" | python -c "import urllib,sys; print urllib.quote(sys.stdin.read())" 2>/dev/null)
    else
        # Fallback: basic URL encoding with sed
        encoded_body=$(printf '%s' "$issue_body" | sed 's/ /%20/g; s/\n/%0A/g')
        encoded_title="Installation%20Error%3A%20Unix%2FLinux%2FmacOS"
    fi

    local issue_url="https://github.com/windysky/claude-glm-wrapper/issues/new?title=${encoded_title}&body=${encoded_body}&labels=bug,unix,installation"

    echo "📋 Error details have been prepared for reporting."
    echo ""

    # Try to open in browser
    local browser_opened=false
    if command -v xdg-open &> /dev/null; then
        if xdg-open "$issue_url" 2>/dev/null; then
            browser_opened=true
            echo "✅ Browser opened with pre-filled error report."
        fi
    elif command -v open &> /dev/null; then
        if open "$issue_url" 2>/dev/null; then
            browser_opened=true
            echo "✅ Browser opened with pre-filled error report."
        fi
    fi

    if [ "$browser_opened" = false ]; then
        echo "⚠️  Could not open browser automatically."
        echo ""
        echo "Please copy and open this URL manually:"
        echo "$issue_url"
    fi

    echo ""

    # Add instructions and wait for user
    if [ "$browser_opened" = true ]; then
        echo "Please review error report in your browser and submit the issue."
        echo "After submitting (or if you choose not to), return here."
    fi

    echo ""
    echo "Press Enter to continue..."
    read
}

# Find all existing wrapper installations
find_all_installations() {
    local locations=(
        "/usr/local/bin"
        "/usr/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
    )

    local found_files=()

    debug_log "find_all_installations: scanning ${#locations[@]} location(s)"
    for location in "${locations[@]}"; do
        if [ -d "$location" ]; then
            # Find all claude-glm* files in this location
            while IFS= read -r file; do
                if [ -f "$file" ]; then
                    found_files+=("$file")
                fi
            done < <(find "$location" -maxdepth 1 -name "claude-glm*" 2>/dev/null)
        fi
    done

    debug_log "find_all_installations: found ${#found_files[@]} file(s)"
    # Return found files (print them)
    printf '%s\n' "${found_files[@]}"
}

# Clean up old wrapper installations
cleanup_old_wrappers() {
    local current_location="$USER_BIN_DIR"
    # Read one path per line instead of an unquoted $(...) inside ( ), which
    # re-splits on $IFS — spaces included — so a wrapper path containing a space
    # became several array entries and the delete loop below reached `rm` with a
    # relative fragment. The [ -n ] guard drops the single blank line that
    # find_all_installations' `printf '%s\n' "${found_files[@]}"` emits on an
    # empty array, preserving the -eq 0 early return on a fresh install.
    # Deliberately NOT the bash 4.0+ array-read builtins: macOS ships bash 3.2.57
    # and is a supported platform, and under `set -eE` a missing builtin exits
    # 127 into the ERR trap — a file-a-bug prompt instead of an install. This
    # loop mirrors the one the producer itself uses above.
    # See SPEC_LOW_DEFECTS_CLEANUP.md §1a for both reproduced failures.
    local all_wrappers=()
    local wrapper_line
    while IFS= read -r wrapper_line; do
        [ -n "$wrapper_line" ] && all_wrappers+=("$wrapper_line")
    done < <(find_all_installations)

    debug_log "cleanup_old_wrappers: ${#all_wrappers[@]} wrapper(s) in scope"
    if [ ${#all_wrappers[@]} -eq 0 ]; then
        debug_log "cleanup_old_wrappers: nothing to clean, returning early"
        return 0
    fi

    # Separate current location files from old ones
    local old_wrappers=()
    local current_wrappers=()

    for wrapper in "${all_wrappers[@]}"; do
        if [[ "$wrapper" == "$current_location"* ]]; then
            current_wrappers+=("$wrapper")
        else
            old_wrappers+=("$wrapper")
        fi
    done

    # If no old wrappers found, nothing to clean
    if [ ${#old_wrappers[@]} -eq 0 ]; then
        return 0
    fi

    echo ""
    echo "🔍 Found existing wrappers in multiple locations:"
    echo ""

    for wrapper in "${old_wrappers[@]}"; do
        echo "  ❌ $wrapper (old location)"
    done

    if [ ${#current_wrappers[@]} -gt 0 ]; then
        for wrapper in "${current_wrappers[@]}"; do
            echo "  ✅ $wrapper (current location)"
        done
    fi

    echo ""
    read -p "Would you like to clean up old installations? (y/n): " cleanup_choice

    if [[ "$cleanup_choice" == "y" || "$cleanup_choice" == "Y" ]]; then
        echo ""
        echo "Removing old wrappers..."
        for wrapper in "${old_wrappers[@]}"; do
            if rm "$wrapper" 2>/dev/null; then
                echo "  ✅ Removed: $wrapper"
            else
                echo "  ⚠️  Could not remove: $wrapper (permission denied)"
            fi
        done
        echo ""
        echo "✅ Cleanup complete!"
    else
        echo ""
        echo "⚠️  Skipping cleanup. Old wrappers may interfere with new installation."
        echo "   You may want to manually remove them later."
    fi

    echo ""
}

# Validate an API key before it is embedded into wrappers and settings.json.
# Only [A-Za-z0-9._-] is accepted: anything else (quote, $, ;, backtick,
# backslash, whitespace) can break out of the generated shell assignment or
# JSON string and run as code on every wrapper launch.
validate_zai_api_key() {
    local key="$1"
    local LC_ALL=C  # byte-wise matching so the charset stays strictly ASCII

    if [ -z "$key" ]; then
        return 1
    fi

    case "$key" in
        *[!A-Za-z0-9._-]*)
            echo ""
            echo "❌ API key contains unexpected characters."
            echo "   Allowed: letters, digits, dot (.), underscore (_), hyphen (-)"
            echo "   The key was NOT saved and no files were changed."
            echo "   Re-run the installer and paste the key exactly as shown at:"
            echo "   https://z.ai/manage-apikey/apikey-list"
            echo ""
            return 1
            ;;
    esac

    return 0
}

detect_existing_zai_api_key() {
    local candidate=""
    local wrapper_files=(
        "$USER_BIN_DIR/claude-glm-5.3"
        "$USER_BIN_DIR/claude-glm-5.2"
        "$USER_BIN_DIR/claude-glm-5.1"
        "$USER_BIN_DIR/claude-glm-5-turbo"
        "$USER_BIN_DIR/claude-glm-5"
        "$USER_BIN_DIR/claude-glm-4.7"
        "$USER_BIN_DIR/claude-glm-4.6"
        "$USER_BIN_DIR/claude-glm-4.5v"
        "$USER_BIN_DIR/claude-glm-4.5-air"
        "$USER_BIN_DIR/claude-glm-4.5"
        "$USER_BIN_DIR/claude-glm-fast"
    )

    for f in "${wrapper_files[@]}"; do
        if [ -f "$f" ]; then
            candidate=$(sed -n 's/^export ANTHROPIC_AUTH_TOKEN="\([^"]*\)".*/\1/p' "$f" | head -n 1)
            if [ -n "$candidate" ] && [ "$candidate" != "YOUR_ZAI_API_KEY_HERE" ]; then
                printf '%s' "$candidate"
                return 0
            fi
        fi
    done

    local settings_files=(
        "$GLM_53_CONFIG_DIR/settings.json"
        "$GLM_52_CONFIG_DIR/settings.json"
        "$GLM_51_CONFIG_DIR/settings.json"
        "$GLM_5T_CONFIG_DIR/settings.json"
        "$GLM_5_CONFIG_DIR/settings.json"
        "$GLM_47_CONFIG_DIR/settings.json"
        "$GLM_46_CONFIG_DIR/settings.json"
        "$GLM_45V_CONFIG_DIR/settings.json"
        "$GLM_45AIR_CONFIG_DIR/settings.json"
        "$GLM_45_CONFIG_DIR/settings.json"
        "$GLM_FAST_CONFIG_DIR/settings.json"
    )

    for f in "${settings_files[@]}"; do
        if [ -f "$f" ]; then
            candidate=$(sed -n 's/.*"ANTHROPIC_AUTH_TOKEN"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$f" | head -n 1)
            if [ -n "$candidate" ] && [ "$candidate" != "YOUR_ZAI_API_KEY_HERE" ]; then
                printf '%s' "$candidate"
                return 0
            fi
        fi
    done

    return 1
}

# Detect shell and rc file
detect_shell_rc() {
    local shell_name=$(basename "$SHELL")
    local rc_file=""

    case "$shell_name" in
        bash)
            rc_file="$HOME/.bashrc"
            [ -f "$HOME/.bash_profile" ] && rc_file="$HOME/.bash_profile"
            ;;
        zsh)
            rc_file="$HOME/.zshrc"
            ;;
        ksh)
            rc_file="$HOME/.kshrc"
            [ -f "$HOME/.profile" ] && rc_file="$HOME/.profile"
            ;;
        csh|tcsh)
            rc_file="$HOME/.cshrc"
            ;;
        *)
            rc_file="$HOME/.profile"
            ;;
    esac

    debug_log "detect_shell_rc: SHELL=$SHELL -> shell_name=$shell_name -> rc=$rc_file"
    echo "$rc_file"
}

# Returns 0 if ~/.bash_profile already loads ~/.bashrc (via `.`/`source`), meaning a
# second copy of the alias block in ~/.bash_profile would be redundant; 1 otherwise.
bash_profile_sources_bashrc() {
    [ -f "$HOME/.bash_profile" ] || return 1
    grep -E '\.bashrc' "$HOME/.bash_profile" 2>/dev/null \
        | grep -vE '^[[:space:]]*#' \
        | grep -Eq '(^|[;&|[:space:]])(\.|source)[[:space:]]+[^;&|]*\.bashrc'
}

# Ensure user bin directory exists and is in PATH
setup_user_bin() {
    # Create user bin directory.
    #
    # The umask 077 set at the top of this script exists to close the window
    # where a key-bearing file is world-readable between `cat >` and its chmod.
    # It is process-global though, so it would also create ~/.local and
    # ~/.local/bin at 0700 — and ~/.local is a shared XDG directory this
    # installer does not own (other tooling populates ~/.local/share, lib, ...).
    # Restore the conventional mode; the wrappers inside stay 700 regardless.
    # Only affects a directory this run creates — an existing one is untouched.
    local bin_dir_existed=0
    [ -d "$USER_BIN_DIR" ] && bin_dir_existed=1
    mkdir -p "$USER_BIN_DIR"
    if [ "$bin_dir_existed" = "0" ]; then
        chmod 755 "$USER_BIN_DIR" 2>/dev/null || true
        chmod 755 "$(dirname "$USER_BIN_DIR")" 2>/dev/null || true
    fi

    local rc_file=$(detect_shell_rc)

    # Check if PATH includes user bin
    if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
        # Build the PATH line for this shell type
        local path_line
        if [[ "$rc_file" == *".cshrc" ]]; then
            path_line="setenv PATH \$PATH:$USER_BIN_DIR"
        else
            path_line="export PATH=\"\$PATH:$USER_BIN_DIR\""
        fi

        # $PATH stays stale until the user sources the rc, so a second run lands
        # in this branch again. Append only when our line is not already there,
        # otherwise every re-run stacks another identical export.
        if grep -qxF "$path_line" "$rc_file" 2>/dev/null; then
            echo "📝 $USER_BIN_DIR already added to PATH in $rc_file"
        elif [ -e "$rc_file" ] && [ ! -w "$rc_file" ]; then
            # Same rule as the alias block: a write-protected rc is left alone,
            # and the failed append must not abort the install via the ERR trap.
            echo "⚠️  $rc_file is write-protected — PATH line not added."
            echo "   Add this line by hand: $path_line"
        else
            echo "📝 Adding $USER_BIN_DIR to PATH in $rc_file"
            echo "$path_line" >> "$rc_file"
        fi

        echo ""
        echo "⚠️  IMPORTANT: You will need to run this command after installation:"
        echo "   source $rc_file"
        echo ""

        # Update PATH for this installer session too
        export PATH="$PATH:$USER_BIN_DIR"
    fi
}

verify_user_bin_path() {
    if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
        local rc_file=$(detect_shell_rc)
        echo "⚠️  $USER_BIN_DIR is not in PATH for this session."
        echo "   Run: source $rc_file"
        echo ""
    fi
}

# Create GLM-4.7 wrapper
create_claude_glm_47_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-4.7"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-4.7 - Claude Code with Z.AI GLM-4.7 (Standard Model)

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-47"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
# umask 077 keeps this key-bearing file out of the world-readable window
# between creation and the chmod below. Scoped to a subshell so the claude
# session launched further down still runs under the user's own umask.
(umask 077; cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7"
  }
}
SETTINGS
)

chmod 600 "\$CLAUDE_HOME/settings.json"

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-4.7 (Standard Model)..."
echo "📁 Config directory: \$CLAUDE_HOME"
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "\$@"
EOF

    chmod 700 "$wrapper_path"
    echo "✅ Installed claude-glm-4.7 at $wrapper_path"
}

# Create GLM-4.5 wrapper
create_claude_glm_45_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-4.5"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-4.5 - Claude Code with Z.AI GLM-4.5

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.5"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.5"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-45"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
# umask 077 keeps this key-bearing file out of the world-readable window
# between creation and the chmod below. Scoped to a subshell so the claude
# session launched further down still runs under the user's own umask.
(umask 077; cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7"
  }
}
SETTINGS
)

chmod 600 "\$CLAUDE_HOME/settings.json"

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-4.5..."
echo "📁 Config directory: \$CLAUDE_HOME"
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "\$@"
EOF

    chmod 700 "$wrapper_path"
    echo "✅ Installed claude-glm-4.5 at $wrapper_path"
}

# Create GLM-4.5V wrapper (vision)
create_claude_glm_45v_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-4.5v"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-4.5V - Claude Code with Z.AI GLM-4.5V (Vision)

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.5v"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.5v"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-45v"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
# umask 077 keeps this key-bearing file out of the world-readable window
# between creation and the chmod below. Scoped to a subshell so the claude
# session launched further down still runs under the user's own umask.
(umask 077; cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.5v",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.5v",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7"
  }
}
SETTINGS
)

chmod 600 "\$CLAUDE_HOME/settings.json"

# Launch Claude Code with custom config
echo "🖼️  Starting Claude Code with GLM-4.5V (Vision)..."
echo "📁 Config directory: \$CLAUDE_HOME"
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "\$@"
EOF

    chmod 700 "$wrapper_path"
    echo "✅ Installed claude-glm-4.5v at $wrapper_path"
}

# Create GLM-4.6 wrapper
create_claude_glm_46_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-4.6"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-4.6 - Claude Code with Z.AI GLM-4.6

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.6"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.6"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-46"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
# umask 077 keeps this key-bearing file out of the world-readable window
# between creation and the chmod below. Scoped to a subshell so the claude
# session launched further down still runs under the user's own umask.
(umask 077; cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7"
  }
}
SETTINGS
)

chmod 600 "\$CLAUDE_HOME/settings.json"

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-4.6..."
echo "📁 Config directory: \$CLAUDE_HOME"
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "\$@"
EOF

    chmod 700 "$wrapper_path"
    echo "✅ Installed claude-glm-4.6 at $wrapper_path"
}

# Create GLM-5-Turbo wrapper
create_claude_glm_5t_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-5-turbo"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-5-Turbo - Claude Code with Z.AI GLM-5-Turbo

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5-turbo"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5-turbo"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-5-turbo"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
# umask 077 keeps this key-bearing file out of the world-readable window
# between creation and the chmod below. Scoped to a subshell so the claude
# session launched further down still runs under the user's own umask.
(umask 077; cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5-turbo",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5-turbo",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7"
  }
}
SETTINGS
)

chmod 600 "\$CLAUDE_HOME/settings.json"

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-5-Turbo..."
echo "📁 Config directory: \$CLAUDE_HOME"
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "\$@"
EOF

    chmod 700 "$wrapper_path"
    echo "✅ Installed claude-glm-5-turbo at $wrapper_path"
}

# Create GLM-5.3 wrapper (1M context)
create_claude_glm_53_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-5.3"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-5.3 - Claude Code with Z.AI GLM-5.3 (1M context)

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.3[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.3[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="900000"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-53"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
# umask 077 keeps this key-bearing file out of the world-readable window
# between creation and the chmod below. Scoped to a subshell so the claude
# session launched further down still runs under the user's own umask.
(umask 077; cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.3[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5.3[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "900000"
  }
}
SETTINGS
)

chmod 600 "\$CLAUDE_HOME/settings.json"

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-5.3 (1M context)..."
echo "📁 Config directory: \$CLAUDE_HOME"
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "\$@"
EOF

    chmod 700 "$wrapper_path"
    echo "✅ Installed claude-glm-5.3 at $wrapper_path"
}

# Remove wrappers this version no longer ships.
#
# Z.AI retired these model IDs: a request for them is silently served by a
# different model (glm-5 / glm-5.1 / glm-5.2 -> glm-5.3, glm-4.5-air -> glm-4.7),
# so a wrapper named after one no longer does what its name says. Deleting the
# script is what makes the retirement real -- the matching shell aliases are
# stripped separately by remove_aliases_from_rc.
#
# Called AFTER the wrappers are (re)created, so that detect_existing_zai_api_key
# can still recover a key from an old wrapper on an upgrading machine.
#
# Config directories (~/.claude-glm-52 etc.) are deliberately NOT deleted: they
# hold the user's own Claude Code session state, not installer output.
remove_retired_wrappers() {
    local retired=(
        "claude-glm-5"
        "claude-glm-5.1"
        "claude-glm-5.2"
        "claude-glm-4.5-air"
        "claude-glm-fast"
        # Pre-tier-scheme orphan: the bare "claude-glm" wrapper still exported
        # the retired ANTHROPIC_MODEL / ANTHROPIC_SMALL_FAST_MODEL pair. No
        # current installer version creates it, so it only lingers on machines
        # upgraded from before the tier-mapping migration.
        "claude-glm"
    )
    local removed=0
    local name
    for name in "${retired[@]}"; do
        # Only delete files this installer actually wrote. One retired name is
        # the generic "claude-glm", so a filename match alone would silently
        # remove a user's own unrelated script of that name — and unlike
        # cleanup_old_wrappers, this path never asks. Every wrapper this
        # installer generates points at the Z.AI endpoint, so require that
        # fingerprint before removing anything.
        # Match the endpoint only where a wrapper ASSIGNS it, not anywhere in the
        # file: a whole-file grep also matched a user's own script that merely
        # mentions the endpoint in a comment, and this path never asks before
        # deleting. Verified safe against the full history — every wrapper form
        # ever generated under a retired name writes exactly
        # `export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"`, unindented,
        # so nothing key-bearing becomes undeletable by tightening this.
        if [ -f "$USER_BIN_DIR/$name" ] && \
           grep -qE '^[[:space:]]*(export[[:space:]]+)?ANTHROPIC_BASE_URL=.*api\.z\.ai/api/anthropic' \
                "$USER_BIN_DIR/$name" 2>/dev/null; then
            # A failed removal must not stop the install, and must not pass
            # silently either: the wrapper left behind still carries the user's
            # API key and still points at a name Z.AI no longer serves.
            if rm -f "$USER_BIN_DIR/$name" 2>/dev/null; then
                removed=$((removed + 1))
            else
                echo "  ⚠️  Could not remove retired wrapper: $USER_BIN_DIR/$name"
                echo "     Delete it manually — it still holds your API key."
            fi
        fi
    done
    # `ccx` is retired too, but it cannot use the loop above: the historical ccx
    # wrapper was a local proxy (ANTHROPIC_BASE_URL="http://127.0.0.1:${PORT}") and
    # is the only wrapper form this installer ever wrote WITHOUT the Z.AI endpoint,
    # so there is no shared fingerprint to test. It previously ran as an
    # unconditional `rm` before the menu, which deleted a user's own ~/.local/bin/ccx
    # with no prompt — and still deleted it when the user chose "Cancel". Gate it on
    # the proxy wrapper's own markers, and run it here so declining the install
    # declines this too. A surviving retired ccx points at a dead local port: it
    # fails loudly and harmlessly, which is the better way for this to be wrong.
    if [ -f "$USER_BIN_DIR/ccx" ] && \
       grep -qE 'CLAUDE_PROXY_PORT|ANTHROPIC_UPSTREAM_URL' "$USER_BIN_DIR/ccx" 2>/dev/null; then
        if rm -f "$USER_BIN_DIR/ccx" 2>/dev/null; then
            removed=$((removed + 1))
        else
            echo "  ⚠️  Could not remove retired wrapper: $USER_BIN_DIR/ccx"
            echo "     Delete it manually — it still holds your API key."
        fi
    fi

    if [ "$removed" -gt 0 ]; then
        echo "🧹 Removed $removed retired wrapper(s) — that model is no longer served under its own name"
    fi
}

# ---- Staged rc rewrite cleanup ----
# Paths of the temp + backup files for the rc rewrite currently in flight.
# Tracked at script scope so the trap can remove them when the run is
# interrupted (Ctrl-C) or aborts through the ERR path, not only when
# remove_aliases_from_rc returns normally. Cleared as soon as a path has been
# dealt with, so the trap never removes a backup we deliberately kept.
RC_TMP=""
RC_BAK=""
cleanup_rc_staging() {
    if [ -n "$RC_TMP" ]; then
        rm -f "$RC_TMP" 2>/dev/null || true
    fi
    if [ -n "$RC_BAK" ]; then
        rm -f "$RC_BAK" 2>/dev/null || true
    fi
    return 0
}

# Create shell aliases
create_shell_aliases() {
    local rc_file=$(detect_shell_rc)

    if [ -z "$rc_file" ]; then
        echo "⚠️  Could not detect shell rc file, skipping aliases"
        return
    fi

    # Every refusal below leaves the OLD alias block in the file, and
    # remove_retired_wrappers already deleted the wrappers it names earlier in
    # this same run — so those aliases now resolve to files that are gone. Say
    # that, rather than only reporting which permission or write failed.
    stale_block_warning() {
        local remedy="$1"
        echo "   Your rc still contains an alias block pointing at wrappers this"
        echo "   version removed, so those aliases no longer resolve."
        echo "   $remedy and re-run, or delete the block by hand."
    }

    remove_aliases_from_rc() {
        local target_rc="$1"

        if [ -z "$target_rc" ] || [ ! -f "$target_rc" ]; then
            return
        fi

        # A write-protected rc is a deliberate choice, so refuse instead of
        # rewriting it. The old `mv` replaced the file wholesale, which dropped
        # the protection and still reported success.
        if [ ! -w "$target_rc" ]; then
            echo "⚠️  $target_rc is write-protected — leaving it untouched."
            stale_block_warning "Make the file writable"
            return 1
        fi

        # Writable but unreadable (mode 200) passes the check above, yet the
        # header grep below cannot read the file and returns 2, so removal is
        # skipped while the append still runs — producing a second alias block
        # alongside the stale one. Refuse instead.
        if [ ! -r "$target_rc" ]; then
            echo "⚠️  $target_rc is not readable — leaving it untouched."
            stale_block_warning "Fix its permissions"
            return 1
        fi

        # Remove old aliases if they exist.
        # Trigger matches both the legacy header ("# Claude Code Model Switcher Aliases")
        # and the current header ("# Claude-GLM Model Switcher Aliases") so re-runs
        # never duplicate the alias block.
        local legacy_pristine_block=0
        if grep -qE "^alias ccdDd=['\"]?claude --dangerously-skip-permissions -d" "$target_rc" 2>/dev/null \
           && grep -qE "^alias claudeDd=['\"]?claudeD -d" "$target_rc" 2>/dev/null; then
            # Fingerprint of the OLD wrapper's auto-installed claude alias block.
            # If present, scrub the full quintet as part of migration.
            # User-curated claude aliases (without these specific Dd self-references)
            # do NOT match this fingerprint and are left alone.
            legacy_pristine_block=1
            echo "ℹ️  Detected legacy claude alias block from previous wrapper version — migrating."
        fi

        if grep -qE "^# (Claude Code|Claude-GLM) Model Switcher Aliases" "$target_rc" 2>/dev/null; then
            local legacy_claude_filter='cat'
            if [ "$legacy_pristine_block" = "1" ]; then
                legacy_claude_filter='grep -vE "^alias (ccd|ccdD|ccdDd|claudeD|claudeDd)="'
            fi

            # --- Full-line alias matching ---------------------------------
            # A managed alias is removed ONLY when the alias NAME *and* its
            # ENTIRE value match a form this installer generates. Matching the
            # whole line (anchored ^...$) instead of an "alias NAME=" prefix
            # means a user's own alias of the same name, pointing at anything
            # else, keeps its LINE in the rc verbatim.
            #
            # That guarantee is textual, not behavioural. The managed block is
            # appended after the user's line and the last definition wins, so a
            # user alias whose NAME collides with a managed one survives in the
            # file while resolving to the managed target at runtime. Renaming
            # the colliding alias is the only way to keep its binding.
            #
            # Retired names (ccg5, ccg51, ccg52, ccg45air, ccf, ccx) stay in the
            # list on purpose: a re-run must scrub aliases whose wrapper this
            # version no longer ships, or they linger pointing at a deleted file.
            local managed_names='ccg|ccgD|ccgDd|ccgA|ccg45|ccg45D|ccg45Dd|ccg45A|ccg45v|ccg45vD|ccg45vDd|ccg45vA|ccg45air|ccg45airD|ccg45airDd|ccg45airA|ccg46|ccg46D|ccg46Dd|ccg46A|ccg47|ccg47D|ccg47Dd|ccg47A|ccg5|ccg5D|ccg5Dd|ccg5A|ccg5t|ccg5tD|ccg5tDd|ccg5tA|ccg51|ccg51D|ccg51Dd|ccg51A|ccg52|ccg52D|ccg52Dd|ccg52A|ccg53|ccg53D|ccg53Dd|ccg53A|ccf|ccx'
            local managed_flags='--dangerously-skip-permissions( -d)?|--permission-mode auto'
            # Every value this installer has ever written: a claude-glm* wrapper
            # (optionally with our own flags), a managed base alias plus our
            # flags, or a legacy ccx / claude-proxy target.
            # `ccx` is matched exactly, not `ccx[A-Za-z0-9._-]*`: the historical
            # value this installer wrote was the bare string `ccx`, and the
            # trailing wildcard additionally deleted a user's own line such as
            # `alias ccx='ccx-my-tool'` — contradicting the promise above that a
            # user's alias is never touched. `claude-proxy` is gone entirely: it
            # appears in the project's history only as a directory and npm
            # package name, never as an alias value, so it matched nothing this
            # installer ever wrote and only widened the deletion surface.
            local managed_value="claude-glm[A-Za-z0-9._-]*( (${managed_flags}))?|(${managed_names}) (${managed_flags})|ccx"
            # bash/zsh:  alias NAME='VALUE'      csh:  alias NAME 'VALUE'
            # The trailing [[:space:]]* is load-bearing. grep strips only \n, so
            # on a CRLF rc file every managed line ends in \r and a bare `$`
            # anchor fails to match it — the aliases then survive forever while
            # this same run deletes the wrappers they point at, leaving
            # "command not found". Trailing spaces failed identically. CRLF rc
            # files are plausible for this project's WSL/Windows audience.
            local bash_alias_re="^alias (${managed_names})=['\"]?(${managed_value})['\"]?[[:space:]]*$"
            local csh_alias_re="^alias (${managed_names}) ['\"]?(${managed_value})['\"]?[[:space:]]*$"

            # Use temp file for compatibility. Registered with the cleanup trap
            # first, so a Ctrl-C between here and the rm below does not leave it.
            RC_TMP="$target_rc.tmp"
            grep -vE "^# (Claude Code|Claude-GLM) Model Switcher Aliases" "$target_rc" | \
            grep -v "^#  manage those manually in your shell rc)" | \
            grep -v "^# (claude itself and any claude-only aliases are intentionally left untouched" | \
            eval "$legacy_claude_filter" | \
            grep -vE "$bash_alias_re" | \
            grep -vE "$csh_alias_re" > "$target_rc.tmp" || [ $? -eq 1 ]
            # An rc holding nothing but managed content filters down to zero
            # lines, and grep exits 1 when it selects none. A pipeline reports
            # its last command's status, so without this guard `set -e` aborts
            # here — leaving the stale block in place and a stray .tmp.
            # Only exit 1 is tolerated: a real grep failure (exit 2) would write
            # an empty .tmp over the rc, so it must still reach the ERR trap.

            # That status alone is NOT enough to proceed on. The redirect itself
            # also fails with status 1 when the .tmp cannot be created (an rc
            # inside a non-writable directory), which is indistinguishable from
            # grep's "selected no lines". Require the file to EXIST before going
            # anywhere near the rc — testing for non-empty would be wrong, since
            # an rc holding only managed content legitimately filters to zero
            # bytes. Without this check the redirect below truncates the rc
            # first and only then discovers it has nothing to write.
            if [ ! -e "$target_rc.tmp" ]; then
                echo "⚠️  Could not stage a rewrite of $target_rc — it is unchanged."
                stale_block_warning "Free up disk space or fix the directory's permissions"
                RC_TMP=""
                return 1
            fi

            # Write back *through* the existing file instead of mv'ing over it.
            # mv replaces the inode: it reset the mode to the umask default (a
            # 600 rc silently became 644) and turned an rc symlinked into a
            # dotfiles repo into a regular file, so the repo stopped receiving
            # the change. A redirect follows the symlink and keeps the mode.
            #
            # A redirect is not atomic the way mv was: `>` truncates the rc
            # before cat writes a byte, so a write that dies partway (disk full,
            # quota) would leave the user's rc gutted. Keep a backup across the
            # write and restore it on failure, so the rc is either fully updated
            # or byte-identical to what it was.
            #
            # The backup only protects the rc if it is a COMPLETE copy, and the
            # truncating redirect must not run unless it is. Under the very
            # condition the backup exists for — a full disk or an exceeded quota
            # — `cp` competes for the same exhausted resource and dies partway,
            # leaving a truncated but non-empty .bak; a plain `[ -s ]` cannot
            # tell that apart from a good copy, so restoring it would destroy
            # exactly what it was meant to save. `cp` failing outright is worse
            # still: with its status discarded the redirect gutted the rc with no
            # copy to fall back on. Check both, and refuse before touching the rc
            # — the same verify-before-you-write discipline the .tmp guard above
            # already applies.
            RC_BAK="$target_rc.bak"
            # `cp -p` follows an existing symlink at the destination, so a
            # pre-planted ~/.bashrc.bak symlink makes it write the user's rc
            # THROUGH that link — to any path the user can write, including
            # outside $HOME. Removing it first makes cp create a fresh regular
            # file. Needs no induced failure to exploit, unlike the restore path.
            rm -f "$target_rc.bak"
            if ! cp -p "$target_rc" "$target_rc.bak" 2>/dev/null \
               || [ "$(wc -c < "$target_rc.bak" 2>/dev/null)" != "$(wc -c < "$target_rc" 2>/dev/null)" ]; then
                echo "⚠️  Could not back up $target_rc — it is unchanged."
                stale_block_warning "Free up disk space or fix the directory's permissions"
                rm -f "$target_rc.tmp" "$target_rc.bak"
                RC_TMP=""
                RC_BAK=""
                return 1
            fi

            if ! cat "$target_rc.tmp" > "$target_rc"; then
                # Verify the restore landed instead of asserting it: a restore
                # that hit the same limit leaves the rc short, and reporting
                # success there hides the loss it was supposed to report.
                cat "$target_rc.bak" > "$target_rc" 2>/dev/null
                if [ "$(wc -c < "$target_rc" 2>/dev/null)" = "$(wc -c < "$target_rc.bak" 2>/dev/null)" ]; then
                    echo "⚠️  Could not rewrite $target_rc — restored it from backup."
                    stale_block_warning "Free up disk space"
                    rm -f "$target_rc.bak"
                else
                    echo "❌ $target_rc may be incomplete — a backup copy is at $target_rc.bak"
                    echo "   Restore it by hand:  cp $target_rc.bak $target_rc"
                    # Keep the .bak, and unregister it from the cleanup trap:
                    # it is the only surviving complete copy of the user's rc.
                fi
                RC_BAK=""
                rm -f "$target_rc.tmp"
                RC_TMP=""
                return 1
            fi
            rm -f "$target_rc.tmp" "$target_rc.bak"
            RC_TMP=""
            RC_BAK=""
        fi

        return 0
    }

    add_aliases_to_rc() {
        local target_rc="$1"
        local shell_style="$2"

        # Every path that does NOT append the block returns non-zero, so the
        # caller can tell a refusal from a success and skip its "✅ Added
        # aliases" line. Bare `return` here would inherit the status of the
        # preceding test and report success for work that never happened.
        if [ -z "$target_rc" ]; then
            return 1
        fi

        if [ ! -f "$target_rc" ]; then
            touch "$target_rc" 2>/dev/null || return 1
        fi

        # Checked before remove_aliases_from_rc so the write-protected rc is
        # reported once, and so the append below cannot fail into the ERR trap.
        if [ ! -w "$target_rc" ]; then
            echo "⚠️  $target_rc is write-protected — aliases not added."
            echo "   Add them by hand, or make the file writable and re-run."
            return 1
        fi

        # A refused or failed removal leaves the OLD block in the file. Appending
        # on top of it would produce two alias blocks — the stale one still
        # pointing at wrappers this version deletes — so stop instead.
        if ! remove_aliases_from_rc "$target_rc"; then
            echo "   Aliases not added, to avoid leaving two alias blocks behind."
            return 1
        fi

        if [ "$shell_style" = "csh" ]; then
            cat >> "$target_rc" << 'EOF'

# Claude-GLM Model Switcher Aliases
# (claude itself and any claude-only aliases are intentionally left untouched —
#  manage those manually in your shell rc)
alias ccg 'claude-glm-5.3'
alias ccgD 'ccg --dangerously-skip-permissions'
alias ccgDd 'ccg --dangerously-skip-permissions -d'
alias ccgA 'ccg --permission-mode auto'
alias ccg45 'claude-glm-4.5'
alias ccg45D 'ccg45 --dangerously-skip-permissions'
alias ccg45Dd 'ccg45 --dangerously-skip-permissions -d'
alias ccg45A 'ccg45 --permission-mode auto'
alias ccg45v 'claude-glm-4.5v'
alias ccg45vD 'ccg45v --dangerously-skip-permissions'
alias ccg45vDd 'ccg45v --dangerously-skip-permissions -d'
alias ccg45vA 'ccg45v --permission-mode auto'
alias ccg46 'claude-glm-4.6'
alias ccg46D 'ccg46 --dangerously-skip-permissions'
alias ccg46Dd 'ccg46 --dangerously-skip-permissions -d'
alias ccg46A 'ccg46 --permission-mode auto'
alias ccg47 'claude-glm-4.7'
alias ccg47D 'ccg47 --dangerously-skip-permissions'
alias ccg47Dd 'ccg47 --dangerously-skip-permissions -d'
alias ccg47A 'ccg47 --permission-mode auto'
alias ccg5t 'claude-glm-5-turbo'
alias ccg5tD 'ccg5t --dangerously-skip-permissions'
alias ccg5tDd 'ccg5t --dangerously-skip-permissions -d'
alias ccg5tA 'ccg5t --permission-mode auto'
alias ccg53 'claude-glm-5.3'
alias ccg53D 'ccg53 --dangerously-skip-permissions'
alias ccg53Dd 'ccg53 --dangerously-skip-permissions -d'
alias ccg53A 'ccg53 --permission-mode auto'
EOF
        else
            cat >> "$target_rc" << 'EOF'

# Claude-GLM Model Switcher Aliases
# (claude itself and any claude-only aliases are intentionally left untouched —
#  manage those manually in your shell rc)
alias ccg='claude-glm-5.3'
alias ccgD='ccg --dangerously-skip-permissions'
alias ccgDd='ccg --dangerously-skip-permissions -d'
alias ccgA='ccg --permission-mode auto'
alias ccg45='claude-glm-4.5'
alias ccg45D='ccg45 --dangerously-skip-permissions'
alias ccg45Dd='ccg45 --dangerously-skip-permissions -d'
alias ccg45A='ccg45 --permission-mode auto'
alias ccg45v='claude-glm-4.5v'
alias ccg45vD='ccg45v --dangerously-skip-permissions'
alias ccg45vDd='ccg45v --dangerously-skip-permissions -d'
alias ccg45vA='ccg45v --permission-mode auto'
alias ccg46='claude-glm-4.6'
alias ccg46D='ccg46 --dangerously-skip-permissions'
alias ccg46Dd='ccg46 --dangerously-skip-permissions -d'
alias ccg46A='ccg46 --permission-mode auto'
alias ccg47='claude-glm-4.7'
alias ccg47D='ccg47 --dangerously-skip-permissions'
alias ccg47Dd='ccg47 --dangerously-skip-permissions -d'
alias ccg47A='ccg47 --permission-mode auto'
alias ccg5t='claude-glm-5-turbo'
alias ccg5tD='ccg5t --dangerously-skip-permissions'
alias ccg5tDd='ccg5t --dangerously-skip-permissions -d'
alias ccg5tA='ccg5t --permission-mode auto'
alias ccg53='claude-glm-5.3'
alias ccg53D='ccg53 --dangerously-skip-permissions'
alias ccg53Dd='ccg53 --dangerously-skip-permissions -d'
alias ccg53A='ccg53 --permission-mode auto'
EOF
        fi

        return 0
    }

    # Each "✅ Added aliases" below is conditional on the append having actually
    # happened. Announcing it unconditionally contradicted the refusal message
    # printed a line earlier, telling the user their aliases were installed when
    # the rc had deliberately been left untouched.
    case "$rc_file" in
        *".cshrc")
            if add_aliases_to_rc "$rc_file" "csh"; then
                echo "✅ Added aliases to $rc_file"
            fi
            ;;
        "$HOME/.bashrc"|"$HOME/.bash_profile")
            # bash: ~/.bashrc is the canonical home for interactive aliases.
            local written=""
            if add_aliases_to_rc "$HOME/.bashrc" "bash"; then
                written="$HOME/.bashrc"
            fi

            # Only keep a second copy in ~/.bash_profile when it does NOT already
            # source ~/.bashrc. If it bridges to ~/.bashrc, the copy is redundant —
            # strip any installer-owned block we previously left there (de-duplicate
            # on re-run). This avoids the alias block living in two files at once.
            if [ -f "$HOME/.bash_profile" ]; then
                if bash_profile_sources_bashrc; then
                    # De-duplication is a nicety, not the install. A refusal here
                    # (an unwritable ~/.bash_profile) already reports itself, and
                    # its non-zero status must not reach the ERR trap and fail an
                    # install whose aliases landed in ~/.bashrc just fine.
                    remove_aliases_from_rc "$HOME/.bash_profile" || true
                elif add_aliases_to_rc "$HOME/.bash_profile" "bash"; then
                    if [ -n "$written" ]; then
                        written="$written and $HOME/.bash_profile"
                    else
                        written="$HOME/.bash_profile"
                    fi
                fi
            fi

            if [ -n "$written" ]; then
                echo "✅ Added aliases to $written"
            fi
            ;;
        *)
            # zsh / ksh / other: write the detected rc plus ~/.bashrc as a fallback
            # (unchanged behavior for non-bash shells).
            local added_primary=0
            if add_aliases_to_rc "$rc_file" "bash"; then
                added_primary=1
            fi
            if [ "$HOME/.bashrc" != "$rc_file" ]; then
                # Fallback copy: its refusal is reported by the function itself
                # and must not abort an otherwise-successful install.
                add_aliases_to_rc "$HOME/.bashrc" "bash" || true
            fi
            if [ "$added_primary" = "1" ]; then
                echo "✅ Added aliases to $rc_file"
            fi
            ;;
    esac
}

# Check Claude Code availability
check_claude_installation() {
    echo "🔍 Checking Claude Code installation..."

    if command -v claude &> /dev/null; then
        echo "✅ Claude Code found at: $(which claude)"
        return 0
    else
        echo "⚠️  Claude Code not found in PATH"
        echo ""
        echo "Options:"
        echo "1. If Claude Code is installed elsewhere, add it to PATH first"
        echo "2. Install Claude Code from: https://www.anthropic.com/claude-code"
        echo "3. Continue anyway (wrappers will be created but won't work until claude is available)"
        echo ""
        read -p "Continue with installation? (y/n): " continue_choice
        if [[ "$continue_choice" != "y" && "$continue_choice" != "Y" ]]; then
            echo "Installation cancelled."
            exit 1
        fi
        return 1
    fi
}

# Main installation
main() {
    echo "🔧 Claude-GLM Server-Friendly Installer"
    echo "========================================"
    echo ""
    echo "This installer:"
    echo "  • Does NOT require sudo/root access"
    echo "  • Installs to: $USER_BIN_DIR"
    echo "  • Works on Unix/Linux servers"
    echo ""

    # Check Claude Code
    check_claude_installation || true

    # Setup user bin directory
    setup_user_bin
    verify_user_bin_path

    # Clean up old installations from different locations
    cleanup_old_wrappers


    # Check if already installed
    if [ -f "$USER_BIN_DIR/claude-glm-5.3" ] || [ -f "$USER_BIN_DIR/claude-glm-5.2" ] || [ -f "$USER_BIN_DIR/claude-glm-5.1" ] || [ -f "$USER_BIN_DIR/claude-glm-5-turbo" ] || [ -f "$USER_BIN_DIR/claude-glm-5" ] || [ -f "$USER_BIN_DIR/claude-glm-4.7" ] || [ -f "$USER_BIN_DIR/claude-glm-4.6" ] || [ -f "$USER_BIN_DIR/claude-glm-4.5v" ] || [ -f "$USER_BIN_DIR/claude-glm-4.5-air" ] || [ -f "$USER_BIN_DIR/claude-glm-4.5" ] || [ -f "$USER_BIN_DIR/claude-glm-fast" ]; then
        echo ""
        echo "✅ Existing installation detected!"
        echo "1) Update API key only"
        echo "2) Reset wrappers/aliases using existing API key"
        echo "3) Reinstall everything"
        echo "4) Cancel"
        read -p "Choice (1-4): " update_choice

        case "$update_choice" in
            1)
                read -rs -p "Enter your Z.AI API key: " input_key
                echo
                if [ -n "$input_key" ]; then
                    if ! validate_zai_api_key "$input_key"; then
                        exit 1
                    fi
                    ZAI_API_KEY="$input_key"
                    create_claude_glm_45_wrapper
                    create_claude_glm_45v_wrapper
                    create_claude_glm_46_wrapper
                    create_claude_glm_47_wrapper
                    create_claude_glm_5t_wrapper
                    create_claude_glm_53_wrapper
                    remove_retired_wrappers
                    create_shell_aliases
                    echo "✅ API key updated!"
                    exit 0
                fi
                ;;
            2)
                local existing_key
                existing_key=$(detect_existing_zai_api_key 2>/dev/null || true)
                if [ -z "$existing_key" ]; then
                    read -rs -p "Enter your Z.AI API key: " input_key
                    echo
                    if [ -z "$input_key" ]; then
                        exit 0
                    fi
                    existing_key="$input_key"
                fi

                # Also covers a key recovered from an on-disk wrapper: a wrapper
                # poisoned by an earlier install must not be re-injected here.
                if ! validate_zai_api_key "$existing_key"; then
                    echo "   If this key came from an existing wrapper, choose"
                    echo "   option 1 (Update API key only) and enter a clean key."
                    exit 1
                fi

                ZAI_API_KEY="$existing_key"
                create_claude_glm_45_wrapper
                create_claude_glm_45v_wrapper
                create_claude_glm_46_wrapper
                create_claude_glm_47_wrapper
                create_claude_glm_5t_wrapper
                create_claude_glm_53_wrapper
                remove_retired_wrappers
                create_shell_aliases
                echo "✅ Reset complete!"
                exit 0
                ;;
            3)
                echo "Reinstalling..."
                ;;
            *)
                exit 0
                ;;
        esac
    fi

    # Get API key
    echo ""
    echo "Enter your Z.AI API key (from https://z.ai/manage-apikey/apikey-list)"
    read -rs -p "API Key: " input_key
    echo

    if [ -n "$input_key" ]; then
        if ! validate_zai_api_key "$input_key"; then
            exit 1
        fi
        ZAI_API_KEY="$input_key"
        echo "✅ API key received (${#input_key} characters)"
    else
        echo "⚠️  No API key provided. Add it manually later to:"
        echo "   $USER_BIN_DIR/claude-glm-4.5"
        echo "   $USER_BIN_DIR/claude-glm-4.5v"
        echo "   $USER_BIN_DIR/claude-glm-4.6"
        echo "   $USER_BIN_DIR/claude-glm-4.7"
        echo "   $USER_BIN_DIR/claude-glm-5-turbo"
        echo "   $USER_BIN_DIR/claude-glm-5.3"
    fi

    # Create wrappers
    create_claude_glm_45_wrapper
    create_claude_glm_45v_wrapper
    create_claude_glm_46_wrapper
    create_claude_glm_47_wrapper
    create_claude_glm_5t_wrapper
    create_claude_glm_53_wrapper
    remove_retired_wrappers
    create_shell_aliases

    # Final instructions
    local rc_file=$(detect_shell_rc)

    echo ""
    echo "✅ Installation complete!"
    echo ""
    echo "=========================================="
    echo "⚡ IMPORTANT: Run this command now:"
    echo "=========================================="
    echo ""
    echo "   source $rc_file"
    echo ""
    echo "=========================================="
    echo ""
    echo "📝 After sourcing, you can use:"
    echo ""
    echo "Commands:"
    echo "   claude-glm-4.5     - GLM-4.5"
    echo "   claude-glm-4.5v    - GLM-4.5V (vision)"
    echo "   claude-glm-4.6     - GLM-4.6"
    echo "   claude-glm-4.7     - GLM-4.7"
    echo "   claude-glm-5-turbo - GLM-5-Turbo"
    echo "   claude-glm-5.3     - GLM-5.3 (default, 1M context)"
    echo ""
    echo "Aliases (GLM only — your 'claude' command is left untouched):"
    echo "   ccg      - claude-glm-5.3 (GLM-5.3, default, 1M context)"
    echo "   ccgD     - ccg --dangerously-skip-permissions"
    echo "   ccgDd    - ccg --dangerously-skip-permissions -d"
    echo "   ccgA     - ccg --permission-mode auto"
    echo "   ccg45    - claude-glm-4.5 (GLM-4.5)"
    echo "   ccg45v   - claude-glm-4.5v (GLM-4.5V, vision)"
    echo "   ccg46    - claude-glm-4.6 (GLM-4.6)"
    echo "   ccg47    - claude-glm-4.7 (GLM-4.7)"
    echo "   ccg5t    - claude-glm-5-turbo (GLM-5-Turbo)"
    echo "   ccg53    - claude-glm-5.3 (GLM-5.3, same as ccg)"
    echo ""

    if [ "$ZAI_API_KEY" = "YOUR_ZAI_API_KEY_HERE" ]; then
        echo "⚠️  Don't forget to add your API key to:"
        echo "   $USER_BIN_DIR/claude-glm-4.5"
        echo "   $USER_BIN_DIR/claude-glm-4.5v"
        echo "   $USER_BIN_DIR/claude-glm-4.6"
        echo "   $USER_BIN_DIR/claude-glm-4.7"
        echo "   $USER_BIN_DIR/claude-glm-5-turbo"
        echo "   $USER_BIN_DIR/claude-glm-5.3"
    fi

    echo ""
    echo "📁 Installation location: $USER_BIN_DIR"
    echo "📁 Config directories: ~/.claude-glm-45, ~/.claude-glm-45v, ~/.claude-glm-46, ~/.claude-glm-47, ~/.claude-glm-5-turbo, ~/.claude-glm-53"
}

# Error handler
handle_error() {
    local exit_code=$?
    local line_number=$1
    local bash_command="$2"

    # Capture error details
    local error_msg="Command failed with exit code $exit_code"
    if [ -n "$bash_command" ]; then
        error_msg="$error_msg: $bash_command"
    fi

    local error_location="Line $line_number in install.sh"

    report_error "$error_msg" "$error_location" "$exit_code"

    # Give user time to read any final messages before stopping
    echo ""
    echo "Installation terminated due to error."
    echo "Press Enter to finish (window will remain open)..."
    read
    # Return to stop script execution without closing terminal
    return
}

# Test error functionality if requested
if [ "$TEST_ERROR" = true ]; then
    echo "🔍 TEST: Testing error reporting functionality..."
    echo ""

    # Show how script was invoked
    if [ -n "$CLAUDE_GLM_TEST_ERROR" ]; then
        echo "   (Invoked via environment variable)"
    fi
    echo ""

    # Create a test error
    test_error_message="This is a test error to verify error reporting works correctly"
    test_error_line="Test mode - no actual error"

    report_error "$test_error_message" "$test_error_line" "0"

    echo "✅ Test complete. If a browser window opened, error reporting is working!"
    echo ""
    echo "To run normal installation, use:"
    # Process substitution, not a pipe: piping the script into bash puts its
    # source on stdin, which is the same descriptor the `read -rs -p "API Key: "`
    # prompt consumes — so the next line of the installer's own source is read as
    # the key. This is also the form README.md:37 and this script's header use.
    echo "   bash <(curl -fsSL https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.sh)"
    echo ""
    echo "Press Enter to finish (window will remain open)..."
    read
    # Script ends naturally here - terminal stays open
    exit 0
fi

# Set up error handling
set -eE  # Exit on error, inherit ERR trap in functions
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# The rc rewrite stages a .tmp and a .bak around a non-atomic write. Neither is
# removed if the run is interrupted between staging and cleanup, so clear them
# on every exit path — including Ctrl-C, which the ERR trap above never sees.
trap cleanup_rc_staging EXIT
trap 'cleanup_rc_staging; exit 130' INT
trap 'cleanup_rc_staging; exit 143' TERM

# Only run installation if not in test mode
if [ "$TEST_ERROR" != true ]; then
    # Run installation
    main "$@"
fi
