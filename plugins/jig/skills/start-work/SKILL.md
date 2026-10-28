---
name: start-work
description: Start a code change on its own branch in an in-repo worktree. Use right before the first file edit of any change in a git repo (not just when invoked as /start-work), after any design step has been approved. Checks for existing branches and PRs that may already cover the change, then creates a <prefix>/<area>-<summary> branch in a worktree, based on the fresh remote default branch or, for stacked work, on a parent PR's branch.
argument-hint: "[short description of the change]"
---

# Start work on its own branch and worktree

The argument describes the change. If there is none and the conversation doesn't make it clear, ask.

Branches start with a prefix: the one the user's instructions give, otherwise their GitHub login (`gh api user --jq .login`).

## 1. Check for existing work

Fetch, then look for your local and remote branches, worktrees, and open PRs that may already cover this change. If one does, ask the user whether to reuse it. Never quietly create a near-duplicate.

To reuse one, enter its worktree with EnterWorktree `path`, or give the branch a worktree with `git worktree add '<main-checkout>/.claude/worktrees/<summary>' '<branch>'` and enter that. If `git rev-parse --abbrev-ref --symbolic-full-name @{u}` then names the default branch or the parent PR's branch, run `git branch --unset-upstream`, for the reason in step 3.

## 2. Name the branch

`<prefix>/<area>-<summary>`: the prefix, one word for the area being touched (or a ticket ID), and a verb-first summary, e.g. `<prefix>/billing-fix-line-item-quantity-parsing`.

## 3. Create the worktree and enter it

The base is the remote default branch, or, for work stacked on an open PR, that PR's branch. Worktrees always go under the main checkout (the first entry in `git worktree list`), even when the session is in another worktree; one nested inside another worktree is deleted along with it.

```
git worktree add --no-track -b '<branch>' '<main-checkout>/.claude/worktrees/<summary>' 'origin/<base>'
```

Then call EnterWorktree with that `path` (load it with ToolSearch if it's deferred). Creating the worktree yourself, rather than letting EnterWorktree name it, gives the branch its real name and no upstream. A branch that tracks its base can push its commits straight onto the default branch or the parent PR.

If `git check-ignore -q .claude/worktrees/x` fails, add `.claude/worktrees/` to the file at `git rev-parse --git-path info/exclude`, so worktrees don't show up as untracked files.

Push the first time with `git push -u origin HEAD`. Open a stacked PR against its parent branch.

## 4. Set up the worktree

A worktree shares nothing untracked with the main checkout. Install dependencies, and copy or symlink any untracked local config the app needs to run (`.env*`, secrets).

## 5. Work inside the worktree

Claude Code refuses Bash commands it can't verify stay inside the worktree. To avoid that:

- Change files with Edit and Write, not `sed -i` or scripts.
- Run one simple command per Bash call, from the worktree. No `cd`, no `git -C`, and no paths held in shell variables.
- Put multi-step logic in a script in the scratchpad directory and run it by its literal path.

## 6. Confirm and proceed

Tell the user the branch name and worktree path in one line, then continue with the task.
