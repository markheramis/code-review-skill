#!/usr/bin/env bash
# Installs code-review skill to Claude Code skills directory.
# Path: ~/.claude/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness claude