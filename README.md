# claude-plugins

Claude Code plugins by Chris Hunt. There is one so far: **jig**.

## jig

A jig guides a tool so every cut comes out the same. This one guides Claude through a careful development workflow: agree on a design, work on its own branch, open a short pull request, have a fresh agent review it, and clean up after it merges.

| Skill | What it does |
| --- | --- |
| `design-first` | Before editing anything, shares a short design (goal, approach, research on current practice, decisions, what's left out) and waits for a yes. |
| `build-principles` | The standards designs and reviews are held to: only what's needed, plain words, offline first, the user's data is safe, tested core, fresh reviews, concise everywhere. |
| `start-work` | Right before the first edit, checks for existing branches and PRs, then makes a `<github-login>/<area>-<summary>` branch in a worktree inside the repo. |
| `commit` | Reviews the diff, keeps junk and secrets out, stages files by name, and writes a short imperative commit message. |
| `pr-style` | PR titles and bodies: two sentences up top, a little prose context, then what the tests check. |
| `concise` | Rewrites any text to be as short as possible without losing anything important. |
| `review-pr` | Fresh-context agents review the PR in parallel, one each for correctness, security, spec, and maintainability. Their findings are merged, a second agent tries to disprove each one, and what holds up gets fixed and pushed. |
| `ship` | When you ask to merge, checks the PR is reviewed and green, merges it, cleans up without asking again, and runs the repo's release step if you asked for one or the repo says every merge ships. |
| `cleanup-work` | After a PR merges, confirms the merge with `gh`, moves any stacked PRs onto the new base, and removes the worktree and the local and remote branches. |

At the start of every session, a hook gives Claude the workflow that ties the skills together, so they run in order with no setup. You can also run any of them directly, e.g. `/jig:review-pr`. The `pr-reviewer` and `finding-checker` agents do the work for `review-pr`.

### Install

```
/plugin marketplace add chrishunt/claude-plugins
/plugin install jig@chrishunt
```

To get updates automatically, open `/plugin`, go to **Marketplaces**, select `chrishunt`, and turn on auto-update. Otherwise run `/plugin marketplace update chrishunt`.

jig needs `git` and the GitHub CLI (`gh`).

### Make it yours

- **Branch prefix:** branches start with your GitHub login. To use something else, say so in your `~/.claude/CLAUDE.md`, e.g. "Name branches `jane/<area>-<summary>`".
- **Commit and PR attribution:** jig leaves this to Claude Code's [`attribution` setting](https://code.claude.com/docs/en/settings).
- **Merging in auto mode:** auto mode may stop `ship` and ask you to approve the merge. To let it merge without asking, add `"Bash(gh pr merge *)"` to `permissions.allow` in `~/.claude/settings.json`; `ship` still merges only reviewed, green PRs.
- **A different workflow in one repo:** say so in that repo's `CLAUDE.md`, which wins over jig's. To turn jig off there entirely, add `"enabledPlugins": {"jig@chrishunt": false}` to the repo's `.claude/settings.local.json`.

### Other tools

The skills use the open Agent Skills format, so other coding agents can load them, but jig is built and tested for Claude Code. The agents only work there, and some steps use Claude Code tools such as worktrees and subagents.

## Developing

Run these before opening a pull request:

```
claude plugin validate .
claude plugin validate plugins/jig
```

To try an unmerged change, start Claude with `claude --plugin-dir plugins/jig` from your checkout.
