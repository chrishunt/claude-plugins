# claude-plugins

A Claude Code plugin marketplace (`.claude-plugin/marketplace.json`, named `chrishunt`) holding plugins under `plugins/`. It is meant to be shared publicly.

## Rules

- Keep plugin content free of anything personal or private: no names of people, employers, internal projects, ticket IDs, or private URLs. Examples in skills use made-up, generic cases. Git history is public too, so this applies to every commit.
- Skills refer to each other and to agents by their namespaced name (`jig:start-work`, `jig:pr-reviewer`), and to bundled files through `${CLAUDE_PLUGIN_ROOT}`.
- Don't set `version` in `plugin.json` or the marketplace entry: users track commits.
- When a skill is added, removed, or changes what it does, update the table in `README.md`.

## Before a pull request

All of these must pass:

```
claude plugin validate .
claude plugin validate plugins/jig
plugins/jig/tests/guard-default-branch.test.sh
```

The hook tests run git in throwaway repos under a temp directory. They must also pass under macOS's `/bin/bash` 3.2 (`BASH_UNDER_TEST=/bin/bash`), the oldest bash the hook can meet.
