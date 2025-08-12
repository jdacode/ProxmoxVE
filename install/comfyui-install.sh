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



# Installing Dependencies
msg_info "Installing Dependencies"
$STD apt-get install -y \
  git \
  nvtop
msg_ok "Installed Dependencies"



# Default configuration variables
comfyui_version="latest"
gpu_type="None"
python_version_uv="3.12"
application_name="${APPLICATION}"
port_arg="8080"
comfyui_python_port_args="--port ${port_arg}"
comfyui_python_args=""
comfyui_manager_enabled="y"



# Current configuration variables
current_settings_info() {
  echo
  echo "${TAB3}${TAB3}Current configuration summary:"
  echo "${TAB3}${TAB3}-------------------------------"
  echo "${TAB3}${TAB3}${TAB3}ComfyUI version            : ${comfyui_version}"
  echo "${TAB3}${TAB3}${TAB3}GPU                        : ${gpu_type}"
  echo "${TAB3}${TAB3}${TAB3}Python version (uv)        : ${python_version_uv}"
  echo "${TAB3}${TAB3}${TAB3}Port                       : ${port_arg}"
  echo "${TAB3}${TAB3}${TAB3}ComfyUI python args        : ${comfyui_python_args}"
  echo "${TAB3}${TAB3}${TAB3}ComfyUI Manager            : ${comfyui_manager_enabled}"
  echo "${TAB3}${TAB3}${TAB3}Preview ExecStart command  : main.py --listen ${comfyui_python_port_args} ${comfyui_python_args}"
  echo
}

# GPU selection
select_gpu_type() {
  while true; do
    echo
    echo "${TAB3}${TAB3}Choose the GPU type for ComfyUI:"
    echo "${TAB3}${TAB3}-------------------------------"
    echo "${TAB3}${TAB3}${TAB3}  1. None"
    echo "${TAB3}${TAB3}${TAB3}  2. NVIDIA"
    echo "${TAB3}${TAB3}${TAB3}  3. AMD"
    echo "${TAB3}${TAB3}${TAB3}  4. Intel"
    echo
    read -rp "${TAB3}${TAB3}${TAB3}Enter your choice [1-4] (Current: ${gpu_type}): " GPU_CHOICE
    GPU_CHOICE=${GPU_CHOICE:-1}
    case "$GPU_CHOICE" in
      1) gpu_type="None"; break ;;
      2) gpu_type="NVIDIA"; break ;;
      3) gpu_type="AMD"; break ;;
      4) gpu_type="Intel"; break ;;
      *) echo "${TAB3}${TAB3}${TAB3}${TAB3}Invalid choice. Please enter a number between 1 and 4." ;;
    esac
  done
}

# ComfyUI version
set_comfyui_version() {
  while true; do
    read -re -i "${comfyui_version}" -p  "${TAB3}${TAB3}Enter ComfyUI version (e.g. v0.3.49 or 'latest') [Current: ${comfyui_version}]: " input_version
    input_version=${input_version:-$comfyui_version}
    if [[ "$input_version" == "latest" || "$input_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      comfyui_version="$input_version"
      break
    else
      echo "${TAB3}${TAB3}${TAB3}${TAB3}Invalid input. Use 'latest' or a version like v0.3.49."
    fi
  done
}

# Python version
set_python_version() {
  read -re -i "${python_version_uv}" -p "${TAB3}${TAB3}Enter Python version (uv) [Current: ${python_version_uv}]: " input_python
  python_version_uv=${input_python:-$python_version_uv}
}

# Port number
set_port_number() {
  while true; do
    read -re -i "${port_arg}" -p "${TAB3}${TAB3}Enter port number [Current: ${port_arg}]: " input_port
    input_port=${input_port:-$port_arg}
    if [[ "$input_port" =~ ^[0-9]+$ ]]; then
      port_arg="$input_port"
      comfyui_python_port_args="--port ${port_arg}"
      break
    else
      echo "${TAB3}${TAB3}${TAB3}${TAB3}Invalid port. Must be a number."
    fi
  done
}

# ComfyUI arguments
set_comfyui_args() {
  read -re -i "${comfyui_python_args}" -p "${TAB3}${TAB3}Enter ComfyUI python args. (e.g. --gpu-only) [Current: ${comfyui_python_args}]: " input_args
  comfyui_python_args=${input_args:-$comfyui_python_args}
}

# Set ComfyUI manager
set_comfyui_manager() {
  while true; do
    read -re -i "${comfyui_manager_enabled}" -p "${TAB3}${TAB3}Enable ComfyUI-Manager? [Y/n] (Current: ${comfyui_manager_enabled}): " input_manager
    input_manager=${input_manager:-$comfyui_manager_enabled}
    case "${input_manager,,}" in
      [Yy])
        comfyui_manager_enabled="y"
        break
        ;;
      [Nn])
        comfyui_manager_enabled="n"
        break
        ;;
      *)
        echo "${TAB3}${TAB3}${TAB3}Please enter Y/y or N/n."
        ;;
    esac
  done
}


# ComfyUI Manager
install_comfyui_manager() {
  # Define the target directory
  local custom_nodes_dir="/opt/${application_name}/custom_nodes"

  # Check if the directory exists
  if [[ ! -d "${custom_nodes_dir}" ]]; then
    echo "${TAB3}${TAB3}${TAB3}Error: Directory not found: ${custom_nodes_dir}"
    return 1
  fi

  # Clone the manager
  if [[ -d "${custom_nodes_dir}/comfyui-manager" ]]; then
    echo "${TAB3}${TAB3}${TAB3}ComfyUI-Manager already exists. Skipping clone."
  else
    git clone https://github.com/ltdrdata/ComfyUI-Manager "${custom_nodes_dir}/comfyui-manager"
    # Install Manager dependencies with uv
    $STD uv pip install -r "/opt/${application_name}/comfyui-manager/requirements.txt" --python="/opt/${application_name}/venv/bin/python"
  fi

  echo
  echo "${TAB3}${TAB3}${TAB3}Please restart ComfyUI to activate the manager."
  echo
}

# Confirm configuration
confirm_configuration() {
  while true; do
    echo
    echo
    read -rp "${TAB3}${TAB3}${TAB3}Do you want to keep this configuration? [Y/n]: " CONFIG_CONFIRM
    CONFIG_CONFIRM=${CONFIG_CONFIRM:-y}

    case "$CONFIG_CONFIRM" in
      [Yy])
        echo "${TAB3}${TAB3}${TAB3}${TAB3}Current configuration accepted."
        break
        ;;
      [Nn])
        echo "${TAB3}${TAB3}${TAB3}${TAB3}Switching to advanced configuration..."
        break
        ;;
      *)
        echo "${TAB3}${TAB3}${TAB3}${TAB3}Please enter Y/y or N/n."
        ;;
    esac
  done
}

# Division line
division_line() {
  echo
  echo
  echo "${TAB3}=============================================================="
  echo
}

# Advanced configuration wrapper
advanced_config() {
  select_gpu_type
  division_line
  set_comfyui_version
  division_line
  set_python_version
  division_line
  set_port_number
  division_line
  set_comfyui_args
  division_line
  set_comfyui_manager
}

# Basic config
msg_info "${application_name} configuration"
division_line
select_gpu_type
# Advanced config loop until config_confirm_clean is "n"
while true; do
  division_line
  current_settings_info
  confirm_configuration
  division_line
  config_confirm_clean=${CONFIG_CONFIRM,,}

  if [[ "$config_confirm_clean" == "n" ]]; then
    advanced_config
  else
    break
  fi
done
msg_ok "${application_name} configuration"



# Current configuration variables
echo -e "${CM}${BOLD}${DGN}Application name    : ${BGN}${application_name}${CL}"
echo -e "${CM}${BOLD}${DGN}ComfyUI version     : ${BGN}${comfyui_version}${CL}"
echo -e "${CM}${BOLD}${DGN}GPU                 : ${BGN}${gpu_type}${CL}"
echo -e "${CM}${BOLD}${DGN}Python version (uv) : ${BGN}${python_version_uv}${CL}"
echo -e "${CM}${BOLD}${DGN}Port                : ${BGN}${port_arg}${CL}"
echo -e "${CM}${BOLD}${DGN}ComfyUI python args : ${BGN}${comfyui_python_args}${CL}"
echo -e "${CM}${BOLD}${DGN}ComfyUI Manager     : ${BGN}${comfyui_manager_enabled}${CL}"



# Installs uv
msg_info "Setup uv"
PYTHON_VERSION="${python_version_uv}" setup_uv
msg_ok "Setup uv"



# Comfy Version
msg_info "Setup ${application_name}"
if [[ "$comfyui_version" == "latest" ]]; then
  echo "Version is set to 'latest'; skipping version check."
  RELEASE=$(curl -fsSL https://api.github.com/repos/comfyanonymous/ComfyUI/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
else
  RELEASE="$comfyui_version"
fi
msg_ok "Setup ${application_name}"



# Comfy Release
msg_info "Installing ComfyUI version: ${RELEASE}"
curl -fsSL -o "${application_name}.zip" "https://github.com/comfyanonymous/ComfyUI/archive/refs/tags/${RELEASE}.zip"
unzip -q "${application_name}.zip"
# Remove v
CLEAN_RELEASE="${RELEASE//v/}"
# Move app to opt
mv "${application_name}-${CLEAN_RELEASE}/" "/opt/${application_name}"
echo "${RELEASE}" >/opt/"${application_name}"_version.txt
msg_ok "Installed ComfyUI version: ${RELEASE}"



# Dependencies
msg_info "Python dependencies"
$STD uv venv "/opt/${application_name}/venv"
if [[ "$gpu_type" == "NVIDIA" ]]; then
  echo "NVIDIA selected"
  $STD uv pip install \
      torch \
      torchvision \
      torchaudio \
      --extra-index-url https://download.pytorch.org/whl/cu128 \
      --python="/opt/${application_name}/venv/bin/python"
elif [[ "$gpu_type" == "AMD" ]]; then
  echo "AMD selected"
  $STD uv pip install \
      torch \
      torchvision \
      torchaudio \
      --index-url https://download.pytorch.org/whl/rocm6.3 \
      --python="/opt/${application_name}/venv/bin/python"
elif [[ "$gpu_type" == "Intel" ]]; then
  echo "Intel selected"
  $STD uv pip install \
      torch \
      torchvision \
      torchaudio \
      --index-url https://download.pytorch.org/whl/xpu \
      --python="/opt/${application_name}/venv/bin/python"
else
  echo "No GPU selected"
fi
$STD uv pip install -r "/opt/${application_name}/requirements.txt" --python="/opt/${application_name}/venv/bin/python"
msg_ok "Python dependencies"



# Comfyui manager installation
if [[ "${comfyui_manager_enabled}" == "y" ]]; then
  msg_info "Install ${application_name} Manager"
  install_comfyui_manager
  msg_ok "Installed ${application_name} Manager"
else
  msg_error "No installed ${application_name} Manager"
fi




# Creating Service
msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/"${application_name}".service
[Unit]
Description=${application_name} Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/${application_name}
ExecStart=/opt/${application_name}/venv/bin/python /opt/${application_name}/main.py --listen ${comfyui_python_port_args} ${comfyui_python_args}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now "${application_name}"
msg_ok "Created Service"

motd_ssh
customize



# Cleanup
msg_info "Cleaning up"
rm -f "${application_name}".zip
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"


