#!/usr/bin/env pwsh
# Installs code-review sub-skills to the generic Agent Skills directory.
# Path: ~\.agents\skills\<skill-name>\SKILL.md (verified)

& "$PSScriptRoot\install.ps1" -Harness agents
