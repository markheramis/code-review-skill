#!/usr/bin/env bash
# Installs code-review skill to Windsurf skills directory.
# Path: ~/.windsurf/skills/<skill-name>/SKILL.md (verified)
# Verify at: https://agentskills.io or Windsurf docs if this fails.

set -euo pipefail
"$(dirname "$0")/install.sh" --harness windsurf