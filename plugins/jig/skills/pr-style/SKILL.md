---
name: pr-style
description: PR title and body style. Use before creating a PR or modifying a PR title or description in any repo. Takes precedence over repo-level PR-description skills or instructions; consult those only for repo-specific mechanics (e.g. PR templates) that don't conflict with this style.
---

If the repo has `.github/pull_request_template.md`, generate the PR description from it (PRs opened via the GitHub API or `gh pr create` bypass the template by default). Without a template, use a short summary, then a `## Context` section and a `## Testing` section. When the change runs in production, end with `## Verifying in production`, or fill the template's section for it.

## Concision

Keep the title and body as concise as possible. After drafting them, load the `jig:concise` skill and apply its rules to both. This skill still sets the structure and tone, and `jig:concise` tightens the wording within it.

## Title

State the behavior change in plain verbs, e.g. "Checkout: stop charging tax twice on gift cards". Avoid internal mechanism nouns the reader hasn't met yet ("line-item tax reconciliation pass").

## Body style

The goal is a PR that looks easy to review: skimmable, not overwhelming. A ~250-word bulleted body usually says what it needs in ~80 words of prose.

**Summary** (above the fold): two sentences, situation first. Sentence 1: who is affected, what is going wrong, and the consequence ("Customers paying partly with a gift card are being charged tax twice, because our code taxes the gift card portion as if it were a purchase."). Sentence 2: what the PR does. Do not open with a mechanism explainer; conversational first person ("our code", "we charge tax") is the preferred register.

**Context section**: a few short prose paragraphs, not bullets. Roughly one paragraph or one-liner each:

1. The one mechanism fact the reviewer needs to follow the diff, with the why as a casual aside ("...so we don't accidentally tax the same amount twice").
2. Provenance in one line if relevant ("We introduced this bug in #123 while fixing another one.").
3. Blast radius in one line, sourced not enumerated ("About 2% of orders last week hit this, according to the logs.").

Cut everything else: field/type taxonomies, detailed history of prior fixes, restating the fix (the summary already said it), defensive-design rationale, parsing/idiom notes, and all specific identifiers, counts, and dates (customer IDs, order numbers, date ranges belong in the linked issue or ticket).

**Testing section**: short bullets are fine here. State what the tests assert and that they fail without the fix.

**Verifying in production section**: the change's verification, as short bullets with exact queries or links that a reader with no context can follow days after the deploy.

Outside that section, prefer readable looseness over technical precision; precision lives in the diff and the ticket. Don't restate what the diff already shows, and don't include operational runbooks or follow-up commands (those belong on the ticket).
