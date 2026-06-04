#!/usr/bin/env pwsh
# Installs code-review sub-skills to Cursor skills directory.
# Path: ~\.cursor\skills\<skill-name>\SKILL.md (verified)
# Verify at: https://agentskills.io or Cursor docs if this fails.

& "$PSScriptRoot\install-claude.ps1" -Harness cursor
