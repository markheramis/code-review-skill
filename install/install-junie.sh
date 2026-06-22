#!/usr/bin/env bash
# Installs code-review skill to Junie skills directory.
# Path: ~/.junie/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness junie
