#!/usr/bin/env bash
# Check that commit subjects (or a PR title) follow Conventional Commits, which
# release-please reads to pick the next version and write the changelog:
#
#   <type>[(scope)][!]: <description>
#   types: feat fix perf refactor docs test ci build chore style revert
#
#   feat → minor · fix/perf → patch · ! or a "BREAKING CHANGE:" footer → major
#   (minor while still 0.x). The others are released with the next feat/fix.
#
# Usage:
#   scripts/check-commits.sh <base> <head>   every non-merge commit in base..head
#   scripts/check-commits.sh --message <text>  one message (a PR title, a hook)
#   scripts/check-commits.sh --file <path>     one message file (commit-msg hook)
set -euo pipefail

TYPES='feat|fix|perf|refactor|docs|test|ci|build|chore|style|revert'
PATTERN="^(${TYPES})(\([A-Za-z0-9][A-Za-z0-9._/-]*\))?!?: [^ ].*"

check() {
  local subject="$1" where="$2"
  # Merge and revert subjects are written by git itself.
  case "$subject" in "Merge "* | "Revert \""*) return 0 ;; esac
  if [[ "$subject" =~ $PATTERN ]] && [ "${#subject}" -le 100 ]; then
    return 0
  fi
  echo "✗ ${where}: \"${subject}\"" >&2
  if [ "${#subject}" -gt 100 ]; then
    echo "  The subject is ${#subject} characters; keep it to 100." >&2
  else
    echo "  Expected \"<type>(<scope>): <description>\", e.g. \"fix: retry a failed status poll\"." >&2
    echo "  Types: ${TYPES//|/, }. Add ! before the colon for a breaking change." >&2
  fi
  return 1
}

case "${1:-}" in
  --message)
    check "$(printf '%s' "${2:-}" | head -n1)" "message"
    ;;
  --file)
    # A commit-msg hook: first non-comment line of the message file.
    check "$(grep -v '^#' "$2" | sed '/^[[:space:]]*$/d' | head -n1)" "commit message"
    ;;
  *)
    BASE="${1:?usage: check-commits.sh <base> <head> | --message <text> | --file <path>}"
    HEAD="${2:?missing <head>}"
    FAILED=0
    while IFS=$'\t' read -r sha subject; do
      [ -n "$sha" ] || continue
      check "$subject" "commit ${sha:0:7}" || FAILED=1
    done < <(git log --no-merges --format='%H%x09%s' "${BASE}..${HEAD}")
    if [ "$FAILED" -ne 0 ]; then
      echo "" >&2
      echo "Reword them with \`git rebase -i ${BASE:0:7}\` (mark each as reword), then force-push." >&2
      exit 1
    fi
    echo "All commits follow Conventional Commits."
    ;;
esac
