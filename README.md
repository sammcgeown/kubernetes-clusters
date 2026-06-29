# kubernetes-clusters

GitOps repository for managing multiple Kubernetes clusters with ArgoCD.

## Repository Structure

```
kubernetes-clusters/
├── apps/                        # ArgoCD Application manifests, organised by cluster
│   ├── dell7040/
│   │   └── argo-cd-app.yaml     # ArgoCD self-management for dell7040
│   └── rpi4/
│       └── (coming soon)
└── argocd/                      # ArgoCD installation config (Kustomize + Helm)
    ├── base/                    # Shared config applied to all clusters
    │   ├── kustomization.yaml   # argo-cd Helm chart (v9.5.3)
    │   └── values.yaml          # Shared Helm values
    └── overlays/                # Cluster-specific config
        ├── dell7040/
        │   ├── kustomization.yaml
        │   ├── argocd-ingress.yaml
        │   └── argocd-server-tls.yaml
        └── rpi4/
            └── kustomization.yaml
```

## Clusters

### dell7040

| Property | Value |
|---|---|
| ArgoCD URL | https://argocd.lab.definit.co.uk |
| Ingress class | cilium (TLS passthrough) |
| TLS | cert-manager, Let's Encrypt production |

### rpi4

Configuration in progress.

## How It Works

ArgoCD manages its own installation from this repository (the "App of Apps" pattern).

- `argocd/base/` contains the Helm chart reference and shared values, including enabling Helm support in Kustomize (`--enable-helm`).
- `argocd/overlays/<cluster>/` extends the base with cluster-specific resources: ingress hostname, TLS certificate.
- `apps/<cluster>/argo-cd-app.yaml` is the ArgoCD `Application` manifest that points ArgoCD at its own overlay, completing the self-management loop.

## Bootstrap

ArgoCD is not yet running on a new cluster. To bootstrap:

1. Install ArgoCD into the cluster (one-time, manual):

   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. Apply the self-management Application for the target cluster:

   ```bash
   kubectl apply -f apps/<cluster>/argo-cd-app.yaml
   ```

   ArgoCD will then sync itself from Git and take over its own management.

## Adding a New Application

1. Create the application manifests under a new directory (e.g. `my-app/overlays/<cluster>/`).
2. Add an ArgoCD `Application` manifest to `apps/<cluster>/my-app.yaml` pointing at that path.
3. Commit and push — ArgoCD will pick it up automatically.

## Vault Secret Structure Plan

This repository now treats Vault as the source of truth for runtime secrets, with Kubernetes secrets used only where an application or chart strictly requires them.

### Goal

- Keep secret layout predictable across apps and clusters.
- Make Vault policies easy to scope to least privilege.
- Avoid storing plaintext secrets in Git; only sealed/encrypted Kubernetes objects belong in this repo.

### Planned KVv2 Layout

Use the `kv` mount and organise secrets by cluster, application, and purpose:

```text
kv/
   clusters/
      dell7040/
         <app>/
            config
            credentials
            api-keys
      rpi4/
         <app>/
            config
            credentials
```

Examples:

- `kv/clusters/dell7040/hashicorp-mcp/credentials`
- `kv/clusters/dell7040/authentik/credentials`
- `kv/clusters/dell7040/external-dns/api-keys`

### Policy Pattern

Each workload policy should map to the smallest possible path prefix.

Example policy scope for one app on one cluster:

```hcl
path "kv/data/clusters/dell7040/hashicorp-mcp/*" {
   capabilities = ["read", "list"]
}
```

This keeps cross-app and cross-cluster access separated by default.

### How This Fits The Current Repo

- `vault/` deploys Vault and the injector/operator components.
- `apps/<cluster>/vault-app.yaml` installs Vault per cluster through ArgoCD.
- App overlays remain responsible for non-secret config and secret references.
- Where Kubernetes `Secret` objects are still required by a chart, store them as SealedSecrets and source the actual values from Vault during secret creation/rotation workflows.

### Rollout Approach

1. Keep existing working secret references in place.
2. Move app values into the planned Vault paths (`kv/clusters/<cluster>/<app>/...`).
3. Tighten policies so each service account can only read its own path.
4. Standardise rotation runbooks around the same path convention.

The immediate result is that everything can stay working as-is while new secrets and rotations follow one consistent Vault structure.
