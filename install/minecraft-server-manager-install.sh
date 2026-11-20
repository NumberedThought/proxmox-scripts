#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: NumberedThought
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://github.com/anefzaoui/minecraft-server-manager

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

setup_docker
NODE_VERSION="24" NODE_MODULE="pnpm" setup_nodejs

fetch_and_deploy_gh_release "minecraft-server-manager" "anefzaoui/minecraft-server-manager" "tarball"

msg_info "Building Minecraft Server Manager"
cd /opt/minecraft-server-manager
$STD pnpm install --frozen-lockfile
$STD pnpm run build
msg_ok "Built Minecraft Server Manager"

msg_info "Configuring Minecraft Server Manager"
mkdir -p /opt/minecraft-server-manager-data
cat <<EOF >/opt/minecraft-server-manager/.env
DATA_DIR=/opt/minecraft-server-manager-data
PANEL_HOST=0.0.0.0
PANEL_PORT=25564
LOG_PRETTY=false
MSM_EXIT_ON_FATAL=1
EOF
chmod 600 /opt/minecraft-server-manager/.env
msg_ok "Configured Minecraft Server Manager"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/minecraft-server-manager.service
[Unit]
Description=Minecraft Server Manager
After=network-online.target docker.service
Wants=network-online.target docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/minecraft-server-manager
Environment=NODE_ENV=production
Environment=MSM_SKIP_POSTINSTALL=1
ExecStart=/usr/bin/node /opt/minecraft-server-manager/src/server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now minecraft-server-manager
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
