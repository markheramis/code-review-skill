#!/usr/bin/env pwsh
# Installs code-review sub-skills to Codex (OpenAI CLI) skills directory.
# Path: ~\.codex\skills\<skill-name>\SKILL.md (verified)
# Verify at: https://agentskills.io or Codex CLI docs if this fails.

& "$PSScriptRoot\install.ps1" -Harness codex