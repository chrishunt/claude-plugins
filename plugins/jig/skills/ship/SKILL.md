---
name: ship
description: Merge a reviewed pull request, clean up its branch and worktree, and run the repo's release or deploy step when asked or when the repo says every merge ships. Use when the user asks to merge or ship a PR.
argument-hint: "[PR number or URL, defaults to the current branch's PR]"
---

# Ship a PR

Asking to merge is the user's approval to merge this PR and clean up after it. Don't ask again unless a step below says to.

## 1. Check it's ready

- Find the PR's number, head branch, and base while still in its worktree.
- The base is the default branch. If it's another PR's branch, stop and offer to ship that PR first.
- `jig:review-pr` has reviewed the current head. If nothing in this session shows that, and the PR is more than a version bump or changelog line, run it now. If its report changed behavior from the plan, stop and wait for the user.
- The PR is open and not a draft, and its checks pass on the current head. Wait for checks still running; if any fail, stop and report them.
- Note the head commit those checks passed on, and the open PRs based on the head branch, before anything changes.

## 2. Merge

Run `gh pr merge <number> --match-head-commit <sha>`, with the merge method the repo allows and its recent PRs used. If the head moved, stop and report it. Don't pass `--delete-branch`, and don't change repo settings.

## 3. Clean up

Run `jig:cleanup-work` on the head branch, passing along the stacked PRs noted in step 1.

## 4. Release

If the user asked to release or deploy, or the repo's CLAUDE.md says every merge ships, run the repo's release or deploy step as its CLAUDE.md describes. If it describes none, say so instead of improvising one.

## 5. Report

One line for the merge, how it was merged, and anything released, followed by `jig:cleanup-work`'s report.
