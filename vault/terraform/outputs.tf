output "namespace_policies" {
  description = "Map of created Vault policies for each namespace"
  value = {
    for ns, module in module.namespace_access : ns => {
      name = module.policy_name
      id   = module.policy_id
    }
  }
}

output "namespace_roles" {
  description = "Map of created Kubernetes auth roles for each namespace"
  value = {
    for ns, module in module.namespace_access : ns => {
      name = module.role_name
      id   = module.role_id
    }
  }
}

output "namespace_summary" {
  description = "Summary of all namespace configurations"
  value = {
    for ns, config in var.namespaces : ns => {
      policy_name = config.policy_name
      role_name   = config.role_name
      namespaces  = config.namespaces
      token_ttl   = config.token_ttl
    }
  }
}