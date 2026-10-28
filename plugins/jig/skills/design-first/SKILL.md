---
name: design-first
description: Share a design and wait for the user to confirm before making any change. Use whenever the user asks for work that would edit files (feature, fix, refactor, docs, config), before the first edit and before start-work, even when the request sounds clear.
---

# Design first, then build

The user wants to see the plan and say go before anything changes. Reading, searching, and running read-only commands are fine; editing files, creating branches or worktrees, and committing are not, until they confirm.

## 1. Look before proposing

Read enough of the code, docs, and notes to make the design concrete. Don't guess at things you can check.

## 2. Check what's current

Model knowledge lags, and feeling sure about a library or pattern is not evidence that it's still current. Whenever the design picks a library, framework, API, tool, or approach, search the web for its current version and what's recommended now, and compare that with what the repo already uses. Staying on the existing stack is often right, but say when it's behind. Scale the effort to the change: a one-line fix with nothing external needs no research; a new feature or dependency does.

## 3. Hold it to the principles

Load the `jig:build-principles` skill and check the design against it. Build in what applies rather than leaving it for review: offline behavior, data safety, tests, error handling, rendering screens before handing off. Any principle the design bends goes under **Decisions** with the reason.

## 4. Share the design

Keep it as short as the change allows: a few lines for a small fix, a page for a feature.

- **Goal:** what changes for the user, in one or two sentences.
- **Approach:** how it will work, and the files or pieces it touches.
- **Current practice:** what you checked, what you found, and source links; or one line saying why no research was needed.
- **Decisions:** any choice the user should make, each with your recommendation.
- **Not doing:** anything nearby you are deliberately leaving out.

End by asking whether they're ready for you to start. Then stop and wait.

## 5. Build only after a clear yes

- Feedback means revise and share again, not start.
- Approval covers that design. If the work turns out to need something materially different, stop and check back before going on.
- Once confirmed, continue with `jig:start-work`.

Skip this only when the user says to go ahead without a design ("just do it", "no need to check").
