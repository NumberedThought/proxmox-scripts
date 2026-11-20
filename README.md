# Proxmox helper script: Minecraft Server Manager

A [community-scripts](https://community-scripts.org/)-style one-command LXC installer for
[anefzaoui/minecraft-server-manager](https://github.com/anefzaoui/minecraft-server-manager).
It uses the official community-scripts engine (`community-scripts/core`), so you get the same
whiptail menus, Default/Advanced modes and `update` command as every other helper script.

## Install

Push this folder to `github.com/NumberedThought/proxmox-scripts` (public), then in the
**Proxmox host shell** run:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NumberedThought/proxmox-scripts/main/ct/minecraft-server-manager.sh)"
```

Using a different repo? Change the `_CS_DEFAULT_URL` line at the top of
`ct/minecraft-server-manager.sh`. The engine fetches `install/minecraft-server-manager-install.sh`
from there.

Want to run it without hosting? Copy the folder to the Proxmox host and run
`bash ct/minecraft-server-manager.sh` from inside it. The engine finds `install/` next to `ct/`.

## What it builds

- Unprivileged Debian 13 LXC, 4 vCPU / 8 GB RAM / 32 GB disk by default, with nesting and keyctl turned on (Docker needs both)
- Docker Engine (from the official repo) to run each Minecraft server as an `itzg/minecraft-server` container
- Node.js 24 + pnpm, with the latest MSM GitHub release built in `/opt/minecraft-server-manager`
- Panel data in `/opt/minecraft-server-manager-data` (worlds, backups, DB, `.secret-key`). Back up this folder.
- systemd unit `minecraft-server-manager`, listening on `0.0.0.0:25564`

## First login

Open `http://<container-ip>:25564`. The panel is reachable from your LAN, so first-run setup asks
for a one-time PIN. Get it from inside the container:

```bash
journalctl -u minecraft-server-manager | grep -o '"pin":"[0-9]*"'
```

## Update

Inside the container, run `update`. Or re-run the install command on the host and pick
**Update**. Only an upstream release you don't have yet triggers a rebuild. Your `.env` and
data directory are kept.

## Upstreaming

The community-scripts rules accept new apps only through
[DevScripts](https://github.com/community-scripts/DevScripts), and the app needs 1,000+ stars and
must be at least 6 months old. MSM had 108 stars and was about 4 months old on 2026-11-20, so it
doesn't qualify yet. The files already follow the DevScripts layout (`ct/`, `install/`, `json/`),
so they can be submitted once it does.
