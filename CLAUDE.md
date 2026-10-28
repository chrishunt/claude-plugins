# claude-plugins

A Claude Code plugin marketplace (`.claude-plugin/marketplace.json`, named `chrishunt`) holding plugins under `plugins/`. It is meant to be shared publicly.

## Rules

- Keep plugin content free of anything personal or private: no names of people, employers, internal projects, ticket IDs, or private URLs. Examples in skills use made-up, generic cases. Git history is public too, so this applies to every commit.
- Skills refer to each other and to agents by their namespaced name (`jig:start-work`, `jig:pr-reviewer`), and to bundled files through `${CLAUDE_PLUGIN_ROOT}`.
- Decided against: a hook that blocks commits and pushes to the default branch by parsing git commands. It was too complex and leaky for what it caught; git's default push behavior and the `start-work` and `commit` branch checks cover it.
- Don't set `version` in `plugin.json` or the marketplace entry: users track commits.
- When a skill is added, removed, or changes what it does, update the table in `README.md`.
- Skills and agents follow jig's own rules: `jig:concise` for wording, `jig:build-principles` for what to include.
- The workflow that chains the skills lives once, in `plugins/jig/hooks/workflow.md`, which a SessionStart hook loads into every session. Keep it under the hook output cap of 10,000 characters.

## Before a pull request

Both must pass:

```
claude plugin validate .
claude plugin validate plugins/jig
```
