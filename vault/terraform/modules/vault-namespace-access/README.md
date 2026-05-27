# Vault Namespace Access Module

This Terraform module creates a Vault policy and Kubernetes authentication role for a specific namespace, allowing Kubernetes workloads to authenticate with Vault and access secrets.

## Features

- Creates a custom Vault policy with configurable HCL
- Sets up a Kubernetes auth backend role
- Binds service accounts and namespaces to the role
- Configurable token TTL

## Usage

```hcl
module "namespace_access" {
  source = "./modules/vault-namespace-access"

  policy_name              = "my-app-policy"
  policy_hcl               = <<EOT
path "secret/data/my-app/*" {
  capabilities = ["read", "list"]
}
EOT
  role_name                = "my-app-role"
  kubernetes_auth_backend  = "kubernetes"
  service_accounts         = ["default", "my-app"]
  namespaces               = ["my-namespace"]
  token_ttl                = 3600
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| policy_name | Name of the Vault policy to create | `string` | n/a | yes |
| policy_hcl | HCL policy document for Vault | `string` | n/a | yes |
| role_name | Name of the Kubernetes auth role to create | `string` | n/a | yes |
| kubernetes_auth_backend | Path to the Kubernetes auth backend in Vault | `string` | `"kubernetes"` | no |
| service_accounts | List of Kubernetes service account names that can authenticate | `list(string)` | n/a | yes |
| namespaces | List of Kubernetes namespaces where the service accounts exist | `list(string)` | n/a | yes |
| token_ttl | TTL for tokens issued by this role (in seconds) | `number` | `3600` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy_name | Name of the created Vault policy |
| policy_id | ID of the created Vault policy |
| role_name | Name of the created Kubernetes auth role |
| role_id | ID of the created Kubernetes auth role |

## Requirements

- Terraform >= 1.0
- Vault provider ~> 4.0
- Vault server with Kubernetes auth backend enabled