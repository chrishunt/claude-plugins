---
name: start-work
description: Start a new feature/bugfix/code change on its own branch in an in-repo worktree. Use right before the first file edit of any code change in a git repo (not just when invoked as /start-work), after any brainstorming or design step has finished and been approved; checks for existing branches/PRs that may already cover the change (confirm reuse with the user), otherwise creates a <prefix>/<area>-<summary> branch in an in-repo worktree based on the fresh remote default branch.
argument-hint: "[short description of the change]"
---

# /start-work — begin a change on its own branch + worktree

The argument is a short description of the feature/bug/change. If there is no argument and the task isn't clear from conversation context, ask what the change is.

## 0. Wait until brainstorming is done

Run this skill when the first file edit is about to happen, not when the request arrives. If `jig:design-first` (or another brainstorming or design skill) applies or is in progress, let it finish first, including the approval it waits for. Brainstorming only reads the repo, so it can run in the main checkout. Once the design is approved, run the steps below before editing anything.

## 1. Find the branch prefix

Branches are named `<prefix>/...`. Use the prefix the user's instructions (CLAUDE.md or memory) give; otherwise use their GitHub login from `gh api user --jq .login`.

## 2. Check for existing work first

Run:

- `git fetch origin --prune`
- `git branch --list '<prefix>/*'` and `git branch -r --list 'origin/<prefix>/*'`
- `git worktree list`
- `gh pr list --author @me --state open --json number,title,headRefName`

If any existing branch, worktree, or open PR plausibly covers this same change, stop and confirm with the user: reuse it or create a new one. Never silently create a near-duplicate branch.

## 3. Name the branch

Format: `<prefix>/<area>-<short-dashed-summary>`

- `<area>`: one word for the high-level thing being touched (subsystem or feature name: `api`, `ui`, `auth`, `billing`, `docs`, ...). If there's a ticket ID, it can serve as or follow the area (e.g. `abc-123-...`).
- `<short-dashed-summary>`: verb-first summary of the fix or feature.

Examples:

- `<prefix>/api-add-customer-webhook-processing`
- `<prefix>/billing-fix-line-item-quantity-parsing`
- `<prefix>/ui-add-dark-mode-toggle`

## 4. Create the worktree and move into it

Work always happens in a worktree so other tasks can proceed in parallel in the main checkout. Worktrees live inside the repo, not outside it.

Preferred: use the native EnterWorktree tool (load via ToolSearch if deferred). It creates the worktree at `<repo>/.claude/worktrees/<name>` (inside the repo, automatically git-excluded) and moves the session into it. Use the summary portion of the branch name as the worktree name and the full `<prefix>/...` name as the branch.

With the default `worktree.baseRef: "fresh"` setting, the new branch is based on the remote default branch (`origin/HEAD`), which is what we want; step 2's fetch keeps that current. If the branch ends up with a generated name (`worktree-<name>`), rename it: `git branch -m <prefix>/<area>-<summary>`. If EnterWorktree isn't available, fall back to:

```
git worktree add --no-track .claude/worktrees/<short-name> -b <prefix>/<area>-<summary> origin/<default-branch>
```

then work from that directory.

## 5. Make sure the branch can't push to the default branch

Run `git rev-parse --abbrev-ref --symbolic-full-name @{u}`. It should fail with "no upstream configured". If it names the default branch instead (e.g. `origin/main`), run `git branch --unset-upstream`: with some git settings, a branch tracking the default branch pushes its commits straight onto it. Push the branch the first time with `git push -u origin HEAD`.

## 6. Set up the worktree

- If the repo has a dependency install step (a `yarn.lock` / `package-lock.json` / `pnpm-lock.yaml` etc.), run it: worktrees do not share `node_modules` with the main checkout.
- If the repo relies on untracked local config (`.env*`, secrets directories), copy or symlink those from the main checkout so the app runs.

## 7. Confirm and proceed

Tell the user the branch name and worktree path in one line, then continue with the actual task.
