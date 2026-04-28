variable "hcloud_token" {
  description = "Hetzner Cloud API token. Provide via TF_VAR_hcloud_token or terraform.tfvars (gitignored). NEVER commit."
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the existing Hetzner server hosting OpenClaw + tbc."
  type        = string
  default     = "tbc-prod"
}

variable "firewall_name" {
  description = "Name of the existing Hetzner cloud firewall (we only read it; we do not modify it)."
  type        = string
  default     = "tbc-prod-fw"
}
