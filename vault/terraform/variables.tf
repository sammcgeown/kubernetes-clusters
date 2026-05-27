variable "vault_address" {
  description = "The address of the Vault server"
  type        = string
  default     = "https://vault.lab.definit.co.uk"
}

variable "kubernetes_auth_backend" {
  description = "Path to the Kubernetes auth backend in Vault"
  type        = string
  default     = "kubernetes"
}

variable "namespaces" {
  description = "Map of namespace configurations with their Vault access settings"
  type = map(object({
    policy_name      = string
    policy_hcl       = string
    role_name        = string
    service_accounts = list(string)
    namespaces       = list(string)
    token_ttl        = number
  }))
  default = {}
}