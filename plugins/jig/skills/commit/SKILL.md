---
name: commit
description: Commit changes. Use '/commit' to stage and commit what belongs together, or '/commit staged' to commit only what's already staged.
argument-hint: "[staged]"
---

# Commit

With the `staged` argument, commit only what's already in the index, and stop if nothing is. Otherwise, stage what belongs in the commit.

- **Not on the default branch.** If the current branch is the default branch of a repo with a remote, stop: changes go through a pull request, so move the work onto its own branch with `jig:start-work` first. A brand-new repo with no remote branches yet is fine.
- **Stage files by name,** never `git add -A` or `git add .`. Keep out secrets, build output, editor and OS files, and large generated files. If one isn't ignored yet, add it to `.gitignore` in this commit and tell the user.
- **Message:** an imperative subject of 50 characters or fewer with no trailing period, then a blank line and a short prose body, wrapped at 72 columns, saying what changed and why.
