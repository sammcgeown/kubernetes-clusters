variable "policy_name" {
  description = "Name of the Vault policy to create"
  type        = string
}

variable "policy_hcl" {
  description = "HCL policy document for Vault"
  type        = string
}

variable "role_name" {
  description = "Name of the Kubernetes auth role to create"
  type        = string
}

variable "kubernetes_auth_backend" {
  description = "Path to the Kubernetes auth backend in Vault"
  type        = string
  default     = "kubernetes"
}

variable "service_accounts" {
  description = "List of Kubernetes service account names that can authenticate"
  type        = list(string)
}

variable "namespaces" {
  description = "List of Kubernetes namespaces where the service accounts exist"
  type        = list(string)
}

variable "token_ttl" {
  description = "TTL for tokens issued by this role (in seconds)"
  type        = number
  default     = 3600
}