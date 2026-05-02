<#
.SYNOPSIS
    Puts a fork of demo-github into "ready for demo" state by creating
    (or reopening) the three issues that DEMO.md walks through.

.DESCRIPTION
    Idempotent. Safe to re-run before every demo. Detects the current
    GitHub repo via `gh repo view` if -Repo is not supplied. Requires
    the GitHub CLI (`gh`) and an authenticated session.

.PARAMETER Repo
    Target repository in <owner>/<name> form. Defaults to the repo of
    the current working directory.

.PARAMETER DryRun
    Print what the script would do without making any changes.

.EXAMPLE
    pwsh ./scripts/start-demo.ps1

.EXAMPLE
    pwsh ./scripts/start-demo.ps1 -Repo my-user/demo-github

.EXAMPLE
    pwsh ./scripts/start-demo.ps1 -DryRun
#>
[CmdletBinding()]
param(
    [string]$Repo,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI ('gh') not found. Install from https://cli.github.com/"
}

& gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run 'gh auth login' first."
}

if (-not $Repo) {
    $Repo = (& gh repo view --json nameWithOwner -q .nameWithOwner 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $Repo) {
        throw "Could not detect repo. Pass -Repo <owner>/<name> or run inside a clone."
    }
    $Repo = $Repo.Trim()
}

Write-Host "Target repo: $Repo" -ForegroundColor Cyan
if ($DryRun) { Write-Host "(dry run — no changes will be made)" -ForegroundColor Yellow }

# ---------------------------------------------------------------------------
# Labels (idempotent)
# ---------------------------------------------------------------------------
$labels = @(
    @{ name = 'demo'; color = '5319e7'; description = 'Demo issues used by the DEMO.md walkthrough' }
)

$existingLabels = @()
try {
    $existingLabels = (& gh label list --repo $Repo --limit 200 --json name | ConvertFrom-Json).name
} catch {
    $existingLabels = @()
}

foreach ($l in $labels) {
    if ($existingLabels -contains $l.name) {
        Write-Host "  label exists  : $($l.name)" -ForegroundColor DarkGray
        continue
    }
    Write-Host "  creating label: $($l.name)" -ForegroundColor Green
    if ($DryRun) { continue }
    & gh label create $l.name --repo $Repo --color $l.color --description $l.description | Out-Null
}

# ---------------------------------------------------------------------------
# Issues to ensure-exist (titles must match exactly across runs)
# ---------------------------------------------------------------------------
$issues = @(
    @{
        title  = 'Add a dark-mode toggle to the nav'
        labels = @('demo', 'enhancement')
        body   = @'
Add a dark-mode toggle button to the right side of the nav, next to the existing nav links.

**Requirements**
- A small toggle (button or switch) in the `<nav>` flips the page between a light and a dark theme.
- Drive the colour change with CSS custom properties so the hero, sections, cards, and footer all flip in sync.
- Persist the user's choice in `localStorage` so it survives reloads.
- Honour `prefers-color-scheme: dark` on first visit (no stored preference yet).

**Where to edit**
- `index.html` — markup for the toggle button **and** the inlined `<style>` block (CSS lives there in this repo, not in a separate `styles.css`).
'@
    },
    @{
        title  = 'Fix nav-link contrast on mobile (<600px)'
        labels = @('demo', 'bug', 'good first issue')
        body   = @'
On viewports under 600px the nav links are cramped and hover/active state is hard to read against the dark `#1f2937` header.

**Requirements**
- Inside the existing `@media (max-width: 600px)` block in `index.html`, bump the link colour and tap-target spacing.
- Confirm the fix at 360px and 414px widths.
- CSS only — no JavaScript, no markup changes.

**Where to edit**
- `index.html` — the inlined `<style>` block.
'@
    },
    @{
        title  = 'Add a footer social-links row'
        labels = @('demo', 'enhancement')
        body   = @'
Add a single row of social links above the copyright line in the footer.

**Requirements**
- Three links: GitHub, X/Twitter, LinkedIn (use `#` for `href` placeholders).
- Use inline SVG icons so the page stays self-contained — no external icon font or CDN.
- Keep the existing `&copy; 2026 MySite…` line directly underneath the icons.
- Icons should pick up the muted footer text colour and lift slightly on hover.

**Where to edit**
- `index.html` — the `<footer>` block plus a few rules in the inlined `<style>`.
'@
    }
)

# ---------------------------------------------------------------------------
# Issues (idempotent: create if missing, reopen if closed)
# ---------------------------------------------------------------------------
$existingIssues = @()
try {
    $existingIssues = & gh issue list --repo $Repo --state all --limit 200 --json 'number,title,state,url' | ConvertFrom-Json
} catch {
    $existingIssues = @()
}

foreach ($issue in $issues) {
    $match = $existingIssues | Where-Object { $_.title -eq $issue.title } | Select-Object -First 1

    if ($match) {
        if ($match.state -eq 'CLOSED') {
            Write-Host "  reopening #$($match.number) : $($issue.title)" -ForegroundColor Yellow
            if (-not $DryRun) { & gh issue reopen $match.number --repo $Repo | Out-Null }
        } else {
            Write-Host "  already open #$($match.number): $($issue.title)" -ForegroundColor DarkGray
        }
        continue
    }

    Write-Host "  creating       : $($issue.title)" -ForegroundColor Green
    if ($DryRun) { continue }

    $tmp = New-TemporaryFile
    try {
        # -NoNewline avoids an extra blank line at EOF
        Set-Content -Path $tmp -Value $issue.body -Encoding UTF8 -NoNewline

        $ghArgs = @('issue', 'create', '--repo', $Repo, '--title', $issue.title, '--body-file', $tmp.FullName)
        foreach ($lbl in $issue.labels) { $ghArgs += @('--label', $lbl) }

        & gh @ghArgs | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Failed to create issue '$($issue.title)'" }
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Demo is ready. Open issues with the 'demo' label:" -ForegroundColor Cyan
& gh issue list --repo $Repo --label demo --state open

Write-Host ""
Write-Host "Next steps (see DEMO.md):" -ForegroundColor Cyan
Write-Host "  1. Open the GitHub agentic app, sign in, and connect $Repo."
Write-Host "  2. From Inbox or Issues, pick one of the demo issues, hit 'Start a session'."
Write-Host "  3. (Optional) Wire up AZURE_CREDENTIALS + AZURE_STORAGE_CONNECTION_STRING secrets"
Write-Host "     on $Repo if you want the deploy workflow to publish after merge."
