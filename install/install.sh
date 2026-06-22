#!/usr/bin/env bash
# Installs the evidence-first-code-review skill to agent harness skills directories.
# The skill installs as a single SKILL.md with references/, fixtures/, and scripts/.
#
# Usage:
#   ./install.sh                    # install to every detected harness
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
#   ./install.sh --target /custom/path  # install to a custom skills root

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_NAME="evidence-first-code-review"
SKILL_SOURCE="$REPO_ROOT/SKILL.md"
REFERENCES_SOURCE="$REPO_ROOT/references"
FIXTURES_SOURCE="$REPO_ROOT/fixtures"
SCRIPTS_SOURCE="$REPO_ROOT/scripts"

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

# Install the single skill into a target directory.
install_to() {
    local target="$1"
    local harness="${2:-custom}"
    local dest="$target/$SKILL_NAME"

    if [[ ! -f "$SKILL_SOURCE" ]]; then
        echo "  [$harness] SKILL.md not found at $SKILL_SOURCE — skipping"
        return 1
    fi

    mkdir -p "$dest/references" "$dest/fixtures" "$dest/scripts"

    # SKILL.md (entry point)
    cp "$SKILL_SOURCE" "$dest/SKILL.md"

    # references/ (32 deep-dive docs)
    if [[ -d "$REFERENCES_SOURCE" ]]; then
        cp "$REFERENCES_SOURCE"/*.md "$dest/references/"
    fi

    # fixtures/ (templates and JSON schemas)
    if [[ -d "$FIXTURES_SOURCE" ]]; then
        cp -r "$FIXTURES_SOURCE"/. "$dest/fixtures/"
    fi

    # scripts/ (Python utilities)
    if [[ -d "$SCRIPTS_SOURCE" ]]; then
        cp "$SCRIPTS_SOURCE"/*.py "$dest/scripts/" 2>/dev/null || true
    fi

    echo "  [$harness] $SKILL_NAME -> $dest"
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
    # ./install/install.sh works on a fresh machine.
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
    if [[ "$installed" -eq 0 ]]; then
        echo "No known harness skills directories found. Use --target for an explicit custom path."
        exit 1
    fi
fi

echo "Done. $SKILL_NAME installed."