#!/usr/bin/env bash
# Installs code-review skill to Codex (OpenAI CLI) skills directory.
# Path: ~/.codex/skills/<skill-name>/SKILL.md (verified)
# Verify at: https://agentskills.io or Codex CLI docs if this fails.

set -euo pipefail
"$(dirname "$0")/install.sh" --harness codex