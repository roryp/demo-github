# Demo script — 5 minutes (your fork of `roryp/demo-github`)

Read top to bottom. Each step says exactly what to click. Total: ~5 minutes.

This repo is a two-file static site ([`index.html`](index.html) + [`styles.css`](styles.css)) that auto-deploys to Azure Storage via [`.github/workflows/deploy-azure.yml`](.github/workflows/deploy-azure.yml) on every push to `main`. Reference live URL (original repo): https://demosite57342.z13.web.core.windows.net/

## Before you start (off-camera)

- **Fork `roryp/demo-github` to your own GitHub account first.** All steps below run against **your fork** — you need write access to push branches, open PRs, and merge. Throughout this doc, replace `<you>` with your GitHub username.
  - Optional: to make the live-URL refresh in §5 work on your fork, wire up your own Azure Storage `$web` container and add the `AZURE_CREDENTIALS` + `AZURE_STORAGE_ACCOUNT` secrets to your fork. Otherwise the loop ends at **Merged on `main` of your fork** — still a complete demo, just no public deploy.
- App is open, signed in to GitHub (the account that owns the fork).
- The **`<you>/demo-github`** Project is connected. It has at least **one open issue** — recommended primary issues for this repo:
  - *"Add a dark-mode toggle to the nav"* (touches `index.html` + `styles.css`)
  - *"Fix nav-link contrast on mobile (<600px)"* (CSS-only, fast)
  - *"Add a footer social-links row"* (small visible diff)
- Pick a **second** issue to run in parallel — e.g. *"Add a footer social-links row"* if it isn't already your primary.
- Dev-server command for §3 (static site, no build step):
  ```text
  python -m http.server 8000
  ```
  …then open `http://localhost:8000/` in the Browser tab. (`npx serve .` works too.)

---

## §0 — Open (15 sec)

1. App is on **Home**.
2. Point at the left sidebar: **Home · Inbox · Pull requests · Issues · Workflows**.
3. Say: *"Everything I do as a dev — issues, agents, diffs, PRs, merge — lives here. This repo is a tiny static site that ships to Azure on every push, so the loop is fast and visible."*

## §1 — Start a session from an issue (45 sec)

> If your audience doesn't see an **Inbox** item in the sidebar, they can turn on **Combined inbox** in **Settings (Cmd+,) → Experimental → Experiments**. Otherwise they use the **Issues** tab — same flow from step 2 on.

1. Click **Inbox** in the sidebar.
2. Click your demo issue (e.g. *"Add a dark-mode toggle to the nav"*).
3. Top-right of the issue → click **Start a session**.
4. In the composer that appears:
   - **Mode** picker → **Plan**
   - **Workspace type** → **New worktree**
   - **Model** → leave on Auto
5. Type the prompt (or just hit Enter to use the issue body) → **Enter**.
6. Say: *"Worktree means it works in an isolated copy — my main `demo-github` checkout is untouched."*

## §2 — Run a second session in parallel (30 sec)

1. Press **Cmd+N** (Ctrl+N on Windows). The new-session dialog opens.
2. Pick **`<you>/demo-github`** again → set **Workspace type = New worktree** → paste/type the second issue (e.g. *"Add a footer social-links row"*) → **Enter**.
3. Both workspaces now show in the sidebar with a **working** badge.
4. Press **Cmd+1** then **Cmd+2** to flip between them. Each has its own branch and its own diff against `main`.

## §3 — See the changes + live preview (60 sec)

1. Click the workspace whose agent has finished (or is far enough along) — the dark-mode one is good because the diff spans both files.
2. Right panel: click the **Changes** tab (or press **Cmd+\\**). Show the diff in `index.html` and `styles.css`.
3. Add a browser preview: click the **+** at the right of the tab strip → pick **Browser**.
4. Open a **Terminal**: click **+** → **Terminal** (or press **Ctrl+`**) → run `python -m http.server 8000` → enter `http://localhost:8000/` in the Browser tab. The page loads instantly — no build step.
5. Press **Cmd+Shift+C** to turn on **Pick & Polish**. Click any visible element — a nav link, the page heading, a button — it attaches to the next prompt as context. Say: *"Now I can ask 'make this pill-shaped' and it edits `styles.css` against that exact element."*

## §4 — Create the PR (45 sec)

1. Top-right of the workspace, find the blue button. Click the **chevron** next to it.
2. The menu shows three variants — pick one and explain:
   - **Create PR** — normal pull request
   - **Create draft PR** — draft, not ready for review
   - **Agent Merge** — creates the PR **and** drives it to merge for you
3. Click the chosen variant. Wait a few seconds — the agent writes the title/body and opens the PR against `<you>/demo-github` (your fork's `main`).
4. Right panel now has a **Pull request** tab. Open it → show **Conversation · Files · Checks**. Heads-up: the **Checks** tab will be empty for this repo — the only workflow ([`deploy-azure.yml`](.github/workflows/deploy-azure.yml)) runs on push to `main`, not on PRs. Point at it and say: *"That's the deploy hook the agent merge will trip the moment this lands on `main` (assuming you wired up Azure secrets on your fork)."*

> If the button is missing: the workspace is on `main` with no commits, or it's a PR-review workspace. Make sure the agent has actually changed `index.html` or `styles.css`.

## §5 — Agent Merge closes the loop (60 sec)

1. On the open PR, the workspace header button now reads **Ready to merge** or **Ready for review** (for drafts). Since this repo has no PR-triggered checks, there's nothing blocking the button.
   - If it says **Ready for review**, click it once to convert the draft. The button then becomes **Ready to merge**.
2. Click the **chevron** next to **Ready to merge** → **Enable agent merge**.
3. Say: *"Agent merge normally watches three things — review threads, CI, conflicts — and merges when all three are green. This repo's CI runs **after** merge (deploy-only), so today we're showing the review-thread + conflict path. The moment it merges into `main`, the `deploy-azure.yml` workflow uploads `index.html` and `styles.css` to the `$web` container — the change is live within seconds (on forks with Azure secrets configured)."*
4. Demo trigger (optional): leave one unresolved review comment. Watch the conversation: the agent replies, pushes a fix, re-checks, then runs `gh pr merge`.
5. Header flips to **Merged**. 
   - **If your fork has Azure secrets:** tab over to your deployed site and refresh — the dark-mode toggle / footer / whatever you shipped is **on production**. Done.
   - **If not:** tab over to the reference live URL (https://demosite57342.z13.web.core.windows.net/) to show what the deploy looks like on the original repo. Your fork's loop ended at the green **Merged** badge — same demo value, just no public URL.

## §6 — Close (15 sec)

One sentence: *"Issue → agent in a worktree → diff + live preview → PR → agent merge → Azure Storage deploy. One app. No tab-switching."*

---

## Cheat sheet (keep visible while demoing)

| Need to… | Press |
|---|---|
| Command palette | **Cmd+K** |
| New session | **Cmd+N** |
| Switch session | **Cmd+1 … Cmd+9** |
| Open Changes (diff) | **Cmd+\\** |
| Open Pull request tab | **Cmd+Shift+\\** |
| Open Terminal | **Ctrl+`** |
| Pick & Polish | **Cmd+Shift+C** |
| Cycle mode | **Cmd+Shift+M** |

## If something breaks live

- **No "Start a session" button** → workspace already exists. Click **Open session** instead.
- **No "Create PR" button** → you're on `main` with no commits, or it's a PR-review workspace. Open a different workspace.
- **No Inbox tab in the sidebar** → use **Issues** instead. The flow from step 2 on is identical.
- **Browser tab doesn't appear in the + menu** → skip the preview steps. Just show the diff and the conversation; the rest of the demo still works.
- **`python` not found in the terminal** → use `npx serve .` (Node) or just drag `index.html` onto the Browser tab as a `file://` URL.
- **Deploy workflow doesn't run after merge** — the `paths:` filter only fires on `**.html` / `**.css` changes. If the agent only touched docs, trigger it manually: `gh workflow run deploy-azure.yml --repo <you>/demo-github --ref main`.
- **Agent stuck on Agent Merge** → it will ask a question in the composer; answer it and the loop resumes.
