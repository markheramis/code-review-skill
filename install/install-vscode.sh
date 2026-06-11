#!/usr/bin/env bash
# Installs code-review sub-skills to VS Code Copilot personal skills directory.
# Path: ~/.copilot/skills/<skill-name>/SKILL.md (VS Code documented)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness vscode
