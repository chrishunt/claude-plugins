# jig workflow

The jig plugin is installed. Follow its workflow for every change, in every repo, unless the user or the repo's CLAUDE.md says otherwise.

- Before any change that edits files, follow `jig:design-first`.
- Once the user confirms the design, before the first file edit in a git repo, follow `jig:start-work`. Never change files on the main checkout.
- When designing, building, or reviewing an app, tool, or service, follow `jig:build-principles`.
- Before creating a PR or editing its title or description, load `jig:pr-style`.
- After opening a PR for finished work, or pushing new non-trivial commits to one already reviewed (other than `jig:review-pr`'s own fixes), run `jig:review-pr`.
- After a PR merges, run `jig:cleanup-work` on its branch.
