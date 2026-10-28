# claude-plugins

A Claude Code plugin marketplace (`.claude-plugin/marketplace.json`, named `chrishunt`) holding plugins under `plugins/`. It is meant to be shared publicly.

## Rules

- Keep plugin content free of anything personal or private: no names of people, employers, internal projects, ticket IDs, or private URLs. Examples in skills use made-up, generic cases. Git history is public too, so this applies to every commit.
- Skills refer to each other and to agents by their namespaced name (`jig:start-work`, `jig:pr-reviewer`), and to bundled files through `${CLAUDE_PLUGIN_ROOT}`.
- Decided against: a hook that blocks commits and pushes to the default branch by parsing git commands. It was too complex and leaky for what it caught; git's default push behavior, `start-work` creating branches with no upstream, and `commit`'s default-branch check cover it.
- Don't set `version` in `plugin.json` or the marketplace entry: users track commits.
- When a skill is added, removed, or changes what it does, update the table in `README.md`.

## Before a pull request

Both must pass:

```
claude plugin validate .
claude plugin validate plugins/jig
```
