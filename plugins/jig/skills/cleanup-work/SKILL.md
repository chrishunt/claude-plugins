---
name: cleanup-work
description: Clean up local branches and worktrees whose PRs have merged. Use after a PR merges, or when the user asks to tidy up branches/worktrees. `/cleanup-work` with no argument sweeps all of the user's prefixed worktrees and branches; pass a branch or worktree name to target one.
argument-hint: "[branch or worktree, omit to sweep all]"
---

# /cleanup-work — remove merged branches + worktrees

## 1. Determine targets

- No argument: every worktree and local branch under the user's branch prefix (from `git worktree list` and `git branch --list '<prefix>/*'`), plus any worktree `git worktree list` marks `prunable`. The prefix is the one the user's instructions give, otherwise their GitHub login from `gh api user --jq .login`.
- With an argument: just that branch or worktree.

## 2. Verify merge state — never skip this

For each target branch:

```
gh pr list --head <branch> --state all --json number,state,mergedAt,title --limit 3
```

- `MERGED`: cleanup candidate.
- `OPEN`, `CLOSED` without merge, or no PR found: skip it and say why. Only delete these if the user explicitly confirms.
- A worktree marked `locked` in `git worktree list` likely has a live session; skip it and mention it.

PRs are often squash-merged, so `git branch -d` will refuse even for merged work. The gh merge state above is the source of truth; after it confirms `MERGED`, force-delete is safe.

## 3. Confirm every removal with the user — nothing is deleted unconfirmed

Present each cleanup candidate before touching it, with enough context to recognize the work:

- branch name and worktree path
- PR number, title, and merge date
- a very brief summary of the changes (one sentence; the PR title usually suffices, otherwise glance at `gh pr view <number> --json body,files`)

Then ask which to remove. With multiple candidates, use AskUserQuestion with multiSelect so the user can approve all, some, or none in one prompt. Only proceed for the ones confirmed.

## 4. Clean up each confirmed target

1. If the current session is inside the worktree being removed, leave it first (ExitWorktree, or move back to the main checkout).
2. Check for uncommitted files: `git -C <worktree-path> status --porcelain`. If non-empty, show what's there and re-confirm with the user before removing (dirty state is worth a second look even after step 3's approval).
3. `git worktree remove <worktree-path>` (add `--force` only after a dirty state was confirmed disposable).
4. `git branch -D <branch>`
5. After all targets: `git worktree prune` and `git fetch --prune`.

## 5. Report

One line per target: removed, or skipped and why (open PR, locked, dirty, no PR found).
