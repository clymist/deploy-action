#!/usr/bin/env bash
# Compute the next version from Conventional Commits since the last STABLE tag.
#
#   feat:            → minor bump
#   fix: / perf:     → patch bump
#   feat!/BREAKING   → major bump (only moves the minor while still 0.x)
#
# Both prerelease.yml and release.yml source this, so an rc and the stable
# release it becomes always agree on the number.
#
# Usage:  scripts/next-version.sh [--rc]
#   (no args)  → prints the stable target, e.g. "0.5.0"
#   --rc       → prints the next prerelease tag, e.g. "v0.5.0-rc.3"
#
# Requires a full-depth checkout (fetch-depth: 0) so tags and history are present.
set -euo pipefail

MODE="${1:-stable}"

# Latest stable tag (no hyphen ⇒ excludes -rc.N). Default v0.0.0 if none yet.
LAST_STABLE="$(git tag --list 'v[0-9]*.[0-9]*.[0-9]*' | grep -vE '-' | sort -V | tail -n1 || true)"
LAST_STABLE="${LAST_STABLE:-v0.0.0}"
BASE="${LAST_STABLE#v}"
MAJOR="${BASE%%.*}"; REST="${BASE#*.}"; MINOR="${REST%%.*}"; PATCH="${REST#*.}"

# Commits since that tag decide the bump; scan all history if there is no tag.
if git rev-parse -q --verify "$LAST_STABLE" >/dev/null; then
  LOG="$(git log --format='%B' "${LAST_STABLE}..HEAD")"
else
  LOG="$(git log --format='%B')"
fi

BUMP="none"
if printf '%s' "$LOG" | grep -qE '(^|\n)(BREAKING CHANGE|.*!:)'; then
  BUMP="major"
elif printf '%s' "$LOG" | grep -qE '(^|\n)feat(\(.+\))?:'; then
  BUMP="minor"
elif printf '%s' "$LOG" | grep -qE '(^|\n)(fix|perf)(\(.+\))?:'; then
  BUMP="patch"
fi
# Nothing releasable since the last stable → still cut a patch.
[ "$BUMP" = "none" ] && BUMP="patch"

# Pre-1.0, a breaking change moves the minor, not the major.
if [ "$MAJOR" -eq 0 ] && [ "$BUMP" = "major" ]; then BUMP="minor"; fi

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac
TARGET="${MAJOR}.${MINOR}.${PATCH}"

if [ "$MODE" = "--rc" ]; then
  # rc counter: highest existing -rc.N for this target, + 1.
  LAST_RC="$(git tag --list "v${TARGET}-rc.*" | sed -E "s/^v${TARGET}-rc\.//" | sort -n | tail -n1 || true)"
  printf 'v%s-rc.%s\n' "$TARGET" "$(( ${LAST_RC:-0} + 1 ))"
else
  printf '%s\n' "$TARGET"
fi

# Diagnostics go to stderr so `$(...)` capture stays clean.
echo "bump=$BUMP since $LAST_STABLE → $TARGET" >&2
