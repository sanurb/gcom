#!/usr/bin/env bash
set -euo pipefail

Color_Off='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Bold='\033[1m'

error() {
    echo -e "${Red}${Bold}Error:${Color_Off} $@" >&2
    exit 1
}

info() {
    echo -e "${Green}$@${Color_Off}"
}

warn() {
    echo -e "${Yellow}$@${Color_Off}"
}

if [[ ${OS:-} = "Windows_NT" ]]; then
    error "Please install using Windows Subsystem for Linux"
fi

GITHUB_REPO="https://github.com/sanurb/gcom/blob/main/gcom.sh"
INSTALL_DIR="$HOME/.local/bin"
EXECUTABLE_NAME="gcom"

if [[ ! -d "$INSTALL_DIR" ]]; then
    mkdir -p "$INSTALL_DIR"
fi

info "Downloading gcom from $GITHUB_REPO..."
curl -fsSL "$GITHUB_REPO" -o "${INSTALL_DIR}/${EXECUTABLE_NAME}.sh" || error "Failed to download gcom."

info "Setting executable permissions..."
chmod +x "${INSTALL_DIR}/${EXECUTABLE_NAME}.sh" || error "Failed to set executable permissions."

if ! command -v gcom &>/dev/null; then
    ln -sfnv "${INSTALL_DIR}/${EXECUTABLE_NAME}.sh" "${INSTALL_DIR}/${EXECUTABLE_NAME}" || warn "Failed to create symlink. Please manually add $INSTALL_DIR to your PATH."
fi

info "gcom has been installed successfully."
info "Type 'gcom' to start using it."
