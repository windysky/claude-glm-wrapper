# Claude-GLM PowerShell Installer for Windows
# Works without admin rights, installs to user's profile directory
#
# Usage with parameters when downloading:
#   Test error reporting:
#     $env:CLAUDE_GLM_TEST_ERROR=1; iwr -useb https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.ps1 | iex; $env:CLAUDE_GLM_TEST_ERROR=$null
#
#   Enable debug mode:
#     $env:CLAUDE_GLM_DEBUG=1; iwr -useb https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.ps1 | iex; $env:CLAUDE_GLM_DEBUG=$null
#
# Usage when running locally:
#   .\install.ps1 -TestError
#   .\install.ps1 -Debug

param(
    [switch]$TestError,
    [switch]$Debug
)

# Support environment variables for parameters when using iwr | iex
if ($env:CLAUDE_GLM_TEST_ERROR -eq "1" -or $env:CLAUDE_GLM_TEST_ERROR -eq "true") {
    $TestError = $true
}
if ($env:CLAUDE_GLM_DEBUG -eq "1" -or $env:CLAUDE_GLM_DEBUG -eq "true") {
    $Debug = $true
}

# Configuration
$UserBinDir = "$env:USERPROFILE\.local\bin"
$CmdShimDir = Join-Path $env:USERPROFILE "AppData\Local\Microsoft\WindowsApps"
$Glm45ConfigDir = "$env:USERPROFILE\.claude-glm-45"
$Glm45vConfigDir = "$env:USERPROFILE\.claude-glm-45v"
$Glm45airConfigDir = "$env:USERPROFILE\.claude-glm-45-air"
$Glm46ConfigDir = "$env:USERPROFILE\.claude-glm-46"
$Glm47ConfigDir = "$env:USERPROFILE\.claude-glm-47"
$Glm5ConfigDir = "$env:USERPROFILE\.claude-glm-5"
$Glm5tConfigDir = "$env:USERPROFILE\.claude-glm-5-turbo"
$Glm51ConfigDir = "$env:USERPROFILE\.claude-glm-51"
$Glm52ConfigDir = "$env:USERPROFILE\.claude-glm-52"
$GlmFastConfigDir = "$env:USERPROFILE\.claude-glm-fast"
$ZaiApiKey = "YOUR_ZAI_API_KEY_HERE"

# Debug logging
function Write-DebugLog {
    param([string]$Message)
    if ($Debug) {
        Write-Host "DEBUG: $Message" -ForegroundColor Gray
    }
}

# Find all existing wrapper installations
function Find-AllInstallations {
    Write-DebugLog "Searching for existing installations..."
    $locations = @(
        "$env:USERPROFILE\.local\bin",
        "$env:ProgramFiles\Claude-GLM",
        "$env:LOCALAPPDATA\Programs\claude-glm",
        "C:\Program Files\Claude-GLM"
    )

    $foundFiles = @()

    foreach ($location in $locations) {
        Write-DebugLog "Checking location: $location"
        if (Test-Path $location) {
            # Find all claude-glm*.ps1 files in this location
            try {
                $files = Get-ChildItem -Path $location -Filter "claude-glm*.ps1" -ErrorAction Stop
                foreach ($file in $files) {
                    Write-DebugLog "Found: $($file.FullName)"
                    $foundFiles += $file.FullName
                }
            } catch {
                Write-DebugLog "Could not access $location : $_"
                # Continue searching other locations
            }
        }
    }

    Write-DebugLog "Total installations found: $($foundFiles.Count)"
    return $foundFiles
}

# Clean up old wrapper installations
function Remove-OldWrappers {
    $currentLocation = $UserBinDir
    $allWrappers = Find-AllInstallations

    if ($allWrappers.Count -eq 0) {
        return
    }

    # Separate current location files from old ones
    $oldWrappers = @()
    $currentWrappers = @()

    foreach ($wrapper in $allWrappers) {
        if ($wrapper -like "$currentLocation*") {
            $currentWrappers += $wrapper
        } else {
            $oldWrappers += $wrapper
        }
    }

    # If no old wrappers found, nothing to clean
    if ($oldWrappers.Count -eq 0) {
        return
    }

    Write-Host ""
    Write-Host "SEARCH: Found existing wrappers in multiple locations:"
    Write-Host ""

    foreach ($wrapper in $oldWrappers) {
        Write-Host "  REMOVED: $wrapper (old location)"
    }

    if ($currentWrappers.Count -gt 0) {
        foreach ($wrapper in $currentWrappers) {
            Write-Host "  OK: $wrapper (current location)"
        }
    }

    Write-Host ""
    $cleanupChoice = Read-Host "Would you like to clean up old installations? (y/n)"

    if ($cleanupChoice -eq "y" -or $cleanupChoice -eq "Y") {
        Write-Host ""
        Write-Host "Removing old wrappers..."
        foreach ($wrapper in $oldWrappers) {
            try {
                Remove-Item -Path $wrapper -Force -ErrorAction Stop
                Write-Host "  OK: Removed: $wrapper"
            } catch {
                Write-Host "  WARNING: Could not remove: $wrapper (permission denied)"
            }
        }
        Write-Host ""
        Write-Host "OK: Cleanup complete!"
    } else {
        Write-Host ""
        Write-Host "WARNING: Skipping cleanup. Old wrappers may interfere with the new installation."
        Write-Host "   You may want to manually remove them later."
    }

    Write-Host ""
}

# Setup user bin directory and add to PATH
function Setup-UserBin {
    # Create user bin directory
    if (-not (Test-Path $UserBinDir)) {
        New-Item -ItemType Directory -Path $UserBinDir -Force | Out-Null
    }

    # Check if PATH includes user bin
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$UserBinDir*") {
        Write-Host "INFO: Adding $UserBinDir to PATH..."

        # Add to user PATH
        $newPath = if ($currentPath) { "$currentPath;$UserBinDir" } else { $UserBinDir }
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")

        # Update current session PATH
        $env:PATH = "$env:PATH;$UserBinDir"

        Write-Host ""
        Write-Host "WARNING: IMPORTANT: PATH has been updated for future sessions."
        Write-Host "   For this session, restart PowerShell or run: `$env:PATH += ';$UserBinDir'"
        Write-Host ""
    }
}

function Test-UserBinInPath {
    if ($env:PATH -notlike "*$UserBinDir*") {
        Write-Host "WARNING: $UserBinDir is not in PATH for this session."
        Write-Host "   Restart PowerShell or run: `$env:PATH += ';$UserBinDir'"
        Write-Host ""
    }
}
# Add aliases to PowerShell profile
function Add-PowerShellAliases {
    # Ensure profile exists
    if (-not (Test-Path $PROFILE)) {
        $profileDir = Split-Path $PROFILE
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    }

    # Read current profile
    $profileContent = @()
    if (Test-Path $PROFILE) {
        try {
            $profileContent = Get-Content $PROFILE -ErrorAction Stop
            $lineCount = $profileContent.Count
            Write-DebugLog "Read existing profile with $lineCount lines"
        } catch {
            Write-DebugLog "Could not read profile: $_"
            $profileContent = @()
        }
    }

    # Remove old aliases if they exist.
    # User-curated claude aliases are preserved by default; ONLY auto-installed claude
    # aliases from the legacy wrapper version are scrubbed via fingerprint detection
    # (presence of 'function ccdDd' AND 'function claudeDd' self-references).
    $hasCcdDdFunction = @($profileContent | Where-Object { $_ -match '^\s*function\s+ccdDd\b' }).Count -gt 0
    $hasClaudeDdFunction = @($profileContent | Where-Object { $_ -match '^\s*function\s+claudeDd\b' }).Count -gt 0
    $legacyClaudeFingerprint = $hasCcdDdFunction -and $hasClaudeDdFunction
    if ($legacyClaudeFingerprint) {
        Write-Host "INFO: Detected legacy claude alias block from previous wrapper version - migrating."
    }

    # Patterns owned by this installer - always stripped on every run.
    # Strings are matched as regex via -match (substrings without anchors
    # match anywhere in the line; explicit ^ anchors match line start).
    $installerOwnedPatterns = @(
        "# Claude Code Model Switcher Aliases",
        "# Claude-GLM Model Switcher Aliases",
        "# Claude Code Danger Skip Aliases",
        "# Claude-GLM Danger Skip Aliases",
        "# ccx multi-provider proxy function",
        "Set-Alias ccg ",
        "Set-Alias ccg51 ",
        "Set-Alias ccg52 ",
        "Set-Alias ccg5t ",
        "Set-Alias ccg5 ",
        "Set-Alias ccg47 ",
        "Set-Alias ccg46 ",
        "Set-Alias ccg45air ",
        "Set-Alias ccg45v ",
        "Set-Alias ccg45 ",
        "Set-Alias ccf ",
        '^\s*function\s+ccx\b',
        '\\ccx\.ps1',
        '^\s*function\s+ccgD\b',
        '^\s*function\s+ccgDd\b',
        '^\s*function\s+ccg45D\b',
        '^\s*function\s+ccg45Dd\b',
        '^\s*function\s+ccg45vD\b',
        '^\s*function\s+ccg45vDd\b',
        '^\s*function\s+ccg45airD\b',
        '^\s*function\s+ccg45airDd\b',
        '^\s*function\s+ccg46D\b',
        '^\s*function\s+ccg46Dd\b',
        '^\s*function\s+ccg47D\b',
        '^\s*function\s+ccg47Dd\b',
        '^\s*function\s+ccg5D\b',
        '^\s*function\s+ccg5Dd\b',
        '^\s*function\s+ccg5tD\b',
        '^\s*function\s+ccg5tDd\b',
        '^\s*function\s+ccg51D\b',
        '^\s*function\s+ccg51Dd\b',
        '^\s*function\s+ccg52D\b',
        '^\s*function\s+ccg52Dd\b'
    )

    # Legacy claude alias patterns - stripped only when fingerprint detected.
    $legacyClaudePatterns = @(
        '^Set-Alias ccd ',
        '^\s*function\s+ccdD\b',
        '^\s*function\s+ccdDd\b',
        '^\s*function\s+claudeD\b',
        '^\s*function\s+claudeDd\b'
    )

    $filteredContent = $profileContent | Where-Object {
        $line = $_

        foreach ($pattern in $installerOwnedPatterns) {
            if ($line -match $pattern) { return $false }
        }

        if ($legacyClaudeFingerprint) {
            foreach ($pattern in $legacyClaudePatterns) {
                if ($line -match $pattern) { return $false }
            }
        }

        return $true
    }

    # Add new aliases
    # claude itself and any claude-only aliases are intentionally left untouched.
    $aliases = @"

# Claude-GLM Model Switcher Aliases
Set-Alias ccg claude-glm-5.2
Set-Alias ccg5 claude-glm
Set-Alias ccg5t claude-glm-5-turbo
Set-Alias ccg51 claude-glm-5.1
Set-Alias ccg52 claude-glm-5.2
Set-Alias ccg47 claude-glm-4.7
Set-Alias ccg46 claude-glm-4.6
Set-Alias ccg45 claude-glm-4.5
Set-Alias ccg45v claude-glm-4.5v
Set-Alias ccg45air claude-glm-4.5-air
Set-Alias ccf claude-glm-fast

# Claude-GLM Danger Skip Aliases
function ccgD { ccg --dangerously-skip-permissions @args }
function ccgDd { ccg --dangerously-skip-permissions -d @args }
function ccg45D { ccg45 --dangerously-skip-permissions @args }
function ccg45Dd { ccg45 --dangerously-skip-permissions -d @args }
function ccg45vD { ccg45v --dangerously-skip-permissions @args }
function ccg45vDd { ccg45v --dangerously-skip-permissions -d @args }
function ccg45airD { ccg45air --dangerously-skip-permissions @args }
function ccg45airDd { ccg45air --dangerously-skip-permissions -d @args }
function ccg46D { ccg46 --dangerously-skip-permissions @args }
function ccg46Dd { ccg46 --dangerously-skip-permissions -d @args }
function ccg47D { ccg47 --dangerously-skip-permissions @args }
function ccg47Dd { ccg47 --dangerously-skip-permissions -d @args }
function ccg5D { ccg5 --dangerously-skip-permissions @args }
function ccg5Dd { ccg5 --dangerously-skip-permissions -d @args }
function ccg5tD { ccg5t --dangerously-skip-permissions @args }
function ccg5tDd { ccg5t --dangerously-skip-permissions -d @args }
function ccg51D { ccg51 --dangerously-skip-permissions @args }
function ccg51Dd { ccg51 --dangerously-skip-permissions -d @args }
function ccg52D { ccg52 --dangerously-skip-permissions @args }
function ccg52Dd { ccg52 --dangerously-skip-permissions -d @args }
"@

    $newContent = $filteredContent + $aliases
    Set-Content -Path $PROFILE -Value $newContent

    Write-Host "OK: Added aliases to PowerShell profile: $PROFILE"
}

function Remove-CcxArtifacts {
    $ccxWrapper = Join-Path $UserBinDir "ccx.ps1"
    if (Test-Path $ccxWrapper) {
        try {
            Remove-Item -Path $ccxWrapper -Force -ErrorAction Stop
            Write-DebugLog "Removed legacy ccx wrapper: $ccxWrapper"
        } catch {
            Write-DebugLog "Could not remove legacy ccx wrapper: $ccxWrapper : $_"
        }
    }

    $ccxShim = Join-Path $CmdShimDir "ccx.cmd"
    if (Test-Path $ccxShim) {
        try {
            Remove-Item -Path $ccxShim -Force -ErrorAction Stop
            Write-DebugLog "Removed legacy ccx CMD shim: $ccxShim"
        } catch {
            Write-DebugLog "Could not remove legacy ccx CMD shim: $ccxShim : $_"
        }
    }
}

function Remove-DangerSkipArtifacts {
    # No longer removing danger-skip shims -- they are actively used
}

function Get-ExistingZaiApiKey {
    $wrapperPaths = @(
        (Join-Path $UserBinDir "claude-glm-5.2.ps1"),
        (Join-Path $UserBinDir "claude-glm-5.1.ps1"),
        (Join-Path $UserBinDir "claude-glm-5-turbo.ps1"),
        (Join-Path $UserBinDir "claude-glm.ps1"),
        (Join-Path $UserBinDir "claude-glm-4.7.ps1"),
        (Join-Path $UserBinDir "claude-glm-4.6.ps1"),
        (Join-Path $UserBinDir "claude-glm-4.5v.ps1"),
        (Join-Path $UserBinDir "claude-glm-4.5-air.ps1"),
        (Join-Path $UserBinDir "claude-glm-4.5.ps1"),
        (Join-Path $UserBinDir "claude-glm-fast.ps1")
    )

    foreach ($path in $wrapperPaths) {
        if (Test-Path $path) {
            $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
            if ($content -match 'ANTHROPIC_AUTH_TOKEN\s*=\s*"([^"]+)"') {
                $key = $matches[1]
                if ($key -and $key -ne "YOUR_ZAI_API_KEY_HERE") {
                    return $key
                }
            }
        }
    }

    $settingsPaths = @(
        (Join-Path $Glm52ConfigDir "settings.json"),
        (Join-Path $Glm51ConfigDir "settings.json"),
        (Join-Path $Glm5tConfigDir "settings.json"),
        (Join-Path $Glm5ConfigDir "settings.json"),
        (Join-Path $Glm47ConfigDir "settings.json"),
        (Join-Path $Glm46ConfigDir "settings.json"),
        (Join-Path $Glm45vConfigDir "settings.json"),
        (Join-Path $Glm45airConfigDir "settings.json"),
        (Join-Path $Glm45ConfigDir "settings.json"),
        (Join-Path $GlmFastConfigDir "settings.json")
    )

    foreach ($path in $settingsPaths) {
        if (Test-Path $path) {
            $content = Get-Content $path -Raw -ErrorAction SilentlyContinue
            if ($content -match '"ANTHROPIC_AUTH_TOKEN"\s*:\s*"([^"]+)"') {
                $key = $matches[1]
                if ($key -and $key -ne "YOUR_ZAI_API_KEY_HERE") {
                    return $key
                }
            }
        }
    }

    return $null
}

# Create the GLM-5 wrapper (latest)
function New-ClaudeGlmWrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm.ps1"

    # Build wrapper content using array and join to avoid nested here-strings
    $wrapperContent = @(
        '# Claude-GLM - Claude Code with Z.AI GLM-5 (Latest Model)',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm5ConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-5`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-5`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "LAUNCH: Starting Claude Code with GLM-5 (Latest Model)..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-5-Turbo wrapper
function New-ClaudeGlm5tWrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-5-turbo.ps1"

    $wrapperContent = @(
        '# Claude-GLM-5-Turbo - Claude Code with Z.AI GLM-5-Turbo',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5-turbo"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5-turbo"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm5tConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-5-turbo`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-5-turbo`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "TURBO: Starting Claude Code with GLM-5-Turbo..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-5-turbo at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-4.7 wrapper
function New-ClaudeGlm47Wrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-4.7.ps1"

    # Build wrapper content using array and join to avoid nested here-strings
    $wrapperContent = @(
        '# Claude-GLM-4.7 - Claude Code with Z.AI GLM-4.7 (Standard Model)',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-4.7"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.7"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm47ConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-4.7`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-4.7`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "LAUNCH: Starting Claude Code with GLM-4.7 (Standard Model)..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-4.7 at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-4.5 wrapper
function New-ClaudeGlm45Wrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-4.5.ps1"

    $wrapperContent = @(
        '# Claude-GLM-4.5 - Claude Code with Z.AI GLM-4.5',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-4.5"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.5"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm45ConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-4.5`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-4.5`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "LAUNCH: Starting Claude Code with GLM-4.5..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-4.5 at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-4.5V (vision) wrapper
function New-ClaudeGlm45vWrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-4.5v.ps1"

    $wrapperContent = @(
        '# Claude-GLM-4.5V - Claude Code with Z.AI GLM-4.5V (Vision)',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-4.5v"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.5v"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm45vConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-4.5v`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-4.5v`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "VISION: Starting Claude Code with GLM-4.5V (Vision)..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-4.5v at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-4.5-Air wrapper
function New-ClaudeGlm45airWrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-4.5-air.ps1"

    $wrapperContent = @(
        '# Claude-GLM-4.5-Air - Claude Code with Z.AI GLM-4.5-Air',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-4.5-air"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.5-air"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm45airConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-4.5-air`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-4.5-air`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "AIR: Starting Claude Code with GLM-4.5-Air..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-4.5-air at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-4.6 wrapper
function New-ClaudeGlm46Wrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-4.6.ps1"

    $wrapperContent = @(
        '# Claude-GLM-4.6 - Claude Code with Z.AI GLM-4.6',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-4.6"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.6"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm46ConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-4.6`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-4.6`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "LAUNCH: Starting Claude Code with GLM-4.6..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-4.6 at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-5.1 wrapper
function New-ClaudeGlm51Wrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-5.1.ps1"

    $wrapperContent = @(
        '# Claude-GLM-5.1 - Claude Code with Z.AI GLM-5.1 (Latest Model)',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.1"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.1"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm51ConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-5.1`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-5.1`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "LAUNCH: Starting Claude Code with GLM-5.1 (Latest Model)..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-5.1 at $wrapperPath" -ForegroundColor Green
}

# Create the GLM-5.2 wrapper (default, 1M context)
function New-ClaudeGlm52Wrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-5.2.ps1"

    $wrapperContent = @(
        '# Claude-GLM-5.2 - Claude Code with Z.AI GLM-5.2 (Default, 1M context)',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.2[1m]"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5.2[1m]"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = "1000000"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$Glm52ConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-5.2[1m]`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-5.2[1m]`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`",`"CLAUDE_CODE_AUTO_COMPACT_WINDOW`":`"1000000`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "LAUNCH: Starting Claude Code with GLM-5.2 (Default, 1M context)..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-5.2 at $wrapperPath" -ForegroundColor Green
}

# Create the fast GLM-4.5-Air wrapper
function New-ClaudeGlmFastWrapper {
    $wrapperPath = Join-Path $UserBinDir "claude-glm-fast.ps1"

    # Build wrapper content using array and join to avoid nested here-strings
    $wrapperContent = @(
        '# Claude-GLM-Fast - Claude Code with Z.AI GLM-4.5-Air (Fast Model)',
        '',
        '# Set Z.AI environment variables',
        '$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"',
        "`$env:ANTHROPIC_AUTH_TOKEN = `"$ZaiApiKey`"",
        '$env:ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-4.5-air"',
        '$env:ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-4.5-air"',
        '$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"',
        '',
        '# Use custom config directory to avoid conflicts',
        "`$env:CLAUDE_HOME = `"$GlmFastConfigDir`"",
        '',
        '# Create config directory if it doesn''t exist',
        'if (-not (Test-Path $env:CLAUDE_HOME)) {',
        '    New-Item -ItemType Directory -Path $env:CLAUDE_HOME -Force | Out-Null',
        '}',
        '',
        '# Create/update settings file with GLM configuration',
        '$settingsJson = "{`"env`":{`"ANTHROPIC_BASE_URL`":`"https://api.z.ai/api/anthropic`",`"ANTHROPIC_AUTH_TOKEN`":`"' + $ZaiApiKey + '`",`"ANTHROPIC_DEFAULT_OPUS_MODEL`":`"glm-4.5-air`",`"ANTHROPIC_DEFAULT_SONNET_MODEL`":`"glm-4.5-air`",`"ANTHROPIC_DEFAULT_HAIKU_MODEL`":`"glm-4.5-air`"}}"',
        'Set-Content -Path (Join-Path $env:CLAUDE_HOME "settings.json") -Value $settingsJson -Encoding UTF8',
        '',
        '# Launch Claude Code with custom config',
        'Write-Host "FAST: Starting Claude Code with GLM-4.5-Air (Fast Model)..."',
        'Write-Host "CONFIG: Config directory: $env:CLAUDE_HOME"',
        'Write-Host ""',
        '',
        '# Check if claude exists',
        'if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {',
        '    Write-Host "ERROR: ''claude'' command not found!"',
        '    Write-Host "Please ensure Claude Code is installed and in your PATH"',
        '    exit 1',
        '}',
        '',
        '# Run the actual claude command',
        '& claude $args'
    ) -join "`n"

    Set-Content -Path $wrapperPath -Value $wrapperContent
    Write-Host "OK: Installed claude-glm-fast at $wrapperPath" -ForegroundColor Green
}

# Remove deprecated GLM wrappers and command shims
function Remove-DeprecatedGlmArtifacts {
    # GLM-4.6 was previously deprecated but has since been restored.
    # This function intentionally performs no removal; kept as a hook
    # for any future deprecations.
    $deprecatedWrappers = @()

    foreach ($wrapper in $deprecatedWrappers) {
        if (Test-Path $wrapper) {
            try {
                Remove-Item -Path $wrapper -Force -ErrorAction Stop
                Write-DebugLog "Removed deprecated wrapper: $wrapper"
            } catch {
                Write-DebugLog "Could not remove deprecated wrapper: $wrapper : $_"
            }
        }
    }

    $deprecatedShims = @()
    foreach ($name in $deprecatedShims) {
        $shimPath = Join-Path $CmdShimDir "$name.cmd"
        if (Test-Path $shimPath) {
            try {
                Remove-Item -Path $shimPath -Force -ErrorAction Stop
                Write-DebugLog "Removed deprecated CMD shim: $shimPath"
            } catch {
                Write-DebugLog "Could not remove deprecated CMD shim: $shimPath : $_"
            }
        }
    }
}

# Create .cmd shims so commands also work in cmd/Anaconda
function New-CmdShim {
    param(
        [string]$Name,
        [string]$TargetScript,
        [string]$ExtraArgs = ""
    )

    if (-not (Test-Path $CmdShimDir)) {
        try {
            New-Item -ItemType Directory -Path $CmdShimDir -Force | Out-Null
        } catch {
            Write-Host "WARNING: Could not create CMD shim directory at $CmdShimDir" -ForegroundColor Yellow
            return
        }
    }

    $shimPath = Join-Path $CmdShimDir "$Name.cmd"

    $shimContent = if ([string]::IsNullOrWhiteSpace($ExtraArgs)) {
        "@echo off`r`npowershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$TargetScript`" %*`r`n"
    } else {
        "@echo off`r`npowershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$TargetScript`" $ExtraArgs %*`r`n"
    }

    try {
        Set-Content -Path $shimPath -Value $shimContent -Encoding ascii
        Write-Host "OK: Created CMD shim: $shimPath" -ForegroundColor Green
    } catch {
        Write-Host "WARNING: Failed to create CMD shim for $Name at $shimPath" -ForegroundColor Yellow
    }
}

function Add-CmdShims {
    Remove-DeprecatedGlmArtifacts
    Remove-DangerSkipArtifacts
    # Ensure the main wrappers exist before creating shims
    New-CmdShim -Name "ccg"      -TargetScript (Join-Path $UserBinDir "claude-glm-5.2.ps1")
    New-CmdShim -Name "ccg5"     -TargetScript (Join-Path $UserBinDir "claude-glm.ps1")
    New-CmdShim -Name "ccg5t"    -TargetScript (Join-Path $UserBinDir "claude-glm-5-turbo.ps1")
    New-CmdShim -Name "ccg51"    -TargetScript (Join-Path $UserBinDir "claude-glm-5.1.ps1")
    New-CmdShim -Name "ccg52"    -TargetScript (Join-Path $UserBinDir "claude-glm-5.2.ps1")
    New-CmdShim -Name "ccg47"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.7.ps1")
    New-CmdShim -Name "ccg46"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.6.ps1")
    New-CmdShim -Name "ccg45"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.5.ps1")
    New-CmdShim -Name "ccg45v"   -TargetScript (Join-Path $UserBinDir "claude-glm-4.5v.ps1")
    New-CmdShim -Name "ccg45air" -TargetScript (Join-Path $UserBinDir "claude-glm-4.5-air.ps1")
    New-CmdShim -Name "ccf"      -TargetScript (Join-Path $UserBinDir "claude-glm-fast.ps1")

    New-CmdShim -Name "ccgD"       -TargetScript (Join-Path $UserBinDir "claude-glm-5.2.ps1")      -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccgDd"      -TargetScript (Join-Path $UserBinDir "claude-glm-5.2.ps1")      -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg5D"      -TargetScript (Join-Path $UserBinDir "claude-glm.ps1")          -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg5Dd"     -TargetScript (Join-Path $UserBinDir "claude-glm.ps1")          -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg5tD"     -TargetScript (Join-Path $UserBinDir "claude-glm-5-turbo.ps1")  -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg5tDd"    -TargetScript (Join-Path $UserBinDir "claude-glm-5-turbo.ps1")  -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg51D"     -TargetScript (Join-Path $UserBinDir "claude-glm-5.1.ps1")      -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg51Dd"    -TargetScript (Join-Path $UserBinDir "claude-glm-5.1.ps1")      -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg52D"     -TargetScript (Join-Path $UserBinDir "claude-glm-5.2.ps1")      -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg52Dd"    -TargetScript (Join-Path $UserBinDir "claude-glm-5.2.ps1")      -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg47D"     -TargetScript (Join-Path $UserBinDir "claude-glm-4.7.ps1")      -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg47Dd"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.7.ps1")      -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg46D"     -TargetScript (Join-Path $UserBinDir "claude-glm-4.6.ps1")      -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg46Dd"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.6.ps1")      -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg45D"     -TargetScript (Join-Path $UserBinDir "claude-glm-4.5.ps1")      -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg45Dd"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.5.ps1")      -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg45vD"    -TargetScript (Join-Path $UserBinDir "claude-glm-4.5v.ps1")     -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg45vDd"   -TargetScript (Join-Path $UserBinDir "claude-glm-4.5v.ps1")     -ExtraArgs "--dangerously-skip-permissions -d"
    New-CmdShim -Name "ccg45airD"  -TargetScript (Join-Path $UserBinDir "claude-glm-4.5-air.ps1")  -ExtraArgs "--dangerously-skip-permissions"
    New-CmdShim -Name "ccg45airDd" -TargetScript (Join-Path $UserBinDir "claude-glm-4.5-air.ps1")  -ExtraArgs "--dangerously-skip-permissions -d"
}

# Check Claude Code availability
function Test-ClaudeInstallation {
    Write-Host "CHECKING: Claude Code installation..."

    if (Get-Command claude -ErrorAction SilentlyContinue) {
        $claudePath = (Get-Command claude).Source
        Write-Host "OK: Claude Code found at: $claudePath"
        return $true
    } else {
        Write-Host "WARNING: Claude Code not found in PATH"
        Write-Host ""
        Write-Host "Options:"
        Write-Host "1. If Claude Code is installed elsewhere, add it to PATH first"
        Write-Host "2. Install Claude Code from: https://www.anthropic.com/claude-code"
        Write-Host "3. Continue anyway (wrappers will be created but will not work until claude is available)"
        Write-Host ""
        $continue = Read-Host "Continue with installation? (y/n)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Host "Installation cancelled."
            exit 1
        }
        return $false
    }
}

# Report installation errors to GitHub
function Report-Error {
    param(
        [string]$ErrorMessage,
        [string]$ErrorLine = "",
        [object]$ErrorRecord = $null
    )

    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Red
    Write-Host "ERROR: Installation failed!" -ForegroundColor Red
    Write-Host "=============================================" -ForegroundColor Red
    Write-Host ""

    # Collect system information
    $osInfo = try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        "Windows $($os.Version) ($($os.Caption))"
    } catch {
        "Windows (version unknown)"
    }

    $psVersion = $PSVersionTable.PSVersion.ToString()
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"

    # Sanitize error message (remove API keys)
    $sanitizedError = $ErrorMessage -replace 'ANTHROPIC_AUTH_TOKEN\s*=\s*\S+', 'ANTHROPIC_AUTH_TOKEN="[REDACTED]"'
    $sanitizedError = $sanitizedError -replace 'ZaiApiKey\s*=\s*\S+', 'ZaiApiKey="[REDACTED]"'
    $sanitizedError = $sanitizedError -replace '\$ZaiApiKey\s*=\s*"\S+"', '$ZaiApiKey="[REDACTED]"'

    # Display error details to user
    Write-Host "Error Details:" -ForegroundColor Yellow
    Write-Host $sanitizedError -ForegroundColor White
    if ($ErrorLine) {
        Write-Host "Location: $ErrorLine" -ForegroundColor Gray
    }
    Write-Host ""

    # Ask if user wants to report the error
    Write-Host "Would you like to report this error to GitHub?" -ForegroundColor Cyan
    Write-Host "This will open your browser with a pre-filled issue report." -ForegroundColor Gray
    $reportChoice = Read-Host "Report error? (y/n)"
    Write-Host ""

    if ($reportChoice -ne "y" -and $reportChoice -ne "Y") {
        Write-Host "Error not reported. You can get help at:" -ForegroundColor Yellow
        Write-Host "  https://github.com/windysky/claude-glm-wrapper/issues" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Press Enter to close..." -ForegroundColor Gray
        $null = Read-Host
        return
    }

    # Get additional context
    $claudeFound = if (Get-Command claude -ErrorAction SilentlyContinue) { "Yes" } else { "No" }

    # Build error report (using string concatenation to avoid here-string parsing issues)
    $issueBody = "## Installation Error (Windows PowerShell)`n`n"
    $issueBody += "**OS:** $osInfo`n"
    $issueBody += "**PowerShell:** $psVersion`n"
    $issueBody += "**Timestamp:** $timestamp`n`n"
    $issueBody += "### Error Details:`n"
    $issueBody += "``````n"
    $issueBody += "$sanitizedError`n"
    $issueBody += "``````n`n"

    if ($ErrorLine) {
        $issueBody += "**Error Location:** $ErrorLine`n`n"
    }

    $issueBody += "### System Information:`n"
    $issueBody += "- Installation Location: $UserBinDir`n"
    $issueBody += "- Claude Code Found: $claudeFound`n"

    try {
        $execPolicy = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
        $issueBody += "- PowerShell Execution Policy: $execPolicy`n"
    } catch {
        $issueBody += "- PowerShell Execution Policy: Unknown`n"
    }

    $issueBody += "`n### Additional Context:`n"

    if ($ErrorRecord) {
        try {
            $exceptionType = $ErrorRecord.Exception.GetType().FullName
            $category = $ErrorRecord.CategoryInfo.Category
            $issueBody += "- Exception Type: $exceptionType`n"
            $issueBody += "- Category: $category`n"
        } catch {
            $issueBody += "- Additional error details unavailable`n"
        }
    }

    $issueBody += "`n---`n"
    $issueBody += "*This error was automatically reported by the installer. Please add any additional context below.*"

    # URL encode the body (native PowerShell method, no dependencies)
    Write-DebugLog "Encoding error report for URL..."

    # Truncate body if too long (GitHub has URL limits)
    if ($issueBody.Length -gt 5000) {
        $issueBody = $issueBody.Substring(0, 5000) + "`n`n[Report truncated due to length]"
        Write-DebugLog "Truncated error report to 5000 characters"
    }

    # Use native PowerShell URL encoding
    $encodedBody = [uri]::EscapeDataString($issueBody)
    $encodedTitle = [uri]::EscapeDataString("Installation Error: Windows PowerShell")

    $issueUrl = "https://github.com/windysky/claude-glm-wrapper/issues/new?title=$encodedTitle`&body=$encodedBody`&labels=bug,windows,installation"

    Write-Host "INFO: Error details have been prepared for reporting."
    Write-Host ""

    # Try multiple methods to open the browser
    $browserOpened = $false

    Write-DebugLog "Attempting to open browser with Start-Process..."
    try {
        Start-Process $issueUrl -ErrorAction Stop
        $browserOpened = $true
        Write-Host "OK: Browser opened with pre-filled error report." -ForegroundColor Green
    } catch {
        Write-DebugLog "Start-Process failed: $_"
    }

    if (-not $browserOpened) {
        Write-DebugLog "Attempting to open browser with cmd /c start..."
        try {
            & cmd /c start $issueUrl 2>$null
            if ($LASTEXITCODE -eq 0) {
                $browserOpened = $true
                Write-Host "OK: Browser opened with pre-filled error report." -ForegroundColor Green
            }
        } catch {
            Write-DebugLog "cmd /c start failed: $_"
        }
    }

    if (-not $browserOpened) {
        Write-DebugLog "Attempting to open browser with explorer.exe..."
        try {
            & explorer.exe $issueUrl
            $browserOpened = $true
            Write-Host "OK: Browser opened with pre-filled error report." -ForegroundColor Green
        } catch {
            Write-DebugLog "explorer.exe failed: $_"
        }
    }

    if (-not $browserOpened) {
        Write-Host "WARNING: Could not open browser automatically." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please copy and open this URL manually:" -ForegroundColor Yellow
        Write-Host $issueUrl -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Or press Enter to see a shortened URL..." -ForegroundColor Gray
        $null = Read-Host

        # Create a shorter URL with just the title
        $shortUrl = "https://github.com/windysky/claude-glm-wrapper/issues/new?title=$encodedTitle`&labels=bug,windows,installation"
        Write-Host "Shortened URL (add error details manually):" -ForegroundColor Yellow
        Write-Host $shortUrl -ForegroundColor Cyan
    }

    Write-Host ""

    # Add instructions and wait for user
    if ($browserOpened) {
        Write-Host "Please review the error report in your browser and submit the issue." -ForegroundColor Cyan
        Write-Host "After submitting (or if you choose not to), return here." -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Press Enter to continue..." -ForegroundColor Gray
    $null = Read-Host
}

# Main installation
function Install-ClaudeGlm {
    Write-Host "INSTALLER: Claude-GLM PowerShell Installer for Windows"
    Write-Host "==============================================="
    Write-Host ""
    Write-Host "This installer:"
    Write-Host "  * Does NOT require administrator rights"
    Write-Host "  * Installs to: $UserBinDir"
    Write-Host "  * Works on Windows systems"
    Write-Host ""

    if ($Debug) {
        Write-Host "DEBUG: Debug mode enabled" -ForegroundColor Gray
        Write-Host ""
    }

    Write-DebugLog "Starting installation process..."

    # Check Claude Code
    Write-DebugLog "Checking Claude Code installation..."
    $null = Test-ClaudeInstallation

    # Setup user bin directory
    Write-DebugLog "Setting up user bin directory..."
    Setup-UserBin
    Test-UserBinInPath

    # Clean up old installations from different locations
    Write-DebugLog "Checking for old installations..."
    Remove-OldWrappers
    Remove-CcxArtifacts
    Remove-DangerSkipArtifacts

    # Check if already installed
    $glmWrapper = Join-Path $UserBinDir "claude-glm.ps1"
    $glm5tWrapper = Join-Path $UserBinDir "claude-glm-5-turbo.ps1"
    $glm51Wrapper = Join-Path $UserBinDir "claude-glm-5.1.ps1"
    $glm52Wrapper = Join-Path $UserBinDir "claude-glm-5.2.ps1"
    $glm47Wrapper = Join-Path $UserBinDir "claude-glm-4.7.ps1"
    $glm46Wrapper = Join-Path $UserBinDir "claude-glm-4.6.ps1"
    $glm45vWrapper = Join-Path $UserBinDir "claude-glm-4.5v.ps1"
    $glm45airWrapper = Join-Path $UserBinDir "claude-glm-4.5-air.ps1"
    $glm45Wrapper = Join-Path $UserBinDir "claude-glm-4.5.ps1"
    $glmFastWrapper = Join-Path $UserBinDir "claude-glm-fast.ps1"

    if ((Test-Path $glmWrapper) -or (Test-Path $glm5tWrapper) -or (Test-Path $glm51Wrapper) -or (Test-Path $glm52Wrapper) -or (Test-Path $glm47Wrapper) -or (Test-Path $glm46Wrapper) -or (Test-Path $glm45vWrapper) -or (Test-Path $glm45airWrapper) -or (Test-Path $glm45Wrapper) -or (Test-Path $glmFastWrapper)) {
        Write-Host ""
        Write-Host "OK: Existing installation detected!"
        Write-Host "1. Update API key only"
        Write-Host "2. Reset wrappers/aliases using existing API key"
        Write-Host "3. Reinstall everything"
        Write-Host "4. Cancel"
        $choice = Read-Host "Choice (1-4)"

        switch ($choice) {
            "1" {
                $inputKey = Read-Host "Enter your Z.AI API key"
                if ($inputKey) {
                    $script:ZaiApiKey = $inputKey
                    New-ClaudeGlmWrapper
                    New-ClaudeGlm5tWrapper
                    New-ClaudeGlm51Wrapper
                    New-ClaudeGlm52Wrapper
                    New-ClaudeGlm47Wrapper
                    New-ClaudeGlm46Wrapper
                    New-ClaudeGlm45vWrapper
                    New-ClaudeGlm45airWrapper
                    New-ClaudeGlm45Wrapper
                    New-ClaudeGlmFastWrapper
                    Add-PowerShellAliases
                    Add-CmdShims
                    Write-Host "OK: API key updated!"
                    exit 0
                }
            }
            "2" {
                $existingKey = Get-ExistingZaiApiKey
                if (-not $existingKey) {
                    $inputKey = Read-Host "Enter your Z.AI API key"
                    if (-not $inputKey) {
                        exit 0
                    }
                    $existingKey = $inputKey
                }

                $script:ZaiApiKey = $existingKey
                New-ClaudeGlmWrapper
                New-ClaudeGlm5tWrapper
                New-ClaudeGlm51Wrapper
                New-ClaudeGlm52Wrapper
                New-ClaudeGlm47Wrapper
                New-ClaudeGlm46Wrapper
                New-ClaudeGlm45vWrapper
                New-ClaudeGlm45airWrapper
                New-ClaudeGlm45Wrapper
                New-ClaudeGlmFastWrapper
                Add-PowerShellAliases
                Add-CmdShims
                Write-Host "OK: Reset complete!"
                exit 0
            }
            "3" {
                Write-Host "Reinstalling..."
            }
            default {
                exit 0
            }
        }
    }

    # Get API key
    Write-Host ""
    Write-Host "Enter your Z.AI API key (from https://z.ai/manage-apikey/apikey-list)"
    $inputKey = Read-Host "API Key"

    if ($inputKey) {
        $script:ZaiApiKey = $inputKey
        $keyLength = $inputKey.Length
        Write-Host "OK: API key received ($keyLength characters)"
    } else {
        Write-Host "WARNING: No API key provided. Add it manually later to:"
        Write-Host "   $UserBinDir\claude-glm.ps1"
        Write-Host "   $UserBinDir\claude-glm-5-turbo.ps1"
        Write-Host "   $UserBinDir\claude-glm-5.1.ps1"
        Write-Host "   $UserBinDir\claude-glm-5.2.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.5.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.5v.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.5-air.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.6.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.7.ps1"
        Write-Host "   $UserBinDir\claude-glm-fast.ps1"
    }

    # Create wrappers
    New-ClaudeGlmWrapper
    New-ClaudeGlm5tWrapper
    New-ClaudeGlm51Wrapper
    New-ClaudeGlm52Wrapper
    New-ClaudeGlm47Wrapper
    New-ClaudeGlm46Wrapper
    New-ClaudeGlm45vWrapper
    New-ClaudeGlm45airWrapper
    New-ClaudeGlm45Wrapper
    New-ClaudeGlmFastWrapper
    Add-PowerShellAliases
    Add-CmdShims

    # Final instructions
    Write-Host ""
    Write-Host "OK: Installation complete!"
    Write-Host ""
    Write-Host "=========================================="
    Write-Host "IMPORTANT: Restart PowerShell or reload profile:"
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "   . `$PROFILE"
    Write-Host ""
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "INFO: After reloading, you can use:"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "   claude-glm         - GLM-5"
    Write-Host "   claude-glm-5-turbo - GLM-5-Turbo"
    Write-Host "   claude-glm-5.1     - GLM-5.1"
    Write-Host "   claude-glm-5.2     - GLM-5.2 (default, 1M context)"
    Write-Host "   claude-glm-4.7     - GLM-4.7"
    Write-Host "   claude-glm-4.6     - GLM-4.6"
    Write-Host "   claude-glm-4.5     - GLM-4.5"
    Write-Host "   claude-glm-4.5v    - GLM-4.5V (vision)"
    Write-Host "   claude-glm-4.5-air - GLM-4.5-Air"
    Write-Host "   claude-glm-fast    - GLM-4.5-Air (fast, alias for ccg45air)"
    Write-Host ""
    Write-Host "Aliases (GLM only -- your 'claude' command is left untouched):"
    Write-Host "   ccg      - claude-glm-5.2 (GLM-5.2, default, 1M context)"
    Write-Host "   ccgD     - ccg --dangerously-skip-permissions"
    Write-Host "   ccgDd    - ccg --dangerously-skip-permissions -d"
    Write-Host "   ccg45    - claude-glm-4.5 (GLM-4.5)"
    Write-Host "   ccg45v   - claude-glm-4.5v (GLM-4.5V, vision)"
    Write-Host "   ccg45air - claude-glm-4.5-air (GLM-4.5-Air)"
    Write-Host "   ccg46    - claude-glm-4.6 (GLM-4.6)"
    Write-Host "   ccg47    - claude-glm-4.7 (GLM-4.7)"
    Write-Host "   ccg5     - claude-glm (GLM-5)"
    Write-Host "   ccg5t    - claude-glm-5-turbo (GLM-5-Turbo)"
    Write-Host "   ccg51    - claude-glm-5.1 (GLM-5.1)"
    Write-Host "   ccg52    - claude-glm-5.2 (GLM-5.2, same as ccg)"
    Write-Host "   ccf      - claude-glm-fast"
    Write-Host ""

    if ($ZaiApiKey -eq "YOUR_ZAI_API_KEY_HERE") {
        Write-Host "WARNING: Do not forget to add your API key to:"
        Write-Host "   $UserBinDir\claude-glm.ps1"
        Write-Host "   $UserBinDir\claude-glm-5-turbo.ps1"
        Write-Host "   $UserBinDir\claude-glm-5.1.ps1"
        Write-Host "   $UserBinDir\claude-glm-5.2.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.5.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.5v.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.5-air.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.6.ps1"
        Write-Host "   $UserBinDir\claude-glm-4.7.ps1"
        Write-Host "   $UserBinDir\claude-glm-fast.ps1"
    }

    Write-Host ""
    Write-Host "LOCATION: Installation location: $UserBinDir"
    Write-Host "LOCATION: Config directories: $Glm45ConfigDir, $Glm45vConfigDir, $Glm45airConfigDir, $Glm46ConfigDir, $Glm47ConfigDir, $Glm5ConfigDir, $Glm5tConfigDir, $Glm51ConfigDir, $Glm52ConfigDir, $GlmFastConfigDir"
}

# Test error functionality if requested
if ($TestError) {
    Write-Host "TEST: Testing error reporting functionality..." -ForegroundColor Magenta
    Write-Host ""

    # Show how script was invoked
    if ($env:CLAUDE_GLM_TEST_ERROR) {
        Write-Host "   (Invoked via environment variable)" -ForegroundColor Gray
    }
    Write-Host ""

    # Create a test error
    $testErrorMessage = "This is a test error to verify error reporting works correctly"
    $testErrorLine = "Test mode - no actual error"

    # Create a mock error record
    try {
        throw $testErrorMessage
    } catch {
        Report-Error -ErrorMessage $testErrorMessage -ErrorLine $testErrorLine -ErrorRecord $_
    }

    Write-Host "OK: Test complete. If a browser window opened, error reporting is working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To run normal installation, use:" -ForegroundColor Gray
    Write-Host "   iwr -useb https://raw.githubusercontent.com/windysky/claude-glm-wrapper/main/install.ps1 | iex" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press Enter to finish (window will remain open)..." -ForegroundColor Gray
    $null = Read-Host
    # Script will not continue to installation - test mode ends here
}

# Only run installation if not in test mode
if (-not $TestError) {
    # Run installation with error handling
    try {
        $ErrorActionPreference = "Stop"
        Write-DebugLog "Starting installation with ErrorActionPreference = Stop"
        Install-ClaudeGlm
    } catch {
    $errorMessage = $_.Exception.Message
    $errorLine = if ($_.InvocationInfo.ScriptLineNumber) {
        $lineNum = $_.InvocationInfo.ScriptLineNumber
        $scriptName = $_.InvocationInfo.ScriptName
        "Line $lineNum in $scriptName"
    } else {
        "Unknown location"
    }

    Write-DebugLog "Caught error: $errorMessage at $errorLine"
    Report-Error -ErrorMessage $errorMessage -ErrorLine $errorLine -ErrorRecord $_

    # Give user time to read any final messages before stopping
    Write-Host ""
    Write-Host "Installation terminated due to error." -ForegroundColor Red
    Write-Host "Press Enter to finish (window will remain open)..." -ForegroundColor Gray
    $null = Read-Host
    # Return to stop script execution without closing window
    return
    }
}
