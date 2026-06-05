#!/usr/bin/env bash
# Installs code-review sub-skills to agent harness skills directories.
# Each sub-skill gets its own directory with a copy of shared fixtures and scripts.
#
# Usage:
#   ./install.sh                    # install to all detected harnesses
#   ./install.sh --harness claude   # install to Claude Code only
#   ./install.sh --harness codex    # install to Codex only
#   ./install.sh --harness cursor   # install to Cursor only
#   ./install.sh --harness vscode   # install to VS Code Copilot only
#   ./install.sh --harness windsurf # install to Windsurf only
#   ./install.sh --target /custom/path  # install to custom path

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_SOURCE="$REPO_ROOT/fixtures"
SCRIPTS_SOURCE="$REPO_ROOT/scripts/get-reports.py"
SUB_SKILLS=(commit-review branch-review pr-review repo-review remediate-review)

# ── Harness paths ──────────────────────────────────────────────────────────────
# verified: claude, codex, cursor, windsurf, cline
declare -A HARNESS_PATHS=(
    [claude]="$HOME/.claude/skills"           # verified
    [codex]="$HOME/.codex/skills"             # verified
    [cursor]="$HOME/.cursor/skills"           # verified
    [vscode]="$HOME/.copilot/skills"           # VS Code Copilot documented personal skills path
    [windsurf]="$HOME/.windsurf/skills"       # verified
    [cline]="$HOME/.cline/skills"             # verified
)

install_to() {
    local target="$1"
    local harness="${2:-custom}"

    for skill in "${SUB_SKILLS[@]}"; do
        local src="$REPO_ROOT/$skill/SKILL.md"
        local dest="$target/$skill"

        mkdir -p "$dest/fixtures"
        mkdir -p "$dest/scripts"
        cp "$src" "$dest/SKILL.md"
        cp -r "$FIXTURES_SOURCE/." "$dest/fixtures/"
        cp "$SCRIPTS_SOURCE" "$dest/scripts/"

        echo "  [$harness] $skill -> $dest"
    done
}

# ── Parse args ─────────────────────────────────────────────────────────────────
HARNESS=""
CUSTOM_TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --harness) HARNESS="$2"; shift 2 ;;
        --target)  CUSTOM_TARGET="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# ── Install ────────────────────────────────────────────────────────────────────
if [[ -n "$CUSTOM_TARGET" ]]; then
    echo "Installing to custom path: $CUSTOM_TARGET"
    install_to "$CUSTOM_TARGET" "custom"
elif [[ -n "$HARNESS" ]]; then
    path="${HARNESS_PATHS[$HARNESS]:-}"
    if [[ -z "$path" ]]; then
        echo "Unknown harness: $HARNESS"
        echo "Known: ${!HARNESS_PATHS[*]}"
        exit 1
    fi
    echo "Installing to $HARNESS ($path)"
    install_to "$path" "$HARNESS"
else
    # install to all harnesses whose config dir exists
    installed=0
    for harness in "${!HARNESS_PATHS[@]}"; do
        config_dir="$(dirname "${HARNESS_PATHS[$harness]}")"
        if [[ -d "$config_dir" ]]; then
            echo "Installing to $harness..."
            install_to "${HARNESS_PATHS[$harness]}" "$harness"
            ((installed++))
        fi
    done
    if [[ $installed -eq 0 ]]; then
        echo "No known harness config dirs found. Use --harness or --target."
        exit 1
    fi
fi

echo "Done. ${#SUB_SKILLS[@]} skills installed."
