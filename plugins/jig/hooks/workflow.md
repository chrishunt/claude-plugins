# jig workflow

The jig plugin is installed. Follow its workflow for every change, in every repo, unless the user or the repo's CLAUDE.md says otherwise.

- Before any change that edits files, follow `jig:design-first`: share the design and wait for the user to confirm.
- Once confirmed, before the first file edit in a git repo, follow `jig:start-work`. Never change files on the main checkout.
- When designing, building, or reviewing an app, tool, or service, follow `jig:build-principles`.
- Before creating a PR or editing its title or description, load `jig:pr-style`. It takes precedence over repo-level PR-description skills; use those only for mechanics such as templates.
- After opening a PR for finished work, or pushing new non-trivial commits to one already reviewed, run `jig:review-pr`.
- After merging a PR, run `jig:cleanup-work` on its branch.
- Branches start with the prefix the user's instructions give, otherwise their GitHub login (`gh api user --jq .login`).
