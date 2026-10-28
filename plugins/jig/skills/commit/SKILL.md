---
name: commit
description: Commit changes. Use '/commit' to stage and commit all changes, or '/commit staged' to commit only what's already staged.
argument-hint: "[staged]"
---

# Commit

- **Not on the default branch.** If the current branch is the default branch of a repo with a remote, stop: changes go through a pull request, so move the work onto its own branch with `jig:start-work` first. A brand-new repo with no remote branches yet is fine.
- **Keep junk and secrets out,** in both modes: secrets, build output, editor and OS files, and large generated files. If one isn't ignored yet, add it to `.gitignore` and tell the user. With `staged`, if one is already staged, stop and tell the user instead of changing the index.
- **Stage:** with `staged`, commit only what's already in the index, and stop if nothing is. Otherwise stage all changes by name, never with `git add -A` or `git add .`.
- **Message:** an imperative subject of 50 characters or fewer with no trailing period, then a blank line and a short prose body, wrapped at 72 columns, saying what changed and why.
