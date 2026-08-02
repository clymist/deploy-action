# Security Policy

## Reporting a vulnerability

Please report security issues **privately** via
[GitHub Security Advisories](https://github.com/clymist/deploy-action/security/advisories/new),
not as public issues or PRs. We aim to acknowledge within 3 business days.

## Security model

This action authenticates to Clymist using a **GitHub Actions OIDC token** — it
stores **no long-lived secrets**. When you use it:

- The job must declare `permissions: id-token: write`.
- The action requests a short-lived OIDC token for the configured `audience`
  and sends it to the Clymist `/deploy` endpoint over HTTPS.
- Clymist verifies the token's signature (GitHub JWKS), issuer, audience, and
  expiry, then authorizes using the token's `repository` claim — a workflow can
  only deploy the app that belongs to **its own repository**.

### Guidance for users

- Pin the action to a **major tag** (`@v1`) or a full **commit SHA** for
  strongest supply-chain guarantees.
- Never echo the OIDC token or paste it into issues — it is a bearer credential
  (though short-lived and audience-scoped).
- Keep `permissions:` least-privilege: this action needs only
  `id-token: write` and `contents: read`.
