#!/usr/bin/env bash
# Installs code-review sub-skills to Hermes skills directory.
# Path: ~/.hermes/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness hermes
