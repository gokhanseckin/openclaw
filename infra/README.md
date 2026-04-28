# OpenClaw infra

Deploys OpenClaw onto the existing Hetzner VPS `tbc-prod` (shared with
[telegram-brain-claude](https://github.com/gokhanseckin/telegram-brain-claude)).
**Purely additive** — does not modify the firewall, Postgres, Ollama, Caddy,
or any `tbc-*` systemd unit.

Per [upstream's SECURITY.md](https://github.com/openclaw/openclaw/blob/main/SECURITY.md#web-interface-safety),
the Gateway is **not exposed publicly**. It binds to `127.0.0.1` only; reach
it via SSH local-port-forward.

## What it installs

- A non-login system user `openclaw` (`/var/lib/openclaw`).
- Node.js 24 LTS via NodeSource APT.
- The pinned OpenClaw release from npm (global install).
- A hardened systemd unit `openclaw-gateway.service` that runs
  `openclaw gateway --bind loopback --port 18789` as the `openclaw` user.

The Hetzner cloud firewall, `ufw`, and `/etc/caddy/Caddyfile` are **not** touched.

## Prerequisites

1. SSH access to `root@178.104.45.149` with `~/.ssh/id_ed25519` (same key as tbc).
2. Local tools: `terraform` ≥ 1.6, `ansible-core` ≥ 2.16, `community.general` collection.
3. Hetzner API token exported as `TF_VAR_hcloud_token` **or** placed in
   `infra/terraform/terraform.tfvars` (gitignored — never commit).

## Deploy

```bash
cd infra/terraform
terraform init
terraform apply           # data-only; verifies host + firewall exist
cd ../ansible
ansible-galaxy collection install community.general
ansible-playbook -i inventory/hosts.yml playbook.yml --diff
```

Re-running is idempotent: a clean second run reports `changed=0`.

## Reach the Gateway

From your laptop:

```bash
ssh -L 18789:127.0.0.1:18789 root@178.104.45.149
# leave that shell open, then in a browser:
open http://localhost:18789
```

## After deploy: setup, then enable

The gateway refuses to start without an initial configuration — that's why the
ansible role installs the unit but leaves it **disabled**. Run setup once
(interactive, picks an account/mode), then enable + start:

```bash
ssh root@178.104.45.149
# as the service user:
sudo -u openclaw HOME=/var/lib/openclaw openclaw setup
# optional: pick integrations (Telegram/Slack/etc.)
sudo -u openclaw HOME=/var/lib/openclaw openclaw onboard
# then fill /etc/openclaw/env (mode 0600) with any required secrets, and:
sudo systemctl enable --now openclaw-gateway
```

## Verify the tbc stack is unaffected

```bash
ssh root@178.104.45.149 'systemctl is-active openclaw-gateway tbc-mcp-server tbc-bot'
curl -fsS https://mcp.gokhanseckin.com/   # tbc still responding
```
