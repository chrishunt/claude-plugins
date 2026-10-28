---
name: ship
description: Merge a reviewed pull request, clean up its branch and worktree, and run the repo's release or deploy step when asked. Use when the user asks to merge a PR, or to ship, release, or deploy finished work.
argument-hint: "[PR number or URL, defaults to the current branch's PR]"
---

# Ship a PR

Asking to merge is the user's approval to merge this PR and clean up after it. Don't ask again unless a step below says to.

## 1. Check it's ready

- The PR is open and not a draft, and its checks pass. Wait for checks still running; if any fail, stop and report them.
- `jig:review-pr` has reviewed the current head. If nothing in this session shows that, and the PR is more than a version bump or changelog line, run `jig:review-pr` first.

## 2. Merge

- If the session is inside the PR's worktree, leave it with ExitWorktree `action: "keep"`. Never use `remove`: squash-merged commits look unmerged to it, so it asks to discard them.
- Merge with `gh pr merge`, using the merge method the repo allows and its recent PRs used. Don't pass `--delete-branch` (`jig:cleanup-work` removes branches safely) and don't change repo settings.

## 3. Clean up

Run `jig:cleanup-work` on the PR's branch. The user's request to merge confirms removing its worktree and branches, so skip cleanup's confirmation step for this branch only. Its other checks still apply.

## 4. Release

If the user asked to release or deploy, or the repo's CLAUDE.md says every merge ships, run the repo's release or deploy step as its CLAUDE.md describes. If it describes none, say so instead of improvising one.

## 5. Report

One line: the PR merged and how, what cleanup removed, any stacked PRs moved onto the new base, and what was released. Then anything skipped, and why.
