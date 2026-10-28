---
name: cleanup-work
description: Clean up worktrees and local and remote branches whose PRs have merged. Use after a PR merges, or when the user asks to tidy up branches/worktrees. `/cleanup-work` with no argument sweeps all of the user's prefixed worktrees and branches; pass a branch or worktree name to target one.
argument-hint: "[branch or worktree, omit to sweep all]"
---

# Clean up merged work

## 1. Determine targets

Run `git fetch origin --prune` first, so the list of remote branches is current.

- No argument: every worktree, local branch, and remote branch under the user's branch prefix (from `git worktree list`, `git branch --list '<prefix>/*'`, and `git branch -r --list 'origin/<prefix>/*'`), plus any worktree `git worktree list` marks `prunable`. The prefix is the one `jig:start-work` names branches with.
- With an argument: just that branch or worktree, along with its remote branch.

Anyone with push access can name a remote branch, so take one as a target only if its name matches `^[A-Za-z0-9._/-]+$`; otherwise skip it and report the unusual name. Always single-quote branch names and paths in commands.

## 2. Verify merge state, never skipping this

For each target branch, look up its PRs with `gh pr list --head '<branch>' --state all`, including each one's `headRefOid`.

- Any `OPEN` PR for the branch: skip it and say why, even if an earlier PR from it merged.
- Otherwise a `MERGED` PR: cleanup candidate. Its checks below use the most recent merged PR.
- `CLOSED` without merge, or no PR found: skip it and say why.
- A worktree marked `locked` in `git worktree list` likely has a live session; skip it and mention it.
- If the remote branch exists and `git rev-parse 'origin/<branch>'` differs from the merged PR's `headRefOid`, someone pushed after the merge: keep the remote branch and say why. The local branch and worktree can still go.

Delete a skipped branch only if the user explicitly confirms. Even then, leave its remote branch unless they confirm that too, after being told that deleting it closes any open PR and may destroy the only copy of the work.

PRs are often squash-merged, so `git branch -d` will refuse even for merged work. The gh merge state above is the source of truth; after it confirms `MERGED`, force-delete is safe.

## 3. Confirm every removal with the user

Nothing is deleted unconfirmed. The one exception is a branch whose PR `jig:ship` just merged at the user's request: that request is the confirmation, so skip this step for that branch.

Present each cleanup candidate before touching it, with enough context to recognize the work:

- branch name, where it exists (local, remote, or both), and worktree path if any
- PR number, title, and merge date
- a very brief summary of the changes (one sentence; the PR title usually suffices, otherwise glance at `gh pr view <number> --json body,files`)

Then ask which to remove. With multiple candidates, use AskUserQuestion with multiSelect so the user can approve all, some, or none in one prompt. Only proceed for the ones confirmed.

## 4. Clean up each confirmed target

Skip the steps for whatever the target doesn't have (no worktree, no local branch, or no remote branch).

1. If the current session is inside the worktree being removed, leave it first with ExitWorktree `action: "keep"`, or move back to the main checkout. Never use `remove` or `discard_changes`: squash-merged commits look unmerged to it.
2. Check for uncommitted files: `git -C <worktree-path> status --porcelain`. If non-empty, show what's there and re-confirm with the user before removing (dirty state is worth a second look even after step 3's approval).
3. `git worktree remove <worktree-path>` (add `--force` only after a dirty state was confirmed disposable).
4. `git branch -D <branch>`
5. If any open PR is based on this branch (stacked work), move it onto the merged PR's base before deleting the remote branch: `gh pr edit <child> --base <base>`, then in the child's worktree, `git rebase --onto 'origin/<base>' <headRefOid>` to drop the parent's commits, and push with `--force-with-lease`. If the rebase conflicts, abort it and ask the user.
6. `git push --force-with-lease='<branch>:<headRefOid>' origin --delete '<branch>'`, so the remote refuses if the branch moved since step 2. If the push fails, run `git ls-remote --heads origin '<branch>'`: empty output means the branch was deleted after the fetch, so move on; otherwise someone pushed after the merge, so keep it and say why.

## 5. Report

One line per target: what was removed (worktree, local branch, remote branch) and any stacked PR moved onto the new base, or skipped and why (open PR, locked, dirty, pushed after merge, no PR found).
