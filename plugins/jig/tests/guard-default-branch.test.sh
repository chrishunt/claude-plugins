#!/usr/bin/env bash
# Tests for scripts/guard-default-branch.sh. Builds throwaway repos, feeds the
# hook a PreToolUse event for each command, and checks whether it blocks.
#
#   tests/guard-default-branch.test.sh            # with bash from PATH
#   BASH_UNDER_TEST=/bin/bash tests/guard-...sh   # with another bash

set -u
hook="$(cd "$(dirname "$0")/.." && pwd)/scripts/guard-default-branch.sh"
shell=${BASH_UNDER_TEST:-bash}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Ignore the machine's git config so results don't depend on it.
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com

passed=0
failed=0

# expect <allow|block> <cwd> <command> [description]
expect() {
  local want=$1 cwd=$2 cmd=$3 got
  jq -n --arg c "$cmd" --arg d "$cwd" \
    '{hook_event_name: "PreToolUse", tool_name: "Bash", tool_input: {command: $c}, cwd: $d}' |
    "$shell" "$hook" 2> /dev/null
  case $? in
    0) got=allow ;;
    2) got=block ;;
    *) got=error ;;
  esac
  if [ "$got" = "$want" ]; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "FAIL: ${4:-$cmd} (in ${cwd#"$tmp"/}): want $want, got $got"
  fi
}

# A remote with main, cloned to work/, with a feature branch that has no upstream.
git init -q --bare -b main "$tmp/remote.git"
git clone -q "$tmp/remote.git" "$tmp/seed" 2> /dev/null
git -C "$tmp/seed" commit -q --allow-empty -m init
git -C "$tmp/seed" push -q origin main
git clone -q "$tmp/remote.git" "$tmp/work"
git -C "$tmp/work" branch -q --no-track feature origin/main
git -C "$tmp/work" branch -q --track tracks-main origin/main
work=$tmp/work

# work-main/ is the same repo with main checked out, via a worktree.
git -C "$work" switch -q feature
git -C "$work" worktree add -q "$tmp/work-main" main
main=$tmp/work-main

echo "commits"
expect block "$main" "git commit -m x" "commit on main"
expect allow "$work" "git commit -m x" "commit on a feature branch"
expect block "$main" "git add . && git commit -m 'Fix it'" "chained commit on main"
expect block "$tmp" "cd $main && git commit -m x" "cd into main, then commit"
expect block "$tmp" "git -C $main commit -m x" "git -C main commit"
expect allow "$tmp" "cd $work && git commit -m x" "cd into a feature branch, then commit"
expect allow "$main" "git status" "other git commands on main"
expect allow "$main" "echo 'git commit'" "git commit inside quoted text"
expect allow "$work" "$(printf 'git commit -m "$(cat <<%sEOF%s\nSubject\n\ngit push origin main\nEOF\n)"' "'" "'")" \
  "heredoc body mentioning git push"

echo "pushes"
expect block "$work" "git push origin main" "explicit main"
expect block "$work" "git push origin HEAD:main" "HEAD:main"
expect block "$work" "git push origin HEAD:refs/heads/main" "HEAD:refs/heads/main"
expect block "$work" "git push --force origin +main" "+main"
expect block "$work" "git push origin --delete main" "delete main"
expect block "$work" "git push --all origin" "--all"
expect block "$main" "git push" "plain push from main"
expect block "$main" "git push -u origin HEAD" "HEAD from main"
expect allow "$work" "git push" "plain push from a feature branch"
expect allow "$work" "git push -u origin HEAD" "HEAD from a feature branch"
expect allow "$work" "git push origin feature" "explicit feature branch"
expect allow "$work" "git push --dry-run origin main" "dry run"
expect allow "$work" "git push --tags" "tags only"
expect allow "$work" "git push -o ci.skip origin feature" "push option value isn't a refspec"

echo "pushes with push.default tracking"
git -C "$work" config push.default tracking
git -C "$work" switch -q tracks-main
expect block "$work" "git push" "plain push tracking main"
expect block "$work" "git push origin tracks-main" "named branch tracking main"
git -C "$work" switch -q feature
expect allow "$work" "git push origin feature" "untracked feature branch"
git -C "$work" config --unset push.default

echo "repos without a pull request to open"
git init -q -b main "$tmp/local"
expect allow "$tmp/local" "git commit -m x" "no remote"
git init -q --bare -b main "$tmp/empty.git"
git init -q -b main "$tmp/new"
git -C "$tmp/new" remote add origin "$tmp/empty.git"
expect allow "$tmp/new" "git commit -m x" "remote with no branches yet"
expect allow "$tmp/new" "git push -u origin main" "first push to an empty remote"
expect allow "$tmp" "git commit -m x" "not a repo"
expect allow "$main" "ls -la" "not git"

echo "$passed passed, $failed failed"
[ "$failed" = 0 ]
