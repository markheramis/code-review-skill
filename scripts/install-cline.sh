#!/usr/bin/env bash
# Installs code-review sub-skills to Cline skills directory.
# Path: ~/.cline/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness cline
