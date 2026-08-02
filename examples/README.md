# Examples

## `deploy.yml`

Copy this into your own repository at `.github/workflows/deploy.yml`. It builds/
tests, then deploys to Clymist via OIDC. It lives here under `examples/` on
purpose so GitHub does **not** run it as a workflow in this repo.

## `app/`

A minimal Node HTTP app (used as the thing a Clymist app would build & deploy).
Nixpacks detects Node and runs `npm start`.

## Trying it for real

1. In Clymist, connect an app to a GitHub repo and set **Build settings →
   Auto-deploy → From CI (ci-action)**.
2. Add the workflow above to that repo (or run the repo's
   **Actions → E2E (manual)** here, pointing `app` at your Clymist app).
3. On push (or manual run), the action mints an OIDC token and calls
   `POST /deploy`; Clymist verifies the token's `repository` claim matches the
   app's repo and deploys the pushed commit.

Before the Clymist backend exposes `/deploy` and an app is wired, the call
returns 401/403 — which still confirms the action's OIDC + request path works.
