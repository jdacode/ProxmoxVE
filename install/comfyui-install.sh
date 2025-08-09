#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: jdacode
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/comfyanonymous/ComfyUI

# Import Functions und Setup
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os


GPU="None"
GPU_TYPE="None\nNVIDIA\nAMD\nIntel"

msg_info "GPU: ${GPU}"
msg_info "GPU: ${GPU_TYPE}"

# GPU Selection
while true; do
  GPU=$(whiptail --backtitle "Proxmox VE Helper Scripts" --menu \
    "Select GPU Type:" 15 58 4 \
    "none" "None (recommended, default)" \
    "nvidia" "NVIDIA" \
    "amd" "AMD" \
    "intel" "Intel" \
    --default-item "none" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && exit_script

  case "$GPU" in
  none)
    echo -e "${CREATING}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
    break
    ;;
  nvidia)
    echo -e "${CREATING}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
    break
    ;;
  amd)
    echo -e "${CREATING}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
    break
    ;;
  intel)
    echo -e "${CREATING}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
    break
    ;;
  *)
    exit_script
    ;;
  esac
done

# # Installs uv
# msg_info "Setup uv"
# PYTHON_VERSION="3.12" setup_uv
# msg_ok "Setup uv"


# # Setup App
# msg_info "Setup ${APPLICATION}"
# RELEASE=$(curl -fsSL https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
# curl -fsSL -o "${APPLICATION}.zip" "https://github.com/comfyanonymous/ComfyUI/archive/refs/tags/${RELEASE}.zip"
# unzip -q "${APPLICATION}.zip"
# # Remove v
# CLEAN_RELEASE="${RELEASE//v/}"
# # Move app to opt
# mv "${APPLICATION}-${CLEAN_RELEASE}/" "/opt/${APPLICATION}"
# $STD uv venv "/opt/${APPLICATION}/venv"
# $STD uv pip install -r "/opt/${APPLICATION}/requirements.txt" --python="/opt/${APPLICATION}/venv/bin/python"
# #
# # 
# #
# echo "${RELEASE}" >/opt/"${APPLICATION}"_version.txt
# msg_ok "Setup ${APPLICATION}"

# # Creating Service (if needed)
# msg_info "Creating Service"
# cat <<EOF >/etc/systemd/system/"${APPLICATION}".service
# [Unit]
# Description=${APPLICATION} Service
# After=network.target

# [Service]
# Type=simple
# User=root
# WorkingDirectory=/opt/ComfyUI
# ExecStart=/opt/${APPLICATION}/venv/bin/python /opt/ComfyUI/main.py --port 8080 --listen
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target
# EOF
# systemctl enable -q --now "${APPLICATION}"
# msg_ok "Created Service"

# motd_ssh
# customize

# # Cleanup
# msg_info "Cleaning up"
# rm -f "${APPLICATION}".zip
# $STD apt-get -y autoremove
# $STD apt-get -y autoclean
# msg_ok "Cleaned"



custom_install_script() {
  GPU_TYPE=""
  GPU_TYPE="None\nNVIDIA\nAMD\nIntel"

  msg_info "GPU: ${GPU_TYPE}"
  exit_script

  if [[ -z "$GPU_TYPE" ]]; then
    GPU="None"
    echo -e "${CREATING}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
  else
    GPU=$(whiptail --backtitle "Proxmox VE Helper Scripts" --menu "Select GPU Type:" 15 40 6 $(echo "$GPU_TYPE" | awk '{print $0}') 3>&1 1>&2 2>&3)
    if [ -z "$GPU" ]; then
      exit_script
    else
      echo -e "${CREATING}${BOLD}${DGN}Bridge: ${BGN}$GPU${CL}"
    fi
  fi
}
