---
name: review-pr
description: Review an open pull request with fresh-context agents on the strongest model, one per lens (correctness, security, spec, maintainability), check every finding with a second independent agent, then fix what holds up, run the repo's checks, and push. Use right after opening a PR for finished work, or when the user asks for a fresh review of a PR.
argument-hint: "[PR number or URL, defaults to the current branch's PR]"
---

# /review-pr — fresh review, checked findings, fixes

The point is fresh eyes. The reviewers must not inherit this session's context, so each runs as a `jig:pr-reviewer` agent (a new agent, not a fork) and is told only which PR to read and its lens. The checkers run as `jig:finding-checker` agents, one per finding. Both run on the strongest model: when spawning either one, pass `model` set to the most capable model the Agent tool offers.

## 1. Pin down the PR

- The argument, or `gh pr view --json number,url,headRefName,baseRefName,title` for the current branch.
- The working tree must be clean and the branch pushed (`git status`, `git log @{u}..`), so the reviewer reads exactly what's on the PR. If not, stop and ask the user whether to commit and push first.
- Note the absolute path of the checkout (the worktree, if the session is in one).

## 2. Review with fresh agents, one per lens

Spawn one `jig:pr-reviewer` per lens, all in one message so they run in parallel: `correctness`, `security`, `spec`, `maintainability`. Skip a lens that can't apply (e.g. `security` for a docs-only change) and note it for the report. Give each only this, not a summary of the work or what you think is risky:

> Review pull request #<n> in <owner/repo> through the <lens> lens. The checkout is at <absolute path>, on branch <head>, based on <base>.

If every reviewer returns `Findings: 0`, tell the user in one line and stop.

## 3. Merge the findings

Combine the lists. Where findings share a location or a cause, keep one, with the clearest wording and the highest severity. Renumber them F1, F2, and so on.

## 4. Check each finding with another agent

Spawn one `jig:finding-checker` per finding, all in one message so they run in parallel. Give each the PR line from step 2, without the lens, plus that finding's block verbatim. With more than about 12 findings, give each checker two or three related findings instead, and ask for one verdict block per finding.

## 5. Fix what holds up

- **CONFIRMED and "Fix in this PR: yes"**: fix it in this session, following the repo's `CLAUDE.md`. Add or adjust a test when the finding is a behavior bug. Fix in severity order and keep each fix to the finding's scope.
- **"ask"**, **UNCERTAIN**, or a fix that would change behavior the user chose: don't stop to ask. Make the call you would have recommended, weighing the spec, the repo's `CLAUDE.md`, the user's earlier decisions in this session and in memory, and the checker's reasoning. That call may be to fix, to fix differently, or to leave the code as it is. When the recommended call is a redesign beyond the finding's scope, leave the code as it is. Record each call for the report.
- **REFUTED**, or CONFIRMED with "no": don't fix; list in one line each.
- Anything under "Other" from a checker is treated as a new finding: verify it yourself before fixing.

If nothing is fixed, skip to step 7.

## 6. Run the checks and push

- Run the repo's pre-PR gate as its `CLAUDE.md` describes (formatting, lints, tests, and anything else it asks for when the touched area changes). Fix failures; don't push red.
- Commit the fixes with a message saying what was fixed (not "address review"), and push to the PR branch. If the fixes change what the PR description says, update it with the `jig:pr-style` skill.
- Don't post review comments on the PR.

## 7. Report

A short table: finding, severity, verdict, what happened (fixed / left as is / refuted). Then the commit pushed, the gate result, and any lens skipped.

Then **Calls I made**: one entry for each finding decided under the "ask" rule and each assumption you relied on. Give what you decided, why, and the alternative, so the user can reverse any of them with one reply. If there were none, say so. If the fixes were large, offer one more round of this skill on the new head.
