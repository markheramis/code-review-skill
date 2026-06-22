#!/usr/bin/env bash
# Installs code-review skill to Continue skills directory.
# Path: ~/.continue/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness continue
