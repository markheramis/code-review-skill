#!/usr/bin/env bash
# Installs code-review sub-skills to agent harness skills directories.
# Each sub-skill gets its own directory with a copy of shared fixtures and scripts.
#
# Usage:
#   ./install.sh                    # install to all detected harnesses
#   ./install.sh --harness agents   # install to generic .agents skills only
#   ./install.sh --harness claude   # install to Claude Code only
#   ./install.sh --harness codex    # install to Codex only
#   ./install.sh --harness continue # install to Continue only
#   ./install.sh --harness cursor   # install to Cursor only
#   ./install.sh --harness hermes   # install to Hermes only
#   ./install.sh --harness junie    # install to Junie only
#   ./install.sh --harness trae     # install to Trae only
#   ./install.sh --harness vscode   # install to VS Code Copilot only
#   ./install.sh --harness windsurf # install to Windsurf only
#   ./install.sh --target /custom/path  # install to custom path

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_SOURCE="$REPO_ROOT/fixtures"
SCRIPTS_SOURCE="$REPO_ROOT/scripts"
SUB_SKILLS=(commit-review branch-review pr-review repo-review remediate-review verify-report)

# ── Harness paths ──────────────────────────────────────────────────────────────
# verified on this workstation: agents, claude, cline, codex, continue, cursor,
# hermes, junie, trae, vscode/copilot, windsurf
# NOTE: keep HARNESS_KEYS and HARNESS_DIRS as parallel indexed arrays (not an
# associative array) so the script works on macOS bash 3.2, which lacks
# `declare -A`. Order must match between the two arrays.
HARNESS_KEYS=(agents claude cline codex continue cursor hermes junie trae vscode windsurf)
HARNESS_DIRS=(
    "$HOME/.agents/skills"   # generic Agent Skills root
    "$HOME/.claude/skills"   # verified
    "$HOME/.cline/skills"    # verified
    "$HOME/.codex/skills"    # verified
    "$HOME/.continue/skills" # verified
    "$HOME/.cursor/skills"   # verified
    "$HOME/.hermes/skills"   # verified
    "$HOME/.junie/skills"    # verified
    "$HOME/.trae/skills"     # verified
    "$HOME/.copilot/skills"  # VS Code Copilot documented personal skills path
    "$HOME/.windsurf/skills" # verified
)

resolve_harness() {
    case "$1" in
        agent) echo "agents" ;;
        copilot) echo "vscode" ;;
        *) echo "$1" ;;
    esac
}

# Look up the path for a harness name. Echoes nothing if unknown.
harness_path() {
    local name="$1"
    local i
    for i in "${!HARNESS_KEYS[@]}"; do
        if [[ "${HARNESS_KEYS[$i]}" == "$name" ]]; then
            echo "${HARNESS_DIRS[$i]}"
            return 0
        fi
    done
    return 1
}

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
        cp "$SCRIPTS_SOURCE"/*.py "$dest/scripts/"

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
    HARNESS="$(resolve_harness "$HARNESS")"
    if ! path="$(harness_path "$HARNESS")"; then
        echo "Unknown harness: $HARNESS"
        echo "Known: ${HARNESS_KEYS[*]}"
        exit 1
    fi
    if [[ ! -d "$path" ]]; then
        echo "Creating $HARNESS skills directory: $path"
        mkdir -p "$path"
    fi
    echo "Installing to $HARNESS ($path)"
    install_to "$path" "$HARNESS"
else
    # Auto-detect: install to every known harness, creating the skills
    # directory if it does not already exist. This way a single
    # `./install/install.sh` works on a fresh machine.
    installed=0
    for i in "${!HARNESS_KEYS[@]}"; do
        harness="${HARNESS_KEYS[$i]}"
        path="${HARNESS_DIRS[$i]}"
        if [[ -d "$path" ]]; then
            echo "Installing to $harness..."
        else
            echo "Creating $harness skills directory and installing..."
            mkdir -p "$path"
        fi
        install_to "$path" "$harness"
        installed=$((installed + 1))
    done
    if [[ $installed -eq 0 ]]; then
        echo "No known harness skills directories found. Use --target for an explicit custom path."
        exit 1
    fi
fi

echo "Done. ${#SUB_SKILLS[@]} skills installed to ${installed} harness(es)."
