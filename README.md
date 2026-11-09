# Clymist Deploy Action

Trigger a [Clymist](https://clymist.com) deployment from a GitHub Actions workflow —
authenticated with **GitHub OIDC**, so there are **no secrets to store**. Clymist
verifies the workflow's short-lived OIDC token and only lets it deploy the app
that belongs to the **same repository**.

> This is a self-contained composite action. It's developed in the Clymist
> monorepo under `packages/deploy-action` and published to its own repository
> (`clymist/deploy-action`) so users can reference it as `clymist/deploy-action@v0`
> (the sliding tag for the latest stable 0.x; `@v1` once 1.0.0 ships).

## Usage

```yaml
name: Deploy to Clymist
on:
  push:
    branches: [main]

permissions:
  id-token: write   # REQUIRED — lets the job mint an OIDC token
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # --- your build / test steps here ---
      # - run: npm ci && npm test

      - name: Deploy to Clymist
        if: success()                 # gate the deploy on your own condition
        uses: clymist/deploy-action@v0
        with:
          app-id: ${{ vars.CLYMIST_APP_ID }}   # your Clymist app UUID (Build settings)
```

The deploy step only runs when the steps before it succeed (`if: success()`).
Use any condition you like — `if: needs.test.result == 'success'`,
`if: github.ref == 'refs/heads/main'`, etc. **That `if:` is where you decide
whether the deployment should proceed.**

## Inputs

| Input          | Required | Default                             | Description |
|----------------|----------|-------------------------------------|-------------|
| `app-id`       | **yes**  | —                                   | The Clymist app UUID to deploy (from the app's Build settings). Clymist only deploys it if this repository is the one connected to that app. |
| `environment`  | no       | the app's primary environment       | Environment slug to deploy, e.g. `staging` or `production`. |
| `api-url`      | no       | `https://api.clymist.com/api/v1`    | Clymist API base URL (include the `/api/v1` prefix). |
| `audience`     | no       | API origin (scheme+host of `api-url`) | OIDC audience. Only override if your Clymist sets a custom `OIDC_AUDIENCE`. |
| `sha`          | no       | `github.sha`                        | Commit SHA to deploy. |
| `ref`          | no       | `github.ref`                        | Git ref being deployed. |
| `wait`         | no       | `true`                              | Wait for the deployment to finish and **fail the step if it fails**. Set `false` to trigger-and-return. |
| `timeout`      | no       | `900`                               | Max seconds to wait (when `wait: true`). |
| `fail-on-skip` | no       | `true`                              | Fail the step when Clymist deploys nothing. Set `false` to warn and pass instead. |
| `build-args`   | no       | —                                   | Build arguments for this build only, one `NAME=VALUE` per line. Override the app's stored build args. Secret-looking names are refused — put secrets in the app's environment. |

The `app-id` is not a secret — it's fine to hard-code or store as a repo variable.
Authorization comes from the OIDC token: a workflow can only deploy an app whose
connected repository matches the workflow's own repository.

By default the action **waits for the build + rollout to finish** and turns the
step red if the deployment fails — so your CI reflects the real deploy outcome.

## Outputs

| Output          | Description |
|-----------------|-------------|
| `response`      | Raw JSON returned by the Clymist deploy endpoint. |
| `deployment-id` | The created deployment's id. |
| `status`        | Final status: `running` (success), `failed`/`cancelled`, `timeout`, `skipped`, or `triggered` (when `wait: false`). |
| `url`           | Where the app is live: its custom domain if it has one, else its Clymist URL (one, not both). |
| `deployment-url`| The app's deployments in the Clymist dashboard. |
| `environment`   | Name of the Clymist environment that was deployed. |

Requires a Clymist API that returns these fields; with an older one they are empty.
`url` is empty for apps without a public URL (Clymist **Worker** apps and
internal services); the run then ends with `✅ Deployed in 42s (no public URL)`.

### What you see in the run

The step log shows each phase with its time, then where the app is live:

```
🚀 Deploying Backend (production) · commit 64bc235
   → https://api.example.com
  • building   +0s
  • deploying  +16s   (building took 16s)
  • running    +42s   (deploying took 26s)
✅ Live in 42s → https://api.example.com
   Clymist: https://app.clymist.com/applications/<id>?tab=deployments
```

The run's summary page gets a card with the status, duration, environment,
commit, URL and a link to the deployment in Clymist. A failed deploy shows
Clymist's one-line reason (e.g. a failing pre-deploy command) in the error
annotation; the full logs stay in Clymist.

### Link the run to the deployed app

Pass `url` to a GitHub environment, and GitHub shows a **View deployment**
button on the run and on the pull request or commit:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: ${{ steps.clymist.outputs.url }}
    steps:
      - id: clymist
        uses: clymist/deploy-action@v0
        with:
          app-id: ${{ vars.CLYMIST_APP_ID }}
```

## When nothing gets deployed

Clymist can accept the request and still deploy nothing — most often because the
app is in **push** mode (so it deploys from Clymist's own push webhook and
ignores this action), because auto-deploy is off, or because the target
environment is disabled.

That is a **failure**, not a success: the step exits non-zero and prints the
reason Clymist returned, including where to change the setting. If a no-op
deploy is legitimately expected in your workflow, set `fail-on-skip: false` to
downgrade it to a warning.

Clymist also **refuses** to deploy a branch that the target environment does not
track — running this action on `main` against an environment that tracks
`develop` fails rather than shipping the wrong commit. Tag and manual refs are
exempt, so release workflows keep working — except for an environment set to
deploy on tags (e.g. `v*`): it accepts only a matching tag, and refuses branch
workflows and other tags.

## How it works

1. The job requests a GitHub OIDC token for the configured `audience`.
2. The action `POST`s that token to `POST <api-url>/deploy` with `{ app, sha, ref }`.
3. Clymist verifies the token's signature (GitHub JWKS), issuer, audience, and
   expiry, then checks the token's `repository` claim against the target app's
   repo — a workflow can only deploy **its own** repo's app.
4. Clymist builds the exact `sha` and rolls it out.

Set the app's **CI mode** to `ci-action` in Clymist (App → Build settings →
Auto-deploy) so it deploys from this action rather than on every push.

## Requirements

- `permissions: id-token: write` on the job (or workflow).
- Runner tools: `bash`, `curl`, `jq` (all preinstalled on GitHub-hosted runners).

## License

MIT
