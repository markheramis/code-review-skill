#!/usr/bin/env pwsh
# Installs the evidence-first-code-review skill to agent harness skills directories.
# The skill installs as a single SKILL.md with references/, fixtures/, and scripts/.
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
#   .\install.ps1 -Harness vscode         # install to VS Code Copilot only
#   .\install.ps1 -Harness windsurf      # install to Windsurf only
#   .\install.ps1 -Target C:\custom\path  # install to a custom skills root

param(
    [string]$Harness = "",
    [string]$Target = ""
)

$RepoRoot = Split-Path $PSScriptRoot -Parent
$SkillName = "evidence-first-code-review"
$SkillSource = Join-Path $RepoRoot "SKILL.md"
$ReferencesSource = Join-Path $RepoRoot "references"
$FixturesSource = Join-Path $RepoRoot "fixtures"
$ScriptsSource = Join-Path $RepoRoot "scripts"

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

    $dest = Join-Path $TargetPath $SkillName

    if (-not (Test-Path -LiteralPath $SkillSource -PathType Leaf)) {
        Write-Host "  [$HarnessName] SKILL.md not found at $SkillSource — skipping"
        return
    }

    New-Item -ItemType Directory -Force -Path (Join-Path $dest "references") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $dest "fixtures")   | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $dest "scripts")    | Out-Null

    # SKILL.md (entry point)
    Copy-Item -Path $SkillSource -Destination (Join-Path $dest "SKILL.md") -Force

    # references/ (32 deep-dive docs)
    if (Test-Path -LiteralPath $ReferencesSource -PathType Container) {
        Copy-Item -Path (Join-Path $ReferencesSource "*.md") `
                  -Destination (Join-Path $dest "references") -Force
    }

    # fixtures/ (templates and JSON schemas)
    if (Test-Path -LiteralPath $FixturesSource -PathType Container) {
        Copy-Item -Path "$FixturesSource\*" `
                  -Destination (Join-Path $dest "fixtures") -Recurse -Force
    }

    # scripts/ (Python utilities)
    if (Test-Path -LiteralPath $ScriptsSource -PathType Container) {
        Get-ChildItem -Path $ScriptsSource -Filter "*.py" -ErrorAction SilentlyContinue `
            | ForEach-Object { Copy-Item -Path $_.FullName `
                                         -Destination (Join-Path $dest "scripts") -Force }
    }

    Write-Host "  [$HarnessName] $SkillName -> $dest"
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

Write-Host "Done. $SkillName installed."