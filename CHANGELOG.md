# Changelog

All notable changes to this action are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/), and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0]

### Added

- Initial release: composite action that triggers a Clymist deployment from
  GitHub Actions using OIDC (no stored secrets).
- Inputs: `app`, `api-url`, `audience`, `sha`, `ref`.
- Output: `response` (raw JSON from the deploy endpoint).
- CI: actionlint + shellcheck + a mock-endpoint smoke test.
- Release workflow: GitHub Release on `vX.Y.Z` tags + sliding major tag.

> Pre-1.0: pin an exact version (`clymist/deploy-action@v0.1.0`). The sliding
> major tag (`@v1`) becomes the recommended pin once 1.0.0 ships.

[Unreleased]: https://github.com/clymist/deploy-action/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/clymist/deploy-action/releases/tag/v0.1.0
