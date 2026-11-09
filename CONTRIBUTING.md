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
3. Write a **Conventional Commit** message (see below). It becomes the
   changelog line, so write it for users. Don't edit `CHANGELOG.md` by hand.
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

**Stable releases come from commit messages** ([release-please](https://github.com/googleapis/release-please)).
Every merge to `main` updates one open **"chore: release X.Y.Z"** PR with the next
version and the `CHANGELOG.md` entry written from the commits since the last
release. Merging that PR tags `vX.Y.Z`, publishes the GitHub Release and moves the
major tag (`v0`/`v1`), so users pinning `clymist/deploy-action@v0` get it. There is
nothing else to run.

The version comes from the commit types (`feat:` → minor, `fix:`/`perf:` → patch,
`!`/`BREAKING CHANGE` → major; while in `0.x`, breaking maps to minor). `docs:`
lines are listed; `ci:`, `chore:`, `test:`, `build:` and `style:` commits ship
with the next release without a line of their own.

**Editing what the changelog says:**

- **Before merging a change**, fix the commit message (or the PR title, if you
  squash-merge: it becomes the commit message).
- **After merging**, add this to the description of the merged PR; release-please
  uses it instead of that PR's commit messages on its next run:

  ```
  BEGIN_COMMIT_OVERRIDE
  fix: retry a failed status poll instead of failing the step
  END_COMMIT_OVERRIDE
  ```
- **At release time**, edit `CHANGELOG.md` in the release PR before merging it.
  (Another merge to `main` regenerates the PR, so make that edit last.)

### Commit messages

`<type>[(scope)][!]: <description>`, for example `feat: add url output` or
`fix(summary): escape pipes in the error row`. Types: `feat`, `fix`, `perf`,
`refactor`, `docs`, `test`, `ci`, `build`, `chore`, `style`, `revert`. The
**Commits** check fails a PR whose commits or title don't follow this; reword
with `git rebase -i` and force-push. To catch it before pushing, enable the hook
once per clone: `git config core.hooksPath .githooks`.

- **Breaking changes** (removing/renaming an input, changing a default) → use
  `!` or a `BREAKING CHANGE:` footer, and note it in the PR's "Version impact".

## Reporting security issues

Do not open a public issue. Use
[private security advisories](https://github.com/clymist/deploy-action/security/advisories/new).
See [SECURITY.md](./SECURITY.md).
