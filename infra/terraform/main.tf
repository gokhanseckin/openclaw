provider "hcloud" {
  token = var.hcloud_token
}

# Read-only references to existing infrastructure provisioned by telegram-brain-claude.
# This module deliberately creates NO resources — it just verifies the host and
# firewall exist before ansible runs, and exposes their IPs for the inventory.

data "hcloud_server" "tbc" {
  name = var.server_name
}

data "hcloud_firewall" "tbc" {
  name = var.firewall_name
}
