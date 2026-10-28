#!/usr/bin/env bash
# PreToolUse hook for Bash: blocks a git commit on the repo's default branch
# and a git push that would update it, so every change goes through a pull
# request. Reads the hook event as JSON on stdin; exit 2 blocks the command.
#
# Parsing the command is best-effort: it follows `cd`, `git -C`, chained
# commands, and push refspecs, and ignores heredoc bodies and quoted text.

if ! command -v jq > /dev/null 2>&1; then
  echo "jig: install jq to turn on the guard against committing to the default branch" >&2
  exit 1
fi

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
dir=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$command" ] || exit 0
[ -n "$dir" ] || dir=$PWD

block() { # action branch
  echo "jig: blocked, this would $1 the default branch ($2). Changes go through a pull request: put the work on its own branch (see the jig:start-work skill) and push that branch. If the user wants this anyway, they can run the command themselves." >&2
  exit 2
}

in_repo() { # dir
  git -C "$1" rev-parse --is-inside-work-tree > /dev/null 2>&1
}

current_branch() { # dir
  git -C "$1" symbolic-ref --quiet --short HEAD 2> /dev/null
}

# origin, or the only remote when there's no origin.
main_remote() { # dir
  if git -C "$1" config "remote.origin.url" > /dev/null; then
    echo origin
  else
    git -C "$1" remote | head -n 1
  fi
}

# The remote's default branch. Prints nothing when the remote has no branches
# yet (a brand-new repo), since there's no pull request to open then.
default_branch() { # dir remote
  local ref
  [ -n "$2" ] || return
  if ref=$(git -C "$1" symbolic-ref --quiet --short "refs/remotes/$2/HEAD" 2> /dev/null); then
    echo "${ref#"$2"/}"
    return
  fi
  for ref in main master; do
    if git -C "$1" show-ref --verify --quiet "refs/remotes/$2/$ref"; then
      echo "$ref"
      return
    fi
  done
}

# The branch on remote that branch tracks, if any.
upstream_of() { # dir branch remote
  local merge
  [ "$(git -C "$1" config "branch.$2.remote")" = "$3" ] || return
  merge=$(git -C "$1" config "branch.$2.merge") || return
  echo "${merge#refs/heads/}"
}

check_commit() { # dir
  local def
  in_repo "$1" || return
  def=$(default_branch "$1" "$(main_remote "$1")")
  [ -n "$def" ] || return
  [ "$(current_branch "$1")" = "$def" ] && block "commit on" "$def"
}

check_push() { # dir args...
  local dir=$1 remote="" repo_set=0 all=0 tags=0 skip_next=0 n=0
  local refspecs=() arg cur def def_remote mode dst src r up
  shift
  in_repo "$dir" || return
  for arg in "$@"; do
    if [ "$skip_next" = 1 ]; then skip_next=0; continue; fi
    case $arg in
      -n | --dry-run) return ;;
      --all | --branches | --mirror) all=1 ;;
      --tags) tags=1 ;;
      -o | --push-option | --receive-pack | --exec) skip_next=1 ;;
      --repo) skip_next=1 ;;
      --repo=*) remote=${arg#--repo=}; repo_set=1 ;;
      -*) ;;
      *)
        if [ -z "$remote" ] && [ "$repo_set" = 0 ]; then
          remote=$arg
        else
          refspecs[n]=$arg
          n=$((n + 1))
        fi
        ;;
    esac
  done

  cur=$(current_branch "$dir")
  if [ -z "$remote" ]; then
    remote=$(git -C "$dir" config "branch.$cur.pushRemote" ||
      git -C "$dir" config remote.pushDefault ||
      git -C "$dir" config "branch.$cur.remote" ||
      main_remote "$dir")
  fi
  # A URL instead of a remote name: judge it by the main remote.
  def_remote=$remote
  git -C "$dir" config "remote.$remote.url" > /dev/null || def_remote=$(main_remote "$dir")
  def=$(default_branch "$dir" "$def_remote")
  [ -n "$def" ] || return

  [ "$all" = 1 ] && block "push to" "$def"
  mode=$(git -C "$dir" config push.default || echo simple)

  if [ "$n" = 0 ]; then
    [ "$tags" = 1 ] && return
    case $mode in
      nothing) return ;;
      matching)
        git -C "$dir" show-ref --verify --quiet "refs/heads/$def" && block "push to" "$def"
        return
        ;;
      upstream | tracking) dst=$(upstream_of "$dir" "$cur" "$remote") ;;
      *) dst=$cur ;;
    esac
    [ -n "$dst" ] && [ "$dst" = "$def" ] && block "push to" "$def"
    return
  fi

  for r in "${refspecs[@]}"; do
    r=${r#+}
    case $r in
      *:*) dst=${r#*:} ;;
      *)
        src=$r
        [ "$src" = HEAD ] && src=$cur
        dst=$src
        # With these modes, a bare branch name pushes to the branch it tracks.
        case $mode in
          upstream | tracking)
            up=$(upstream_of "$dir" "${src#refs/heads/}" "$remote")
            [ -n "$up" ] && dst=$up
            ;;
        esac
        ;;
    esac
    dst=${dst#refs/heads/}
    [ "$dst" = "$def" ] && block "push to" "$def"
  done
}

# One line per simple command: drop heredoc bodies, unquote single words,
# blank out quoted text, then split on ; & | && || ( and ).
segments=$(printf '%s\n' "$command" |
  awk '
    skip != "" { t = $0; gsub(/^[ \t]+|[ \t]+$/, "", t); if (t == skip) skip = ""; next }
    {
      print
      if (match($0, /(^|[^<])<<-?[ \t]*["\047]?[A-Za-z_][A-Za-z0-9_]*/)) {
        d = substr($0, RSTART, RLENGTH)
        sub(/^[^<]?<<-?[ \t]*["\047]?/, "", d)
        skip = d
      }
    }' |
  sed -E -e "s/\"([^\" ]*)\"/\\1/g" -e "s/'([^' ]*)'/\\1/g" \
    -e 's/"[^"]*"/Q/g' -e "s/'[^']*'/Q/g" |
  awk '{ gsub(/&&|\|\||[;&|()]/, "\n"); print }')

while IFS= read -r segment; do
  read -ra words <<< "$segment"
  [ "${#words[@]}" -gt 0 ] || continue
  i=0
  while [ "$i" -lt "${#words[@]}" ]; do
    case ${words[i]} in
      then | do | else | if | while | until | '!' | time | command | exec | nohup) ;;
      [A-Za-z_]*=*) ;;
      *) break ;;
    esac
    i=$((i + 1))
  done
  word=${words[i]}

  if [ "$word" = cd ]; then
    target=${words[i + 1]:-$HOME}
    target=${target/#\~/$HOME}
    newdir=$(cd "$dir" 2> /dev/null && cd "$target" 2> /dev/null && pwd) && dir=$newdir
    continue
  fi

  case $word in git | */git) ;; *) continue ;; esac
  gitdir=$dir
  j=$((i + 1))
  while [ "$j" -lt "${#words[@]}" ]; do
    case ${words[j]} in
      -C)
        target=${words[j + 1]/#\~/$HOME}
        gitdir=$(cd "$gitdir" 2> /dev/null && cd "$target" 2> /dev/null && pwd) || gitdir=$target
        j=$((j + 2))
        ;;
      -c) j=$((j + 2)) ;;
      -*) j=$((j + 1)) ;;
      *) break ;;
    esac
  done
  case ${words[j]} in
    commit) check_commit "$gitdir" ;;
    push) check_push "$gitdir" "${words[@]:j+1}" ;;
  esac
done <<< "$segments"

exit 0
