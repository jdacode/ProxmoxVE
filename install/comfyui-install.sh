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
whiptail_backtitle="Proxmox VE Helper Scripts"
whiptail_title="ComfyUI Configuration"
comfyui_version="latest"
gpu_type="None"
python_version_uv="3.12"
application_name="${APPLICATION}"
port_arg="8080"
comfyui_python_args="--port ${port_arg}"

msg_info "Starting ${application_name} installation"

##########################################
# CONFIG_SUMMARY="\
# Default configuration:

#   ComfyUI version     : ${comfyui_version}
#   GPU                 : ${gpu_type}
#   Python version (uv) : ${python_version_uv}
#   Application name    : ${application_name}
#   ComfyUI python args : ${comfyui_python_args}"

# whiptail --backtitle "${whiptail_backtitle}" \
#          --title "${whiptail_title}" \
#          --msgbox "${CONFIG_SUMMARY}" 15 60

# # GPU Selection
# while true; do
#   GPU=$(whiptail --backtitle "${whiptail_backtitle}" --menu \
#     "Select GPU Type:" 15 58 4 \
#     "none" "None (recommended, default)" \
#     "nvidia" "NVIDIA" \
#     "amd" "AMD" \
#     "intel" "Intel" \
#     --default-item "none" \
#     --title "ComfyUI Configuration" 3>&1 1>&2 2>&3)
#   [ $? -ne 0 ] && exit_script

#   case "${gpu_type}" in
#   none)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}${gpu_type}${CL}"
#     break
#     ;;
#   nvidia)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}${gpu_type}${CL}"
#     break
#     ;;
#   amd)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}${gpu_type}${CL}"
#     break
#     ;;
#   intel)
#     echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}${gpu_type}${CL}"
#     break
#     ;;
#   *)
#     exit_script
#     ;;
#   esac
# done
##########################################

echo
echo "=============================================================="
echo
echo
echo "${TAB3}Default configuration summary:"
echo "${TAB3}-------------------------------"
echo "${TAB3}${TAB3}ComfyUI version     : ${comfyui_version}"
echo "${TAB3}${TAB3}GPU                 : ${gpu_type}"
echo "${TAB3}${TAB3}Python version (uv) : ${python_version_uv}"
echo "${TAB3}${TAB3}Application name    : ${application_name}"
echo "${TAB3}${TAB3}Port                : ${port_arg}"
echo "${TAB3}${TAB3}ComfyUI arguments   : ${comfyui_python_args}"
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
  echo "=============================================================="
  echo
  echo
  echo "${TAB3}Choose the GPU type for ComfyUI:"
  echo "${TAB3}${TAB3}  1) None   (recommended, default)"
  echo "${TAB3}${TAB3}  2) NVIDIA"
  echo "${TAB3}${TAB3}  3) AMD"
  echo "${TAB3}${TAB3}  4) Intel"
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

  echo -e "${CM}${BOLD}${DGN}GPU: ${BGN}${gpu_type}${CL}"
  break
done








# # Installs uv
# msg_info "Setup uv"
# PYTHON_VERSION="${python_version_uv}" setup_uv
# msg_ok "Setup uv"


# # Setup App
# msg_info "Setup ${application_name}"

# if [[ "$comfyui_version" == "latest" ]]; then
#   echo "Version is set to 'latest'; skipping version check."
#   RELEASE=$(curl -fsSL https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
# else
#   RELEASE="$comfyui_version"
# fi

# msg_info "Installing ComfyUI version ${comfyui_version}"
# curl -fsSL -o "${application_name}.zip" "https://github.com/comfyanonymous/ComfyUI/archive/refs/tags/${RELEASE}.zip"
# unzip -q "${application_name}.zip"
# # Remove v
# CLEAN_RELEASE="${RELEASE//v/}"
# # Move app to opt
# mv "${application_name}-${CLEAN_RELEASE}/" "/opt/${application_name}"
# $STD uv venv "/opt/${application_name}/venv"
# $STD uv pip install -r "/opt/${application_name}/requirements.txt" --python="/opt/${application_name}/venv/bin/python"
# #
# # 
# #
# echo "${RELEASE}" >/opt/"${application_name}"_version.txt
# msg_ok "Setup ${application_name}"

# # Creating Service (if needed)
# msg_info "Creating Service"
# cat <<EOF >/etc/systemd/system/"${application_name}".service
# [Unit]
# Description=${application_name} Service
# After=network.target

# [Service]
# Type=simple
# User=root
# WorkingDirectory=/opt/${application_name}
# ExecStart=/opt/${application_name}/venv/bin/python /opt/${application_name}/main.py ${comfyui_python_args} --listen
# Restart=on-failure

# [Install]
# WantedBy=multi-user.target
# EOF
# systemctl enable -q --now "${application_name}"
# msg_ok "Created Service"

# motd_ssh
# customize

# Cleanup
msg_info "Cleaning up"
rm -f "${application_name}".zip
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"


