# rpi4 Argo CD Bootstrap Notes

This folder bootstraps remote-cluster access for the Argo CD instance running on `dell7040`.

## Current workflow

1. Apply `argocd-service-account.yaml` to the `rpi4` cluster.
2. Build a local plain cluster secret manifest (not committed).
3. Seal the secret with Sealed Secrets.
4. Commit only `argocd/overlays/dell7040/rpi4-cluster-sealedsecret.yaml`.

## Important guardrails

- Do not commit plaintext cluster secrets.
- `rpi4-cluster-secret.yaml` is intentionally gitignored and should remain local-only.
- The Argo CD overlay at `argocd/overlays/dell7040/kustomization.yaml` must reference only the sealed secret.

## Follow-up hardening

After initial app onboarding is stable:

1. Rotate the rpi4 Argo manager token.
2. Replace wildcard `*` RBAC with least-privilege permissions per API group/resource used.
3. Re-seal and commit the updated cluster secret.
