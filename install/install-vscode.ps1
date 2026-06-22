#!/usr/bin/env pwsh
# Installs code-review skill to VS Code Copilot personal skills directory.
# Path: ~\.copilot\skills\<skill-name>\SKILL.md (VS Code documented)

& "$PSScriptRoot\install.ps1" -Harness vscode
