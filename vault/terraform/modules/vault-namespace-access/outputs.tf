output "policy_name" {
  description = "Name of the created Vault policy"
  value       = vault_policy.namespace_policy.name
}

output "policy_id" {
  description = "ID of the created Vault policy"
  value       = vault_policy.namespace_policy.id
}

output "role_name" {
  description = "Name of the created Kubernetes auth role"
  value       = vault_kubernetes_auth_backend_role.namespace_role.role_name
}

output "role_id" {
  description = "ID of the created Kubernetes auth role"
  value       = vault_kubernetes_auth_backend_role.namespace_role.id
}