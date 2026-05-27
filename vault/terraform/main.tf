# Main Terraform configuration for Vault namespace access
# Uses the vault-namespace-access module to configure policies and roles for each namespace

module "namespace_access" {
  source = "./modules/vault-namespace-access"

  for_each = var.namespaces

  policy_name             = each.value.policy_name
  policy_hcl              = each.value.policy_hcl
  role_name               = each.value.role_name
  kubernetes_auth_backend = var.kubernetes_auth_backend
  service_accounts        = each.value.service_accounts
  namespaces              = each.value.namespaces
  token_ttl               = each.value.token_ttl
}