---
name: commit
description: "Commit changes. Use '/commit' to stage & commit all, or '/commit staged' to commit only what's already staged."
---

# /commit — Smart Git Commit

You are creating a git commit. Check the argument passed to this skill:

- **No argument** (`/commit`): follow all steps below (stage and commit).
- **`staged`** (`/commit staged`): skip step 4 entirely — only commit what is already in the index. If `git diff --cached` is empty, warn the user that nothing is staged and stop.

Follow these steps exactly:

## 1. Make sure you're not on the default branch

Run `git branch --show-current` and compare it with the remote default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, e.g. `origin/main`). If they match, stop: changes go through a pull request, so move the work onto its own branch with `jig:start-work` first. Committing on the default branch is fine only when the repo has no remote, or the remote has no default branch yet (a brand-new repo).

## 2. Understand what changed

Run `git status` and `git diff` (both staged and unstaged) to review all changes. Also run `git log --oneline -5` to see recent commit style for context.

## 3. Check for files that should NOT be committed

Review `.gitignore` and compare against untracked/changed files. Look for:
- Build artifacts, derived data, `.build/` or `dist/` directories
- Secrets, credentials, `.env` files
- IDE/editor state (`.idea`, `.vscode/settings.json`, `xcuserdata`)
- OS junk (`.DS_Store`, `Thumbs.db`)
- Large binaries or generated files

If any such files exist, notify the user, and update `.gitignore` first and include that change in the commit.

## 4. Stage files selectively *(skip if `staged` argument was provided)*

Stage relevant files by name. Do NOT use `git add -A` or `git add .` blindly. Exclude secrets, large binaries, and anything that belongs in `.gitignore`.

## 5. Craft the commit message

- **Subject line**: imperative mood, ≤50 characters, no trailing period
  - Examples: "Add input validation to signup form", "Fix date parsing for leap years"
- **Body**: separated by a blank line, then concise bullet points summarizing each logical change

Format using a heredoc:
```
git commit -m "$(cat <<'EOF'
Subject line here

- First logical change
- Second logical change
EOF
)"
```

## 6. Confirm

After committing, run `git log -1` to show the result.
