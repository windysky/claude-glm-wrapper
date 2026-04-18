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

# Configuration
USER_BIN_DIR="$HOME/.local/bin"
GLM_45_CONFIG_DIR="$HOME/.claude-glm-45"
GLM_46_CONFIG_DIR="$HOME/.claude-glm-46"
GLM_47_CONFIG_DIR="$HOME/.claude-glm-47"
GLM_5_CONFIG_DIR="$HOME/.claude-glm-5"
GLM_51_CONFIG_DIR="$HOME/.claude-glm-51"
GLM_FAST_CONFIG_DIR="$HOME/.claude-glm-fast"
ZAI_API_KEY="YOUR_ZAI_API_KEY_HERE"

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

    # Return found files (print them)
    printf '%s\n' "${found_files[@]}"
}

# Clean up old wrapper installations
cleanup_old_wrappers() {
    local current_location="$USER_BIN_DIR"
    local all_wrappers=($(find_all_installations))

    if [ ${#all_wrappers[@]} -eq 0 ]; then
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

detect_existing_zai_api_key() {
    local candidate=""
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
                printf '%s' "$candidate"
                return 0
            fi
        fi
    done

    local settings_files=(
        "$GLM_51_CONFIG_DIR/settings.json"
        "$GLM_5_CONFIG_DIR/settings.json"
        "$GLM_47_CONFIG_DIR/settings.json"
        "$GLM_46_CONFIG_DIR/settings.json"
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

    echo "$rc_file"
}

# Ensure user bin directory exists and is in PATH
setup_user_bin() {
    # Create user bin directory
    mkdir -p "$USER_BIN_DIR"

    local rc_file=$(detect_shell_rc)

    # Check if PATH includes user bin
    if [[ ":$PATH:" != *":$USER_BIN_DIR:"* ]]; then
        echo "📝 Adding $USER_BIN_DIR to PATH in $rc_file"

        # Add to PATH based on shell type
        if [[ "$rc_file" == *".cshrc" ]]; then
            echo "setenv PATH \$PATH:$USER_BIN_DIR" >> "$rc_file"
        else
            echo "export PATH=\"\$PATH:$USER_BIN_DIR\"" >> "$rc_file"
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
export ANTHROPIC_MODEL="glm-4.7"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flashx"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-47"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_MODEL": "glm-4.7",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7-flashx"
  }
}
SETTINGS

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

    chmod +x "$wrapper_path"
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
export ANTHROPIC_MODEL="glm-4.5"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flashx"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-45"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_MODEL": "glm-4.5",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7-flashx"
  }
}
SETTINGS

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

    chmod +x "$wrapper_path"
    echo "✅ Installed claude-glm-4.5 at $wrapper_path"
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
export ANTHROPIC_MODEL="glm-4.6"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flashx"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-46"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_MODEL": "glm-4.6",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7-flashx"
  }
}
SETTINGS

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

    chmod +x "$wrapper_path"
    echo "✅ Installed claude-glm-4.6 at $wrapper_path"
}

# Create GLM-5 wrapper
create_claude_glm_5_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-5"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-5 - Claude Code with Z.AI GLM-5 (Latest Model)

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_MODEL="glm-5"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flashx"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-5"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_MODEL": "glm-5",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7-flashx"
  }
}
SETTINGS

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-5 (Latest Model)..."
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

    chmod +x "$wrapper_path"
    echo "✅ Installed claude-glm-5 at $wrapper_path"
}

# Create GLM-5.1 wrapper
create_claude_glm_51_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-5.1"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-5.1 - Claude Code with Z.AI GLM-5.1 (Latest Model)

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_MODEL="glm-5.1"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flashx"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-51"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM configuration
cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_MODEL": "glm-5.1",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7-flashx"
  }
}
SETTINGS

# Launch Claude Code with custom config
echo "🚀 Starting Claude Code with GLM-5.1 (Latest Model)..."
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

    chmod +x "$wrapper_path"
    echo "✅ Installed claude-glm-5.1 at $wrapper_path"
}

# Create fast GLM-4.7-flashx wrapper
create_claude_glm_fast_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-glm-fast"

    cat > "$wrapper_path" << EOF
#!/bin/bash
# Claude-GLM-Fast - Claude Code with Z.AI GLM-4.7-flashx (Fast Model)

# Set Z.AI environment variables
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
export ANTHROPIC_MODEL="glm-4.7-flashx"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flashx"

# Use custom config directory to avoid conflicts
export CLAUDE_HOME="\$HOME/.claude-glm-fast"

# Create config directory if it doesn't exist
mkdir -p "\$CLAUDE_HOME"

# Create/update settings file with GLM-Air configuration
cat > "\$CLAUDE_HOME/settings.json" << SETTINGS
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_MODEL": "glm-4.7-flashx",
    "ANTHROPIC_SMALL_FAST_MODEL": "glm-4.7-flashx"
  }
}
SETTINGS

# Launch Claude Code with custom config
echo "⚡ Starting Claude Code with GLM-4.7-flashx (Fast Model)..."
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

    chmod +x "$wrapper_path"
    echo "✅ Installed claude-glm-fast at $wrapper_path"
}

# Create Anthropic wrapper
create_claude_anthropic_wrapper() {
    local wrapper_path="$USER_BIN_DIR/claude-anthropic"

    cat > "$wrapper_path" << 'EOF'
#!/bin/bash
# Claude-Anthropic - Claude Code with original Anthropic models

# Clear any Z.AI environment variables
unset ANTHROPIC_BASE_URL
unset ANTHROPIC_AUTH_TOKEN
unset ANTHROPIC_MODEL
unset ANTHROPIC_SMALL_FAST_MODEL

# Use default Claude config directory
unset CLAUDE_HOME

echo "🚀 Starting Claude Code with Anthropic Claude models..."
echo ""

# Check if claude exists
if ! command -v claude &> /dev/null; then
    echo "❌ Error: 'claude' command not found!"
    echo "Please ensure Claude Code is installed and in your PATH"
    exit 1
fi

# Run actual claude command
claude "$@"
EOF

    chmod +x "$wrapper_path"
    echo "✅ Installed claude-anthropic at $wrapper_path"
}

# Create shell aliases
create_shell_aliases() {
    local rc_file=$(detect_shell_rc)

    if [ -z "$rc_file" ]; then
        echo "⚠️  Could not detect shell rc file, skipping aliases"
        return
    fi

    remove_aliases_from_rc() {
        local target_rc="$1"

        if [ -z "$target_rc" ] || [ ! -f "$target_rc" ]; then
            return
        fi

        # Remove old aliases if they exist
        if grep -q "# Claude Code Model Switcher Aliases" "$target_rc" 2>/dev/null; then
            # Use temp file for compatibility
            grep -v "# Claude Code Model Switcher Aliases" "$target_rc" | \
            grep -v "alias ccd=" | \
            grep -v "alias ccdD=" | \
            grep -v "alias ccdDd=" | \
            grep -v "alias claudeD=" | \
            grep -v "alias claudeDd=" | \
            grep -v "alias ccg45=" | \
            grep -v "alias ccg45D=" | \
            grep -v "alias ccg45Dd=" | \
            grep -v "alias ccg46=" | \
            grep -v "alias ccg46D=" | \
            grep -v "alias ccg46Dd=" | \
            grep -v "alias ccg47=" | \
            grep -v "alias ccg47D=" | \
            grep -v "alias ccg47Dd=" | \
            grep -v "alias ccg5=" | \
            grep -v "alias ccg5D=" | \
            grep -v "alias ccg5Dd=" | \
            grep -v "alias ccg51=" | \
            grep -v "alias ccg51D=" | \
            grep -v "alias ccg51Dd=" | \
            grep -v "alias ccf=" | \
            grep -v "alias ccx=" > "$target_rc.tmp"
            mv "$target_rc.tmp" "$target_rc"
        fi
    }

    add_aliases_to_rc() {
        local target_rc="$1"
        local shell_style="$2"

        if [ -z "$target_rc" ]; then
            return
        fi

        if [ ! -f "$target_rc" ]; then
            touch "$target_rc" 2>/dev/null || return
        fi

        remove_aliases_from_rc "$target_rc"

        if [ "$shell_style" = "csh" ]; then
            cat >> "$target_rc" << 'EOF'

# Claude Code Model Switcher Aliases
alias ccd 'claude'
alias ccdD 'claude --dangerously-skip-permissions'
alias ccdDd 'claude --dangerously-skip-permissions -d'
alias claudeD 'claude --dangerously-skip-permissions'
alias claudeDd 'claudeD -d'
alias ccg45 'claude-glm-4.5'
alias ccg45D 'ccg45 --dangerously-skip-permissions'
alias ccg45Dd 'ccg45 --dangerously-skip-permissions -d'
alias ccg46 'claude-glm-4.6'
alias ccg46D 'ccg46 --dangerously-skip-permissions'
alias ccg46Dd 'ccg46 --dangerously-skip-permissions -d'
alias ccg47 'claude-glm-4.7'
alias ccg47D 'ccg47 --dangerously-skip-permissions'
alias ccg47Dd 'ccg47 --dangerously-skip-permissions -d'
alias ccg5 'claude-glm-5'
alias ccg5D 'ccg5 --dangerously-skip-permissions'
alias ccg5Dd 'ccg5 --dangerously-skip-permissions -d'
alias ccg51 'claude-glm-5.1'
alias ccg51D 'ccg51 --dangerously-skip-permissions'
alias ccg51Dd 'ccg51 --dangerously-skip-permissions -d'
alias ccf 'claude-glm-fast'
EOF
        else
            cat >> "$target_rc" << 'EOF'

# Claude Code Model Switcher Aliases
alias ccd='claude'
alias ccdD='claude --dangerously-skip-permissions'
alias ccdDd='claude --dangerously-skip-permissions -d'
alias claudeD='claude --dangerously-skip-permissions'
alias claudeDd='claudeD -d'
alias ccg45='claude-glm-4.5'
alias ccg45D='ccg45 --dangerously-skip-permissions'
alias ccg45Dd='ccg45 --dangerously-skip-permissions -d'
alias ccg46='claude-glm-4.6'
alias ccg46D='ccg46 --dangerously-skip-permissions'
alias ccg46Dd='ccg46 --dangerously-skip-permissions -d'
alias ccg47='claude-glm-4.7'
alias ccg47D='ccg47 --dangerously-skip-permissions'
alias ccg47Dd='ccg47 --dangerously-skip-permissions -d'
alias ccg5='claude-glm-5'
alias ccg5D='ccg5 --dangerously-skip-permissions'
alias ccg5Dd='ccg5 --dangerously-skip-permissions -d'
alias ccg51='claude-glm-5.1'
alias ccg51D='ccg51 --dangerously-skip-permissions'
alias ccg51Dd='ccg51 --dangerously-skip-permissions -d'
alias ccf='claude-glm-fast'
EOF
        fi
    }

    if [[ "$rc_file" == *".cshrc" ]]; then
        add_aliases_to_rc "$rc_file" "csh"
    else
        add_aliases_to_rc "$rc_file" "bash"
    fi

    if [ "$HOME/.bashrc" != "$rc_file" ]; then
        add_aliases_to_rc "$HOME/.bashrc" "bash"
    fi

    echo "✅ Added aliases to $rc_file"
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
    check_claude_installation

    # Setup user bin directory
    setup_user_bin
    verify_user_bin_path

    # Clean up old installations from different locations
    cleanup_old_wrappers

    rm -f "$USER_BIN_DIR/ccx" 2>/dev/null || true

    # Check if already installed
    if [ -f "$USER_BIN_DIR/claude-glm-5.1" ] || [ -f "$USER_BIN_DIR/claude-glm-5" ] || [ -f "$USER_BIN_DIR/claude-glm-4.7" ] || [ -f "$USER_BIN_DIR/claude-glm-4.6" ] || [ -f "$USER_BIN_DIR/claude-glm-4.5" ] || [ -f "$USER_BIN_DIR/claude-glm-fast" ]; then
        echo ""
        echo "✅ Existing installation detected!"
        echo "1) Update API key only"
        echo "2) Reset wrappers/aliases using existing API key"
        echo "3) Reinstall everything"
        echo "4) Cancel"
        read -p "Choice (1-4): " update_choice

        case "$update_choice" in
            1)
                read -p "Enter your Z.AI API key: " input_key
                if [ -n "$input_key" ]; then
                    ZAI_API_KEY="$input_key"
                    create_claude_glm_45_wrapper
                    create_claude_glm_46_wrapper
                    create_claude_glm_47_wrapper
                    create_claude_glm_5_wrapper
                    create_claude_glm_51_wrapper
                    create_claude_glm_fast_wrapper
                    create_shell_aliases
                    echo "✅ API key updated!"
                    exit 0
                fi
                ;;
            2)
                local existing_key
                existing_key=$(detect_existing_zai_api_key 2>/dev/null || true)
                if [ -z "$existing_key" ]; then
                    read -p "Enter your Z.AI API key: " input_key
                    if [ -z "$input_key" ]; then
                        exit 0
                    fi
                    existing_key="$input_key"
                fi

                ZAI_API_KEY="$existing_key"
                create_claude_glm_45_wrapper
                create_claude_glm_46_wrapper
                create_claude_glm_47_wrapper
                create_claude_glm_5_wrapper
                create_claude_glm_51_wrapper
                create_claude_glm_fast_wrapper
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
    read -p "API Key: " input_key

    if [ -n "$input_key" ]; then
        ZAI_API_KEY="$input_key"
        echo "✅ API key received (${#input_key} characters)"
    else
        echo "⚠️  No API key provided. Add it manually later to:"
        echo "   $USER_BIN_DIR/claude-glm-4.5"
        echo "   $USER_BIN_DIR/claude-glm-4.6"
        echo "   $USER_BIN_DIR/claude-glm-4.7"
        echo "   $USER_BIN_DIR/claude-glm-5"
        echo "   $USER_BIN_DIR/claude-glm-5.1"
        echo "   $USER_BIN_DIR/claude-glm-fast"
    fi

    # Create wrappers
    create_claude_glm_45_wrapper
    create_claude_glm_46_wrapper
    create_claude_glm_47_wrapper
    create_claude_glm_5_wrapper
    create_claude_glm_51_wrapper
    create_claude_glm_fast_wrapper
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
    echo "   claude-glm-4.5   - GLM-4.5"
    echo "   claude-glm-4.6   - GLM-4.6"
    echo "   claude-glm-4.7   - GLM-4.7"
    echo "   claude-glm-5     - GLM-5"
    echo "   claude-glm-5.1   - GLM-5.1 (latest)"
    echo "   claude-glm-fast  - GLM-4.7-flashx (fast)"
    echo ""
    echo "Aliases:"
    echo "   ccd    - claude (regular Claude / default)"
    echo "   ccdD   - claude --dangerously-skip-permissions"
    echo "   ccdDd  - claude --dangerously-skip-permissions -d"
    echo "   ccg45  - claude-glm-4.5 (GLM-4.5)"
    echo "   ccg46  - claude-glm-4.6 (GLM-4.6)"
    echo "   ccg47  - claude-glm-4.7 (GLM-4.7)"
    echo "   ccg5   - claude-glm-5 (GLM-5)"
    echo "   ccg51  - claude-glm-5.1 (GLM-5.1)"
    echo "   ccf    - claude-glm-fast"
    echo ""

    if [ "$ZAI_API_KEY" = "YOUR_ZAI_API_KEY_HERE" ]; then
        echo "⚠️  Don't forget to add your API key to:"
        echo "   $USER_BIN_DIR/claude-glm-4.5"
        echo "   $USER_BIN_DIR/claude-glm-4.6"
        echo "   $USER_BIN_DIR/claude-glm-4.7"
        echo "   $USER_BIN_DIR/claude-glm-5"
        echo "   $USER_BIN_DIR/claude-glm-5.1"
        echo "   $USER_BIN_DIR/claude-glm-fast"
    fi

    echo ""
    echo "📁 Installation location: $USER_BIN_DIR"
    echo "📁 Config directories: ~/.claude-glm-45, ~/.claude-glm-46, ~/.claude-glm-47, ~/.claude-glm-5, ~/.claude-glm-51, ~/.claude-glm-fast"
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
    local test_error_message="This is a test error to verify error reporting works correctly"
    local test_error_line="Test mode - no actual error"

    report_error "$test_error_message" "$test_error_line" "0"

    echo "✅ Test complete. If a browser window opened, error reporting is working!"
    echo ""
    echo "To run normal installation, use:"
    echo "   curl -fsSL https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.sh | bash"
    echo ""
    echo "Press Enter to finish (window will remain open)..."
    read
    # Script ends naturally here - terminal stays open
    exit 0
fi

# Set up error handling
set -eE  # Exit on error, inherit ERR trap in functions
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# Only run installation if not in test mode
if [ "$TEST_ERROR" != true ]; then
    # Run installation
    main "$@"
fi
