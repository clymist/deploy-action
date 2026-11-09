# Changelog

All notable changes to this action are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Changed

- The job summary is a deployment report: the outcome in the title, app,
  environment, a link to the commit, duration, URL and a link to Clymist, a
  table of how long each phase took, and a callout with the reason when a
  deploy fails or is skipped.
- Prereleases are no longer published on every merge to `main`; run the
  Prerelease workflow to make one. The old `-rc` tags were removed so the tags
  list shows real releases.

## [0.6.0]

The run says where the app is live and why a deploy failed, and it copes with
apps that have no URL and with odd responses from Clymist.

### Added

- Outputs `url`, `deployment-url` and `environment`: where the app is live
  (its custom domain if it has one, else its Clymist URL) and its deployments
  in the Clymist dashboard. Use `url` as a GitHub environment url for a
  **View deployment** button.
- A job summary card with status, duration, environment, commit, URL and a
  link to the deployment in Clymist.

### Changed

- Clearer logs: each phase shows its elapsed time and how long the previous
  one took, and success ends with `✅ Live in 42s → <url>`.
- A failed deploy's error annotation carries Clymist's one-line reason and a
  link to the full logs, instead of only the status.
- A failed status poll (network blip, API restart) is retried instead of
  failing the step; it gives up after six in a row.
- Apps without a public URL (workers, internal services) end with
  `✅ Deployed in 42s (no public URL)`; the `url` output is empty.
- Responses from Clymist are treated as untrusted: URLs are used only if
  well-formed, text is kept to one line and capped (no workflow-command
  injection), a non-JSON or unreachable API gives a clear error, and outputs
  use the multi-line delimiter form so an odd body can't corrupt them.
- The "logs" link on a failed deploy opens the app's Deployments tab in
  Clymist (from the API's `deploymentUrl` when it sends one). The previous
  per-deployment path doesn't exist in the dashboard.

## [0.5.0]

Builds can take per-run arguments from the workflow, and tagged releases can
deploy straight to environments that track tags.

### Added

- `build-args` input: per-build image build arguments, one `NAME=VALUE` per
  line (only the first `=` splits, so values may contain commas, colons or `=`).
  They override the app's stored build args for that build only. Secret-looking
  names are refused, since build args are baked into the image and build logs.

### Changed

- Releases are cut from **Actions → Release → Run workflow**, which computes the
  version from Conventional Commits, refuses to reuse a tag or to ship a version
  `CHANGELOG.md` does not document, and supports a `dry-run`. Version logic now
  lives in `scripts/next-version.sh`, shared with the prerelease workflow.
- Deploying from a tag workflow builds the tagged commit (Clymist used to try to
  clone `refs/tags/<tag>` as a branch and fail). An environment with a tag
  pattern (e.g. `v*`) only accepts a matching tag: a branch workflow or another
  tag is refused.

## [0.4.0]

Deploys that never happened used to pass green. They now fail, and every reason
says what to change and where.

### Added

- `fail-on-skip` input (default `true`): fail the step when Clymist deploys
  nothing. Set it to `false` to keep the previous warn-and-pass behavior.
- Deployment failures print the reason from the API plus a direct link to the
  deployment's logs in the Clymist dashboard.

### Changed

- **BREAKING**: when Clymist deploys nothing — the app is in `push` mode,
  auto-deploy is off, or the target environment is disabled — the step now
  **fails** instead of exiting 0 with a warning. A workflow that relied on the
  green exit must set `fail-on-skip: false`.
- Skip reasons are now actionable sentences naming the app and the setting to
  change, replacing raw field dumps like `ciMode=push`.
- Deploying a branch the target environment does not track is now rejected by
  the API, instead of silently shipping the wrong commit to that environment.
  Tag and manual refs are unaffected.
- The step is labelled "Deploy to Clymist" in the Actions UI — it previously
  showed as `Run set -euo pipefail`.
- The log no longer prints `✅ triggered` when nothing was deployed.

### Fixed

- README documents the `environment` input (shipped in 0.3.0 but undocumented).

## [0.3.0]

First STABLE release, so the sliding `@v0` tag moves here — `@v0` previously
still resolved to 0.1.0 (inputs `app`, `api-url`, `audience`, `sha`, `ref`),
which is why `app-id` was reported as an invalid input.

### Added

- `environment` input: deploy a specific environment by slug (e.g. `staging`).
  Omit it to deploy the app's primary environment.
- `wait` / `timeout` inputs: wait for the deployment to finish and fail the step
  if it fails (default on).
- Outputs `deployment-id` and `status`; grouped, readable step logs.

### Changed

- **BREAKING**: `app` (name/subdomain, optional) is replaced by `app-id` (the
  app's UUID, required). App names are not unique across organizations, so a
  name could never identify a deploy target unambiguously.
- Requests send an identifiable User-Agent.

## [0.1.0]

### Added

- Initial release: composite action that triggers a Clymist deployment from
  GitHub Actions using OIDC (no stored secrets).
- Inputs: `app`, `api-url`, `audience`, `sha`, `ref`.
- Output: `response` (raw JSON from the deploy endpoint).
- CI: actionlint + shellcheck + a mock-endpoint smoke test.
- Release workflow: GitHub Release on `vX.Y.Z` tags + sliding major tag.

> Pre-1.0: `@v0` tracks the latest stable 0.x release. Pin an exact version
> (`clymist/deploy-action@v0.4.0`) if you need the behavior frozen; `@v1` becomes
> the recommended pin once 1.0.0 ships.

[Unreleased]: https://github.com/clymist/deploy-action/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/clymist/deploy-action/releases/tag/v0.4.0
[0.3.0]: https://github.com/clymist/deploy-action/releases/tag/v0.3.0
[0.1.0]: https://github.com/clymist/deploy-action/releases/tag/v0.1.0
