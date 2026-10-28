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

For each target branch:

```
gh pr list --head '<branch>' --state all --json number,state,mergedAt,title,headRefOid,baseRefName,isCrossRepository --limit 5
```

Ignore PRs from forks (`isCrossRepository`): they only share the branch name.

- Any `OPEN` PR for the branch: skip it and say why, even if an earlier PR from it merged.
- Otherwise a `MERGED` PR: cleanup candidate. Its checks below use the most recent merged PR.
- `CLOSED` without merge, or no PR found: skip it and say why.
- A worktree marked `locked` in `git worktree list` likely has a live session; skip it and mention it.
- If the remote branch exists and `git rev-parse 'origin/<branch>'` differs from the merged PR's `headRefOid`, someone pushed after the merge: keep the remote branch and say why. The local branch and worktree can still go.
- If the local branch has commits the merged PR doesn't (`git merge-base --is-ancestor '<branch>' '<headRefOid>'` fails), keep the local branch and its worktree and say why.

Delete a skipped branch only if the user explicitly confirms. Even then, leave its remote branch unless they confirm that too, after being told that deleting it closes any open PR and may destroy the only copy of the work.

PRs are often squash-merged, so `git branch -d` will refuse even for merged work. The gh merge state above is the source of truth; after it confirms `MERGED`, force-delete is safe.

## 3. Confirm every removal with the user

Nothing is deleted unconfirmed. The one exception is a branch whose PR `jig:ship` just merged at the user's request: that request confirms removing it and moving the user's own stacked PRs in step 4, so skip this step for that branch.

Present each cleanup candidate before touching it, with enough context to recognize the work:

- branch name, where it exists (local, remote, or both), and worktree path if any
- PR number, title, and merge date
- a very brief summary of the changes (one sentence; the PR title usually suffices, otherwise glance at `gh pr view <number> --json body,files`)
- any open PRs stacked on it, and whether step 4 will move them

Then ask which to remove. With multiple candidates, use AskUserQuestion with multiSelect so the user can approve all, some, or none in one prompt. Only proceed for the ones confirmed.

## 4. Clean up each confirmed target

Skip the steps for whatever the target doesn't have (no worktree, no local branch, or no remote branch).

1. If the current session is inside the worktree being removed, leave it first with ExitWorktree `action: "keep"` (not `remove`: squash-merged commits look unmerged to it), or move back to the main checkout.
2. Check for uncommitted files: `git -C <worktree-path> status --porcelain`. If non-empty, show what's there and re-confirm with the user before removing (dirty state is worth a second look even after step 3's approval).
3. `git worktree remove <worktree-path>` (add `--force` only after a dirty state was confirmed disposable).
4. `git branch -D <branch>`
5. Stacked PRs are the open PRs based on this branch (`gh pr list --base '<branch>' --state open`), plus the user's open PRs whose head contains the merged commit (`git merge-base --is-ancestor '<headRefOid>' 'origin/<child>'`), since GitHub may already have moved those onto the base.
   - Move one onto the merged PR's `baseRefName` only if it's in the same repo, its head branch is under the user's prefix, its name and the base both pass step 1's name check, its head contains `<headRefOid>`, and its worktree is clean, not locked, and at `origin/<child>`.
   - To move it, in its worktree: note `git rev-parse 'origin/<child>'`, run `git rebase --onto 'origin/<base>' '<headRefOid>'`, push with `--force-with-lease='<child>:<noted sha>'`, then `gh pr edit <child> --base '<base>'`. If the rebase conflicts, abort it and ask the user.
   - Leave any other stacked PR alone and report that it needs a rebase.
6. Unless a stacked PR left alone in step 5 still targets this branch, `git push --force-with-lease='<branch>:<headRefOid>' origin --delete '<branch>'`, so the remote refuses if the branch moved since step 2. If the push fails, run `git ls-remote --heads origin '<branch>'`: empty output means the branch was deleted after the fetch, so move on; otherwise someone pushed after the merge, so keep it and say why.

## 5. Report

One line per target: what was removed (worktree, local branch, remote branch) and any stacked PR moved onto the new base, or what was kept and why.
