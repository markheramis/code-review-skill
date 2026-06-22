#!/usr/bin/env bash
# Installs code-review skill to Trae skills directory.
# Path: ~/.trae/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness trae
