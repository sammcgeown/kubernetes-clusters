# Vault Namespace Access Module
# Creates a Vault policy and Kubernetes auth role for a specific namespace

resource "vault_policy" "namespace_policy" {
  name = var.policy_name

  policy = var.policy_hcl
}

resource "vault_kubernetes_auth_backend_role" "namespace_role" {
  backend                          = var.kubernetes_auth_backend
  role_name                        = var.role_name
  bound_service_account_names      = var.service_accounts
  bound_service_account_namespaces = var.namespaces
  token_ttl                        = var.token_ttl
  token_policies                   = [vault_policy.namespace_policy.name]
}