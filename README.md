# Clymist Deploy Action

Trigger a [Clymist](https://clymist.com) deployment from a GitHub Actions workflow —
authenticated with **GitHub OIDC**, so there are **no secrets to store**. Clymist
verifies the workflow's short-lived OIDC token and only lets it deploy the app
that belongs to the **same repository**.

> This is a self-contained composite action. It's developed in the Clymist
> monorepo under `packages/deploy-action` and published to its own repository
> (`clymist/deploy-action`) so users can reference it as `clymist/deploy-action@v1`.

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

| Input      | Required | Default                             | Description |
|------------|----------|-------------------------------------|-------------|
| `app-id`   | **yes**  | —                                   | The Clymist app UUID to deploy (from the app's Build settings). Clymist only deploys it if this repository is the one connected to that app. |
| `api-url`  | no       | `https://api.clymist.com/api/v1`    | Clymist API base URL (include the `/api/v1` prefix). |
| `audience` | no       | API origin (scheme+host of `api-url`) | OIDC audience. Only override if your Clymist sets a custom `OIDC_AUDIENCE`. |
| `sha`      | no       | `github.sha`                        | Commit SHA to deploy. |
| `ref`      | no       | `github.ref`                        | Git ref being deployed. |
| `wait`     | no       | `true`                              | Wait for the deployment to finish and **fail the step if it fails**. Set `false` to trigger-and-return. |
| `timeout`  | no       | `900`                               | Max seconds to wait (when `wait: true`). |

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
