#!/usr/bin/env bash
# Installs code-review skill to the generic Agent Skills directory.
# Path: ~/.agents/skills/<skill-name>/SKILL.md (verified)

set -euo pipefail
"$(dirname "$0")/install.sh" --harness agents
