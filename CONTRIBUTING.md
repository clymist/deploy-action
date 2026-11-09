# Contributing

Thanks for helping improve the Clymist Deploy Action!

## Local checks

This is a **composite action** — a single `action.yml` with an embedded bash
script. No build step. Before opening a PR:

```bash
# Lint the action + its embedded shell (same as CI)
docker run --rm -v "$PWD":/repo -w /repo rhysd/actionlint:latest -color

# Or install actionlint + shellcheck locally
brew install actionlint shellcheck
actionlint
```

## Making changes

1. Edit `action.yml`. Keep the embedded script POSIX-friendly bash and
   `shellcheck`-clean. Quote variables; prefer `set -euo pipefail`.
2. If you add/rename an **input** or **output**, update:
   - the `inputs:` / `outputs:` blocks in `action.yml`, and
   - the tables in `README.md` (CI does not enforce this — reviewers do).
3. Add a line to `CHANGELOG.md` under `Unreleased`.
4. The CI smoke test runs the action against a mock endpoint — make sure it
   still passes.

## Versioning & releases

We follow SemVer with a **sliding major tag**, and use
[Conventional Commits](https://www.conventionalcommits.org/) to drive versions.

**Prereleases are on demand.** To try a change before a stable release, run
**Actions → Prerelease → Run workflow**. It computes the next version from the
commits since the last stable tag (`feat:` → minor, `fix:`/`perf:` → patch,
`!`/`BREAKING CHANGE` → major; while in `0.x`, breaking maps to minor) and
publishes `v<next>-rc.<N>`, installable as e.g. `clymist/deploy-action@v0.7.0-rc.1`.
Prereleases are marked "Pre-release" on GitHub and **never** move the `vX` major
tag. Delete an rc's release and tag once its stable release is out, so the tags
list shows real releases.

**Stable releases are deliberate.** Cut one via **Actions → Release → Run
workflow**. Leave `version` blank and it computes the next number from the
commits since the last stable tag — the same rules, and the same shared script
(`scripts/next-version.sh`), that `prerelease.yml` uses, so an rc and the stable
release it becomes never disagree. Fill `version` in to override. The workflow
then creates the tag, publishes the GitHub Release, and force-moves the major
tag (`v0`/`v1`), so users pinning `clymist/deploy-action@v0` get it.
(Pushing a `vX.Y.Z` tag directly still works and publishes the same way.)

Two guards will stop a release rather than ship a half-prepared one:

- **The tag must be new** — it refuses to reuse an existing version.
- **`CHANGELOG.md` must have a `## [X.Y.Z]` section for the version.** The
  changelog is hand-written on purpose; a missing entry means the release
  wasn't prepared, so add the entry and run again.

Use **`dry-run: true`** to see the computed version and run both guards without
tagging or publishing anything.

- Write **Conventional Commit** subjects (`feat:`, `fix:`, `feat!:`, …) — the
  prerelease version is derived from them.
- **Breaking changes** (removing/renaming an input, changing a default) → use
  `!` or a `BREAKING CHANGE:` footer, and note it in the PR's "Version impact".

## Reporting security issues

Do not open a public issue. Use
[private security advisories](https://github.com/clymist/deploy-action/security/advisories/new).
See [SECURITY.md](./SECURITY.md).
