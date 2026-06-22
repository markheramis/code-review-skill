#!/usr/bin/env bash
# Installs code-review skill to Hermes skills directory.
# Path: ~/.hermes/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness hermes
