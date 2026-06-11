#!/usr/bin/env bash
# Installs code-review sub-skills to Continue skills directory.
# Path: ~/.continue/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness continue
