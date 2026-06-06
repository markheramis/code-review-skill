#!/usr/bin/env pwsh
# Installs code-review sub-skills to agent harness skills directories.
# Each sub-skill gets its own directory with a copy of shared fixtures and scripts.
#
# Usage:
#   .\install.ps1                        # install to all detected harnesses
#   .\install.ps1 -Harness agents        # install to generic .agents skills only
#   .\install.ps1 -Harness claude        # install to Claude Code only
#   .\install.ps1 -Harness codex         # install to Codex only
#   .\install.ps1 -Harness continue      # install to Continue only
#   .\install.ps1 -Harness cursor        # install to Cursor only
#   .\install.ps1 -Harness hermes        # install to Hermes only
#   .\install.ps1 -Harness junie         # install to Junie only
#   .\install.ps1 -Harness trae          # install to Trae only
#   .\install.ps1 -Harness vscode        # install to VS Code Copilot only
#   .\install.ps1 -Harness windsurf      # install to Windsurf only
#   .\install.ps1 -Target C:\custom\path # install to custom path

param(
    [string]$Harness = "",
    [string]$Target = ""
)

$RepoRoot = Split-Path $PSScriptRoot -Parent
$FixturesSource = Join-Path $RepoRoot "fixtures"
$ScriptsSource = Join-Path $RepoRoot "scripts" "get-reports.py"
$SubSkills = @("commit-review", "branch-review", "pr-review", "repo-review", "remediate-review")

# ── Harness paths ──────────────────────────────────────────────────────────────
# verified on this workstation: agents, claude, cline, codex, continue, cursor,
# hermes, junie, trae, vscode/copilot, windsurf
$HarnessPaths = @{
    agents   = "$env:USERPROFILE\.agents\skills"    # generic Agent Skills root
    claude   = "$env:USERPROFILE\.claude\skills"     # verified
    cline    = "$env:USERPROFILE\.cline\skills"      # verified
    codex    = "$env:USERPROFILE\.codex\skills"      # verified
    continue = "$env:USERPROFILE\.continue\skills"   # verified
    cursor   = "$env:USERPROFILE\.cursor\skills"     # verified
    hermes   = "$env:USERPROFILE\.hermes\skills"     # verified
    junie    = "$env:USERPROFILE\.junie\skills"      # verified
    trae     = "$env:USERPROFILE\.trae\skills"       # verified
    vscode   = "$env:USERPROFILE\.copilot\skills"    # VS Code Copilot documented personal skills path
    windsurf = "$env:USERPROFILE\.windsurf\skills"   # verified
}

$HarnessAliases = @{
    agent   = "agents"
    copilot = "vscode"
}

function Install-To {
    param([string]$TargetPath, [string]$HarnessName = "custom")

    foreach ($skill in $SubSkills) {
        $src  = Join-Path $RepoRoot $skill "SKILL.md"
        $dest = Join-Path $TargetPath $skill

        New-Item -ItemType Directory -Force -Path (Join-Path $dest "fixtures") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $dest "scripts")  | Out-Null
        Copy-Item -Path $src -Destination (Join-Path $dest "SKILL.md") -Force
        Copy-Item -Path "$FixturesSource\*" -Destination (Join-Path $dest "fixtures") -Recurse -Force
        Copy-Item -Path $ScriptsSource -Destination (Join-Path $dest "scripts") -Force

        Write-Host "  [$HarnessName] $skill -> $dest"
    }
}

# ── Install ────────────────────────────────────────────────────────────────────
if ($Target) {
    Write-Host "Installing to custom path: $Target"
    Install-To -TargetPath $Target -HarnessName "custom"
}
elseif ($Harness) {
    $resolvedHarness = $Harness.ToLowerInvariant()
    if ($HarnessAliases.ContainsKey($resolvedHarness)) {
        $resolvedHarness = $HarnessAliases[$resolvedHarness]
    }

    if (-not $HarnessPaths.ContainsKey($resolvedHarness)) {
        Write-Error "Unknown harness: $Harness. Known: $($HarnessPaths.Keys -join ', ')"
        exit 1
    }
    $path = $HarnessPaths[$resolvedHarness]
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        Write-Error "Skills directory does not exist for harness '$resolvedHarness': $path"
        exit 1
    }
    Write-Host "Installing to $resolvedHarness ($path)"
    Install-To -TargetPath $path -HarnessName $resolvedHarness
}
else {
    # install to all harnesses whose skills directory already exists
    $installed = 0
    foreach ($h in $HarnessPaths.Keys) {
        if (Test-Path -LiteralPath $HarnessPaths[$h] -PathType Container) {
            Write-Host "Installing to $h..."
            Install-To -TargetPath $HarnessPaths[$h] -HarnessName $h
            $installed++
        }
    }
    if ($installed -eq 0) {
        Write-Warning "No known harness skills directories found. Use -Target for an explicit custom path."
        exit 1
    }
}

Write-Host "Done. $($SubSkills.Count) skills installed."
