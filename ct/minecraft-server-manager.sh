#!/usr/bin/env bash
_CS_DEFAULT_URL="${_CS_DEFAULT_URL:-https://raw.githubusercontent.com/NumberedThought/proxmox-scripts/main}"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2021-2026 community-scripts ORG
# Author: NumberedThought
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://github.com/anefzaoui/minecraft-server-manager

APP="Minecraft-Server-Manager"
var_tags="${var_tags:-gaming;minecraft;docker}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-8192}"
var_disk="${var_disk:-32}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
#var_arm64="${var_arm64:-no}" # unset = ask the user; set yes/no only when verified
var_unprivileged="${var_unprivileged:-1}"
var_nesting="${var_nesting:-1}"
var_keyctl="${var_keyctl:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -f ~/.minecraft-server-manager ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "minecraft-server-manager" "anefzaoui/minecraft-server-manager"; then
    msg_info "Stopping Minecraft Server Manager"
    systemctl stop minecraft-server-manager
    msg_ok "Stopped Minecraft Server Manager"

    create_backup /opt/minecraft-server-manager/.env

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "minecraft-server-manager" "anefzaoui/minecraft-server-manager" "tarball"
    NODE_VERSION="24" NODE_MODULE="pnpm" setup_nodejs

    restore_backup

    msg_info "Building Minecraft Server Manager"
    cd /opt/minecraft-server-manager
    $STD pnpm install --frozen-lockfile
    $STD pnpm run build
    msg_ok "Built Minecraft Server Manager"

    msg_info "Starting Minecraft Server Manager"
    systemctl start minecraft-server-manager
    msg_ok "Started Minecraft Server Manager"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}:25564${CL}"
echo -e "${INFO}${YW}First-run setup PIN (inside the container):${CL} ${BGN}journalctl -u minecraft-server-manager | grep -o '\"pin\":\"[0-9]*\"'${CL}"
