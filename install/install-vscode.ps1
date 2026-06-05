#!/usr/bin/env pwsh
# Installs code-review sub-skills to VS Code Copilot personal skills directory.
# Path: ~\.copilot\skills\<skill-name>\SKILL.md (VS Code documented)

& "$PSScriptRoot\install.ps1" -Harness vscode
