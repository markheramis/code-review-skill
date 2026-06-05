#!/usr/bin/env pwsh
# Installs code-review sub-skills to Windsurf skills directory.
# Path: ~\.windsurf\skills\<skill-name>\SKILL.md (verified)
# Verify at: https://agentskills.io or Windsurf docs if this fails.

& "$PSScriptRoot\install.ps1" -Harness windsurf
