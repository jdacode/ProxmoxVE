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
# update_os

# Default configuration variables
WHIPTAIL_BACKTITLE="Proxmox VE Helper Scripts"
WHIPTAIL_TITLE="ComfyUI Configuration"
COMFYUI_VERSION="latest"
GPU="None"
PYTHON_VERSION_UV="3.12"
APPLICATION_NAME="${APPLICATION}"
PORT="8080"
COMFYUI_PYTHON_ARGS="--port ${PORT}"



##########################################
# CONFIG_SUMMARY="\
# Default configuration:

#   ComfyUI version     : ${COMFYUI_VERSION}
#   GPU                 : ${GPU}
#   Python version (uv) : ${PYTHON_VERSION_UV}
#   Application name    : ${APPLICATION_NAME}
#   ComfyUI python args : ${COMFYUI_PYTHON_ARGS}"

# whiptail --backtitle "${WHIPTAIL_BACKTITLE}" \
#          --title "${WHIPTAIL_TITLE}" \
#          --msgbox "${CONFIG_SUMMARY}" 15 60

# # GPU Selection
# while true; do
#   GPU=$(whiptail --backtitle "${WHIPTAIL_BACKTITLE}" --menu \
#     "Select GPU Type:" 15 58 4 \
#     "none" "None (recommended, default)" \
#     "nvidia" "NVIDIA" \
#     "amd" "AMD" \
#     "intel" "Intel" \
#     --default-item "none" \
#     --title "ComfyUI Configuration" 3>&1 1>&2 2>&3)
#   [ $? -ne 0 ] && exit_script

#   case "$GPU" in
#   none)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
#     break
#     ;;
#   nvidia)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
#     break
#     ;;
#   amd)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
#     break
#     ;;
#   intel)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
#     break
#     ;;
#   *)
#     exit_script
#     ;;
#   esac
# done
##########################################

echo
echo
echo
echo "${TAB3}Default configuration summary:"
echo "${TAB3}-------------------------------"
echo "${TAB3}ComfyUI version     : ${COMFYUI_VERSION}"
echo "${TAB3}GPU                 : ${GPU}"
echo "${TAB3}Python version (uv) : ${PYTHON_VERSION_UV}"
echo "${TAB3}Application name    : ${APPLICATION_NAME}"
echo "${TAB3}Port                : ${PORT}"
echo "${TAB3}ComfyUI arguments   : ${COMFYUI_PYTHON_ARGS}"
echo

while true; do
  echo
  echo
  read -rp "${TAB3}Do you want to keep this configuration? (y/n) [Y]: " CONFIG_CONFIRM
  CONFIG_CONFIRM=${CONFIG_CONFIRM:-y}

  case "$CONFIG_CONFIRM" in
    [Yy])
      echo "${TAB3}Configuration accepted."
      break
      ;;
    [Nn])
      echo "${TAB3}Switching to advanced configuration..."
      break
      ;;
    *)
      echo "${TAB3}Please enter Y (yes) or N (no)."
      ;;
  esac
done


while true; do
  echo
  echo
  echo
  echo "${TAB3}Choose the GPU type for ComfyUI:"
  echo "${TAB3}  1) None   (recommended, default)"
  echo "${TAB3}  2) NVIDIA"
  echo "${TAB3}  3) AMD"
  echo "${TAB3}  4) Intel"
  echo

  echo
  read -rp "${TAB3}Enter your choice [1-4] (default: 1): " GPU_CHOICE
  GPU_CHOICE=${GPU_CHOICE:-1}

  case "$GPU_CHOICE" in
    1)
      GPU="none"
      ;;
    2)
      GPU="nvidia"
      ;;
    3)
      GPU="amd"
      ;;
    4)
      GPU="intel"
      ;;
    *)
      echo "${TAB3}Invalid choice. Please enter a number between 1 and 4."
      continue
      ;;
  esac

  echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}$GPU${CL}"
  break
done








# # Installs uv
# msg_info "Setup uv"
# PYTHON_VERSION="${PYTHON_VERSION_UV}" setup_uv
# msg_ok "Setup uv"


# # Setup App
# msg_info "Setup ${APPLICATION_NAME}"

# if [[ "$COMFYUI_VERSION" == "latest" ]]; then
#   echo "🟢 Version is set to 'latest'; skipping version check."
#   RELEASE=$(curl -fsSL https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
# else
#   RELEASE="$COMFYUI_VERSION"
# fi

# msg_info "Installing ComfyUI version ${COMFYUI_VERSION}"
# curl -fsSL -o "${APPLICATION_NAME}.zip" "https://github.com/comfyanonymous/ComfyUI/archive/refs/tags/${RELEASE}.zip"
# unzip -q "${APPLICATION_NAME}.zip"
# # Remove v
# CLEAN_RELEASE="${RELEASE//v/}"
# # Move app to opt
# mv "${APPLICATION_NAME}-${CLEAN_RELEASE}/" "/opt/${APPLICATION_NAME}"
# $STD uv venv "/opt/${APPLICATION_NAME}/venv"
# $STD uv pip install -r "/opt/${APPLICATION_NAME}/requirements.txt" --python="/opt/${APPLICATION_NAME}/venv/bin/python"
# #
# # 
# #
# echo "${RELEASE}" >/opt/"${APPLICATION_NAME}"_version.txt
# msg_ok "Setup ${APPLICATION_NAME}"

# # Creating Service (if needed)
# msg_info "Creating Service"
# cat <<EOF >/etc/systemd/system/"${APPLICATION_NAME}".service
# [Unit]
# Description=${APPLICATION_NAME} Service
# After=network.target

# [Service]
# Type=simple
# User=root
# WorkingDirectory=/opt/${APPLICATION_NAME}
# ExecStart=/opt/${APPLICATION_NAME}/venv/bin/python /opt/${APPLICATION_NAME}/main.py ${COMFYUI_PYTHON_ARGS} --listen
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target
# EOF
# systemctl enable -q --now "${APPLICATION_NAME}"
# msg_ok "Created Service"

# motd_ssh
# customize

# Cleanup
msg_info "Cleaning up"
rm -f "${APPLICATION_NAME}".zip
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"


