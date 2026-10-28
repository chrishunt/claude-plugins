---
name: build-principles
description: The standards every app, tool, or service must meet, covering product scope, interface design, engineering, and process. Use when designing, building, or reviewing an app, feature, UI, or service (alongside any design or pull request review step), and whenever choosing between approaches.
---

# Build principles

Hold every design, change, and review to the ones that bear on what it touches. When a choice bends one, say which and why. A repo's own CLAUDE.md or spec may be stricter or decide otherwise for that repo; follow it there.

## Product

- **Only what's needed.** Add a feature only if the app can't work without it or it has a big impact. Record ideas decided against, with the reason, in the repo's docs so they aren't proposed again.
- **Obvious without help.** Follow the platform's conventions and interface guidelines, so a new user needs no manual, onboarding, or explanation. Put an occasional hint in hover help, not an info box. Before departing from a convention, check what the platform's own apps and the best apps in the category do.
- **Plain words.** One name per thing and one thing per name, across screens, docs, and code. Never show internal terms, jargon, or raw scores.
- **Works offline.** Nothing breaks or disappears when the network drops. Keep the last good data, refresh quietly when connected, and never lose a cache to a failed fetch.
- **The user's data is safe and theirs.** Keep raw data in open, documented formats that are readable without the app, and backfill history for anything collected from now on. Version saved formats, and keep files from every release loading. Reach outside sources through small adapters so one can be swapped without touching the rest. Back up before anything risky.

## Design

- **Everything means something.** Color, type, weight, icons, and layout carry meaning: the same thing always looks the same, and different things look different. Use color only when it means something, and stay monochrome otherwise. Build from shared tokens and components instead of styling inline.
- **Expert craft in every detail.** Typography, spacing, alignment, hierarchy, iconography, light and dark mode, and accessibility (touch targets, contrast, text scaling, reduced motion) follow current best practice for the platform.
- **Show, then decide.** When a visual choice is the user's, render real options with real content, varied from safe to bold, and iterate from feedback. Don't describe what could be shown.
- **Look before handing off.** Render every screen and state a change touches (small and large, light and dark, empty, full, and error) and review them as an expert designer would, ideally with a fresh agent. Fix cramped or clipped text, misalignment, flicker, and layout shift before asking the user to look.
- **Smooth is fast.** No jank, flicker, or jumping content. Transitions are quick, and things stay in place while data loads.

## Engineering

- **Current best practice, researched.** Check current docs, versions, and recommendations instead of relying on memory. The standards of expert practitioners in every field the app touches apply.
- **Simple, with no duplication.** Each rule, value, and concept lives in exactly one place, so consistency follows. Prefer removing complexity to managing it.
- **Instructions hold only what a model would miss.** Skills, agents, prompts, and CLAUDE.md files record preferences, safety guards, and lessons from real mistakes, and leave out how-to a capable model already knows.
- **Logic in a tested core.** Behavior lives in a UI-free module with tests, and views only lay out and handle input. A rule is written once and shared by every platform and surface.
- **Tested end to end.** Tests cover all behavior: logic, UI flows, parsing, migrations, saved-format compatibility, network, and error paths. They fail without the change they protect. Check models, parsers, and estimates against real data as well as hand-made fixtures, and keep real test data beside the repo, out of version control.
- **Fast by design.** Measure, then make startup, loading, and interaction as quick as possible. Cache sensibly, invalidate correctly, and keep slow work off the user's path.
- **Robust.** Recover without the user wherever possible: retry with backoff, reconnect, resume, fall back. Show an error only when the user can act on it, in plain words that say what to do.
- **Dependencies stay current.** Don't pin to arbitrary old versions. Update, read what changed, and check the impact.
- **Secure and private by default.** Secrets live in the system keychain or a password manager, never in the repo or in plain text. Expose services only as widely as needed, and encrypted. Share as little as possible with third parties.
- **Reuse the user's patterns.** Before inventing a structure, script, or setup, look at how the user's other projects already solve it, and match them.
- **Careful with the real world.** Ask before anything with effects outside the sandbox: live networks or services, real devices or speakers, signed-in accounts, and deleting or overwriting data.

## Process

- **Pull requests, reviewed fresh.** Every change goes through a pull request reviewed by an agent with no context from the work, and what holds up gets fixed.
- **Docs say why, once.** Each decision has one doc that owns it, written for a reader with no context, while exact numbers live in code. Add one short changelog line for each change a user would notice, and version releases properly.
- **Concise everywhere.** UI text, docs, changelogs, commits, and replies are as short as possible without losing anything important. Comments only explain a non-obvious why, never what the code already shows.
