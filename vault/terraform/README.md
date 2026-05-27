# Vault Terraform Configuration

This Terraform configuration manages Vault policies and Kubernetes authentication roles for namespace-based access control. It uses a modular approach to allow easy configuration of policies and roles for each namespace.

## Architecture

The configuration is structured as follows:

```
vault/terraform/
├── main.tf                    # Root module that instantiates the vault-namespace-access module
├── variables.tf               # Root-level variables
├── outputs.tf                 # Root-level outputs
├── terraform.tfvars          # Variable values (customize per environment)
├── provider.tf               # Terraform and provider configuration
└── modules/
    └── vault-namespace-access/
        ├── main.tf           # Module resources (policy + role)
        ├── variables.tf      # Module input variables
        ├── outputs.tf        # Module outputs
        └── README.md         # Module documentation
```

## Features

- **Modular Design**: Each namespace gets its own policy and Kubernetes auth role via the reusable module
- **Flexible Policy Configuration**: Define custom HCL policies for each namespace
- **Kubernetes Integration**: Binds service accounts and namespaces to Vault roles
- **Easy to Extend**: Add new namespaces by adding entries to the `namespaces` variable

## Prerequisites

1. Vault server running and accessible
2. Kubernetes auth backend enabled in Vault
3. Terraform >= 1.0 installed
4. Valid Vault authentication (token, Kubernetes, etc.)

## Security Considerations

**⚠️ IMPORTANT: Before committing to a public repository:**

This directory contains sensitive configuration files that should NOT be committed to public repositories:

### Files to Keep Private

1. **`terraform.tfvars`** - Contains environment-specific configuration including:
   - Vault server addresses
   - Namespace configurations
   - Service account names
   - Internal infrastructure details

2. **`terraform.tfstate` and `terraform.tfstate.backup`** - State files contain:
   - Vault policy IDs and names
   - Kubernetes auth role configurations
   - Complete infrastructure state

3. **`.terraform/` directory** - Contains provider binaries and modules

4. **`.terraform.lock.hcl`** - Provider version lock file (optional to commit)

### Protected by .gitignore

A [`.gitignore`](.gitignore) file has been created in this directory to prevent accidental commits of sensitive files. The following are excluded:

- `*.tfvars` and `*.tfvars.json` files
- `*.tfstate` and `*.tfstate.*` files
- `.terraform/` directory
- `.terraform.lock.hcl`

### Safe to Commit

The following files are safe to commit to public repositories:

- `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf` - Infrastructure code
- `terraform.tfvars.example` - Template with placeholder values
- `modules/` directory - Reusable module code
- `README.md` and documentation files

### Best Practices

1. **Use `terraform.tfvars.example`**: Copy this template to create your `terraform.tfvars`
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your actual values
   ```

2. **Store state remotely**: Consider using remote state backends (S3, Terraform Cloud, etc.) instead of local state files

3. **Use environment variables**: For sensitive values like Vault tokens:
   ```bash
   export VAULT_TOKEN="your-token"
   export VAULT_ADDR="https://vault.example.com"
   ```

4. **Review before commit**: Always run `git status` and review files before committing

## Usage

### 1. Configure Variables

Edit [`terraform.tfvars`](terraform.tfvars) to define your namespace configurations:

```hcl
vault_address            = "https://vault.example.com"
kubernetes_auth_backend  = "kubernetes"

namespaces = {
  my-app = {
    policy_name = "cluster-my-app-credentials"
    policy_hcl = <<EOT
path "secret/data/clusters/my-cluster/my-app/credentials/*" {
  capabilities = ["read", "list"]
}
EOT
    role_name        = "my-app-cluster"
    service_accounts = ["default", "my-app-sa"]
    namespaces       = ["my-app"]
    token_ttl        = 3600
  }
}
```

### 2. Initialize Terraform

```bash
cd vault/terraform
terraform init
```

### 3. Plan Changes

```bash
terraform plan
```

### 4. Apply Configuration

```bash
terraform apply
```

## Adding a New Namespace

To add a new namespace configuration:

1. Open [`terraform.tfvars`](terraform.tfvars)
2. Add a new entry to the `namespaces` map:

```hcl
namespaces = {
  # Existing configurations...
  
  new-app = {
    policy_name = "dell7040-new-app-credentials"
    policy_hcl = <<EOT
# Allow new-app to read credentials from its dedicated path
path "secret/data/clusters/dell7040/new-app/credentials/*" {
  capabilities = ["read", "list"]
}

# Allow listing the credentials directory
path "secret/metadata/clusters/dell7040/new-app/credentials/*" {
  capabilities = ["list"]
}
EOT
    role_name        = "new-app-dell7040"
    service_accounts = ["default"]
    namespaces       = ["new-app"]
    token_ttl        = 3600
  }
}
```

3. Run `terraform plan` and `terraform apply`

## Configuration Reference

### Root Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| vault_address | The address of the Vault server | `string` | `"https://vault.lab.definit.co.uk"` |
| kubernetes_auth_backend | Path to the Kubernetes auth backend in Vault | `string` | `"kubernetes"` |
| namespaces | Map of namespace configurations | `map(object)` | `{}` |

### Namespace Configuration Object

Each namespace configuration requires:

- `policy_name`: Name for the Vault policy
- `policy_hcl`: HCL policy document defining access rules
- `role_name`: Name for the Kubernetes auth role
- `service_accounts`: List of service account names that can authenticate
- `namespaces`: List of Kubernetes namespaces where service accounts exist
- `token_ttl`: Token time-to-live in seconds

## Outputs

The configuration provides the following outputs:

- `namespace_policies`: Map of created Vault policies for each namespace
- `namespace_roles`: Map of created Kubernetes auth roles for each namespace
- `namespace_summary`: Summary of all namespace configurations

View outputs with:

```bash
terraform output
```

## Authentication

Set the `VAULT_TOKEN` environment variable before running Terraform:

```bash
export VAULT_TOKEN="your-vault-token"
terraform plan
```

Alternatively, configure other authentication methods in [`provider.tf`](provider.tf).

## Module Documentation

For detailed information about the vault-namespace-access module, see [modules/vault-namespace-access/README.md](modules/vault-namespace-access/README.md).

## Migrating from Old Configuration

The previous configuration used a single file with hardcoded patterns. The new modular approach provides:

- **Better Separation of Concerns**: Each namespace is independently configured
- **More Flexibility**: Custom policies per namespace instead of templated patterns
- **Easier Maintenance**: Add/remove namespaces without touching Terraform code
- **Reusability**: The module can be used in other projects

## Troubleshooting

### Policy Not Working

1. Verify the policy HCL syntax is correct
2. Check that the secret paths match your Vault KV structure
3. Ensure the Kubernetes auth backend is properly configured

### Authentication Failures

1. Verify service account names and namespaces are correct
2. Check that the Kubernetes auth backend role is bound correctly
3. Ensure the service account has the necessary Kubernetes RBAC permissions

### Token TTL Issues

Adjust the `token_ttl` value in your namespace configuration. Values are in seconds:
- 1 hour = 3600
- 24 hours = 86400
- 7 days = 604800