---
name: review-pr
description: Review an open pull request with fresh-context agents, one per lens (correctness, security, spec, maintainability), check every finding with a second independent agent, then fix what holds up, run the repo's checks, and push. Use right after opening a PR for finished work, after pushing new non-trivial commits to a reviewed PR (other than this skill's own fixes), or when the user asks for a fresh review of a PR.
argument-hint: "[PR number or URL, defaults to the current branch's PR]"
---

# Review a PR with fresh eyes

The point is fresh eyes. The reviewers must not inherit this session's context, so each runs as a `jig:pr-reviewer` agent (a new agent, not a fork) and is told only which PR to read and its lens. The checkers run as `jig:finding-checker` agents, one per finding. Don't pass a `model` when spawning either one: they run on the session's model, so every review is held to the same standard.

## 1. Pin down the PR

- The argument, or the current branch's PR.
- The working tree must be clean and the branch pushed (`git status`, `git log @{u}..`), so the reviewer reads exactly what's on the PR. If not, stop and ask the user whether to commit and push first.
- Note the absolute path of the checkout (the worktree, if the session is in one).

## 2. Review with fresh agents, one per lens

Spawn one `jig:pr-reviewer` per lens, all in one message so they run in parallel: `correctness`, `security`, `spec`, `maintainability`. Skip a lens that can't apply (e.g. `security` for a docs-only change). Give each only this, not a summary of the work or what you think is risky:

> Review pull request #<n> in <owner/repo> through the <lens> lens. The checkout is at <absolute path>, on branch <head>, based on <base>.

If every reviewer returns `Findings: 0`, tell the user in one line and stop.

## 3. Merge the findings

Combine the lists. Where findings share a location or a cause, keep one, with the clearest wording and the highest severity. Renumber them F1, F2, and so on.

## 4. Check each finding with another agent

Spawn one `jig:finding-checker` per finding, all in one message so they run in parallel. Give each the PR line from step 2, without the lens, plus that finding's block verbatim.

## 5. Fix what holds up

- **CONFIRMED and "Fix in this PR: yes"**: fix it in this session, following the repo's `CLAUDE.md`. Add or adjust a test when the finding is a behavior bug. Fix in severity order and keep each fix to the finding's scope.
- **"ask"**, **UNCERTAIN**, or a fix that would change behavior the user chose: don't stop to ask. Make the call you would have recommended, weighing the spec, the repo's `CLAUDE.md`, the user's earlier decisions in this session and in memory, and the checker's reasoning. That call may be to fix, to fix differently, or to leave the code as it is. When the recommended call is a redesign beyond the finding's scope, leave the code as it is. Record each call for the report.
- **REFUTED**, or CONFIRMED with "no": don't fix. Note the CONFIRMED ones for the report.
- Anything under "Other" from a checker is treated as a new finding: verify it yourself before fixing.

If nothing is fixed, skip to step 7.

## 6. Run the checks and push

- Run the repo's pre-PR gate as its `CLAUDE.md` describes (formatting, lints, tests, and anything else it asks for when the touched area changes). Fix failures; don't push red.
- Commit the fixes with a message saying what was fixed (not "address review"), and push to the PR branch. If the fixes change what the PR description says, update it with the `jig:pr-style` skill.
- Don't post review comments on the PR.

## 7. Report

The user usually hasn't read the code, so report only what they can act on, in terms of what the PR does rather than where in the code. No table, finding numbers, severities, verdicts, or lens names. Refuted findings and skipped lenses stay out, and so do routine fixes, which the fix commit records.

Start with one line: how many issues were fixed and, if step 6 ran, the commit pushed and that the checks pass. For example, "Review fixed 3 issues and pushed `abc1234`; checks pass.", "Review fixed nothing; 2 issues left for later.", or "Review found nothing to fix."

Then only the sections that have something in them, with each item in exactly one:

- **Problems**: the checks failed, the push failed, or anything else stopped the review from finishing.
- **Changed from the plan**: a fix that changed behavior from what the user approved (e.g. "an empty name now shows an error instead of saving"), with why and the alternative, so they can reverse it with one reply.
- **Left for later**: real problems judged out of scope for this PR, one line each.
- **Your call**: every other call from step 5 the user would notice or that left a possible problem in place, and each assumption they might not share. Give what you decided, why, and the alternative, so they can reverse it with one reply.

If the fixes were large, offer one more round of this skill on the new head.
