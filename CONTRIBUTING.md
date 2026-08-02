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

**Prereleases are automatic.** Every merge to `main` runs `prerelease.yml`,
which computes the next version from the commits since the last stable tag
(`feat:` → minor, `fix:`/`perf:` → patch, `!`/`BREAKING CHANGE` → major; while
in `0.x`, breaking maps to minor) and publishes `v<next>-rc.<N>`. Prereleases are
marked "Pre-release" on GitHub and **never** move the `vX` major tag. So `main`
always has an installable rc for testing: `clymist/deploy-action@v0.2.0-rc.3`.

**Stable releases are deliberate.** Cut one via **Actions → Release → Run
workflow**, entering the version (e.g. `0.2.0`). That workflow creates the tag,
the GitHub Release, and force-moves the major tag (`v0`/`v1`), so users pinning
`clymist/deploy-action@v1` get it. (Pushing a `vX.Y.Z` tag directly also works.)

- Write **Conventional Commit** subjects (`feat:`, `fix:`, `feat!:`, …) — the
  prerelease version is derived from them.
- **Breaking changes** (removing/renaming an input, changing a default) → use
  `!` or a `BREAKING CHANGE:` footer, and note it in the PR's "Version impact".

## Reporting security issues

Do not open a public issue. Use
[private security advisories](https://github.com/clymist/deploy-action/security/advisories/new).
See [SECURITY.md](./SECURITY.md).
