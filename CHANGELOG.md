# Changelog

All notable changes to this action are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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
> (`clymist/deploy-action@v0.3.0`) if you need the inputs frozen; `@v1` becomes
> the recommended pin once 1.0.0 ships.

[Unreleased]: https://github.com/clymist/deploy-action/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/clymist/deploy-action/releases/tag/v0.3.0
[0.1.0]: https://github.com/clymist/deploy-action/releases/tag/v0.1.0
