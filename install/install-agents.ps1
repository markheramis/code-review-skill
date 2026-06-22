#!/usr/bin/env pwsh
# Installs code-review skill to the generic Agent Skills directory.
# Path: ~\.agents\skills\<skill-name>\SKILL.md (verified)

& "$PSScriptRoot\install.ps1" -Harness agents
