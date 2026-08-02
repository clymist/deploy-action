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

We follow SemVer with a **sliding major tag**:

- Cut a release by pushing a tag `vX.Y.Z`.
- The release workflow creates the GitHub Release **and** force-moves the major
  tag (`vX`) to it, so users pinning `clymist/deploy-action@v1` get patches.
- **Breaking changes** (removing/renaming an input, changing a default) require
  a **major** bump and a note in the PR's "Version impact".

## Reporting security issues

Do not open a public issue. Use
[private security advisories](https://github.com/clymist/deploy-action/security/advisories/new).
See [SECURITY.md](./SECURITY.md).
