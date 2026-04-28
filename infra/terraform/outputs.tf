output "server_ipv4" {
  value       = data.hcloud_server.tbc.ipv4_address
  description = "Public IPv4 of the shared host. Use for ansible inventory."
}

output "server_ipv6" {
  value       = data.hcloud_server.tbc.ipv6_address
  description = "Public IPv6 of the shared host."
}

output "firewall_rule_count" {
  value       = length(data.hcloud_firewall.tbc.rule)
  description = "Sanity check: this should match the tbc-managed rule count and never change as a result of running this module."
}
