#!/usr/bin/env pwsh
# Installs code-review sub-skills to agent harness skills directories.
# Each sub-skill gets its own directory with a copy of shared fixtures.
#
# Usage:
#   .\install.ps1                        # install to all detected harnesses
#   .\install.ps1 -Harness claude        # install to Claude Code only
#   .\install.ps1 -Harness codex         # install to Codex only
#   .\install.ps1 -Harness cursor        # install to Cursor only
#   .\install.ps1 -Harness windsurf      # install to Windsurf only
#   .\install.ps1 -Target C:\custom\path # install to custom path

param(
    [string]$Harness = "",
    [string]$Target = ""
)

$RepoRoot = Split-Path $PSScriptRoot -Parent
$FixturesSource = Join-Path $RepoRoot "fixtures"
$SubSkills = @("commit-review", "branch-review", "pr-review", "repo-review")

# ── Harness paths ──────────────────────────────────────────────────────────────
# verified: claude, codex, cursor, windsurf, cline
$HarnessPaths = @{
    claude   = "$env:USERPROFILE\.claude\skills"     # verified
    codex    = "$env:USERPROFILE\.codex\skills"      # verified
    cursor   = "$env:USERPROFILE\.cursor\skills"     # verified
    windsurf = "$env:USERPROFILE\.windsurf\skills"   # verified
    cline    = "$env:USERPROFILE\.cline\skills"      # verified
}

function Install-To {
    param([string]$TargetPath, [string]$HarnessName = "custom")

    foreach ($skill in $SubSkills) {
        $src  = Join-Path $RepoRoot $skill "SKILL.md"
        $dest = Join-Path $TargetPath $skill

        New-Item -ItemType Directory -Force -Path (Join-Path $dest "fixtures") | Out-Null
        Copy-Item -Path $src -Destination (Join-Path $dest "SKILL.md") -Force
        Copy-Item -Path "$FixturesSource\*" -Destination (Join-Path $dest "fixtures") -Recurse -Force

        Write-Host "  [$HarnessName] $skill -> $dest"
    }
}

# ── Install ────────────────────────────────────────────────────────────────────
if ($Target) {
    Write-Host "Installing to custom path: $Target"
    Install-To -TargetPath $Target -HarnessName "custom"
}
elseif ($Harness) {
    if (-not $HarnessPaths.ContainsKey($Harness)) {
        Write-Error "Unknown harness: $Harness. Known: $($HarnessPaths.Keys -join ', ')"
        exit 1
    }
    $path = $HarnessPaths[$Harness]
    Write-Host "Installing to $Harness ($path)"
    Install-To -TargetPath $path -HarnessName $Harness
}
else {
    # install to all harnesses whose config dir exists
    $installed = 0
    foreach ($h in $HarnessPaths.Keys) {
        $configDir = Split-Path $HarnessPaths[$h] -Parent
        if (Test-Path $configDir) {
            Write-Host "Installing to $h..."
            Install-To -TargetPath $HarnessPaths[$h] -HarnessName $h
            $installed++
        }
    }
    if ($installed -eq 0) {
        Write-Warning "No known harness config dirs found. Use -Harness or -Target."
        exit 1
    }
}

Write-Host "Done. $($SubSkills.Count) skills installed."
