#!/usr/bin/env bash
# Installs code-review skill to Cursor skills directory.
# Path: ~/.cursor/skills/<skill-name>/SKILL.md (verified)
# Verify at: https://agentskills.io or Cursor docs if this fails.

set -euo pipefail
"$(dirname "$0")/install.sh" --harness cursor