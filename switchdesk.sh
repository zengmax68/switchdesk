#!/usr/bin/env bash
#
# switchdesk - Universal Desktop Environment Installer & Switcher
# Author: zengmax68
# Works on systemd-based distros with dnf/apt/pacman/zypper.
#

set -e

# -----------------------------
# Colours
# -----------------------------
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

log() { echo -e "${BLUE}[switchdesk]${RESET} $1"; }
ok()  { echo -e "${GREEN}[OK]${RESET} $1"; }
warn(){ echo -e "${YELLOW}[WARN]${RESET} $1"; }
err() { echo -e "${RED}[ERROR]${RESET} $1"; }

# -----------------------------
# Root check
# -----------------------------
require_root() {
    if [ "$EUID" -ne 0 ]; then
        err "Please run as root (use sudo)."
        exit 1
    fi
}

# -----------------------------
# Detect package manager
# -----------------------------
detect_pkg_manager() {
    if command -v dnf >/dev/null 2>&1; then
        PKG_MGR="dnf"
    elif command -v apt >/dev/null 2>&1; then
        PKG_MGR="apt"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MGR="pacman"
    elif command -v zypper >/dev/null 2>&1; then
        PKG_MGR="zypper"
    else
        err "Unsupported distro: no known package manager found."
        exit 1
    fi
}

# -----------------------------
# Install a desktop environment
# -----------------------------
install_de() {
    local de="$1"
    log "Installing desktop environment: $de"

    case "$PKG_MGR" in
        dnf)
            case "$de" in
                gnome)    dnf groupinstall -y "GNOME Desktop Environment" ;;
                kde)      dnf groupinstall -y "KDE Plasma Workspaces" ;;
                xfce)     dnf groupinstall -y "Xfce Desktop" ;;
                cinnamon) dnf groupinstall -y "Cinnamon Desktop" ;;
                mate)     dnf groupinstall -y "MATE Desktop" ;;
                lxqt)     dnf groupinstall -y "LXQt Desktop" ;;
                *) err "Unknown DE: $de"; exit 1 ;;
            esac
            ;;
        apt)
            apt update
            case "$de" in
                gnome)    apt install -y ubuntu-desktop || apt install -y gnome-shell ;;
                kde)      apt install -y kde-standard ;;
                xfce)     apt install -y xfce4 ;;
                cinnamon) apt install -y cinnamon ;;
                mate)     apt install -y mate-desktop-environment ;;
                lxqt)     apt install -y lxqt ;;
                *) err "Unknown DE: $de"; exit 1 ;;
            esac
            ;;
        pacman)
            case "$de" in
                gnome)    pacman -Syu --noconfirm gnome gnome-extra ;;
                kde)      pacman -Syu --noconfirm plasma kde-applications ;;
                xfce)     pacman -Syu --noconfirm xfce4 xfce4-goodies ;;
                cinnamon) pacman -Syu --noconfirm cinnamon ;;
                mate)     pacman -Syu --noconfirm mate mate-extra ;;
                lxqt)     pacman -Syu --noconfirm lxqt ;;
                *) err "Unknown DE: $de"; exit 1 ;;
            esac
            ;;
        zypper)
            case "$de" in
                gnome)    zypper install -t pattern gnome ;;
                kde)      zypper install -t pattern kde ;;
                xfce)     zypper install -t pattern xfce ;;
                cinnamon) zypper install cinnamon ;;
                mate)     zypper install mate-desktop ;;
                lxqt)     zypper install lxqt ;;
                *) err "Unknown DE: $de"; exit 1 ;;
            esac
            ;;
    esac

    ok "Install complete for: $de"
}

# -----------------------------
# Detect installed sessions
# -----------------------------
detect_installed_des() {
    log "Detected desktop sessions:"
    if [ -d /usr/share/xsessions ]; then
        ls /usr/share/xsessions | sed 's/\.desktop$//' | sed 's/^/- /'
    fi
    if [ -d /usr/share/wayland-sessions ]; then
        ls /usr/share/wayland-sessions | sed 's/\.desktop$//' | sed 's/^/- /'
    fi
}

# -----------------------------
# Detect installed display managers
# -----------------------------
detect_installed_dm() {
    log "Detected installed display managers:"
    for dm in gdm sddm lightdm; do
        if command -v "$dm" >/dev/null 2>&1; then
            echo "- $dm"
        fi
    done
}

# -----------------------------
# Switch display manager
# -----------------------------
switch_dm_for_de() {
    local de="$1"
    local target_dm=""

    case "$de" in
        gnome) target_dm="gdm" ;;
        kde)   target_dm="sddm" ;;
        xfce|cinnamon|mate|lxqt)
            if command -v lightdm >/dev/null 2>&1; then
                target_dm="lightdm"
            else
                warn "LightDM not installed. Installing..."
                case "$PKG_MGR" in
                    apt) apt install -y lightdm ;;
                    dnf) dnf install -y lightdm ;;
                    pacman) pacman -Syu --noconfirm lightdm ;;
                    zypper) zypper install -y lightdm ;;
                esac
                target_dm="lightdm"
            fi
            ;;
        *)
            err "Unknown DE: $de"
            exit 1
            ;;
    esac

    log "Switching display manager to: $target_dm"

    for dm in gdm sddm lightdm; do
        systemctl disable "$dm" >/dev/null 2>&1 || true
    done

    systemctl enable "$target_dm" >/dev/null 2>&1
    systemctl set-default graphical.target >/dev/null 2>&1

    ok "Display manager switched to $target_dm"
}

# -----------------------------
# Status
# -----------------------------
show_status() {
    echo -e "${BLUE}=== Desktop Sessions ===${RESET}"
    detect_installed_des
    echo

    echo -e "${BLUE}=== Display Managers ===${RESET}"
    detect_installed_dm
    echo

    echo -e "${BLUE}=== Active Display Manager ===${RESET}"
    systemctl status display-manager | grep -E 'Loaded:|Active:' || warn "No active display manager detected."
}

# -----------------------------
# Help
# -----------------------------
usage() {
cat <<EOF
switchdesk - Universal Desktop Environment Manager

Usage:
  switchdesk status
  switchdesk install <de>
  switchdesk switch <de>
  switchdesk --version
  switchdesk --help

Supported desktop environments:
  gnome, kde, xfce, cinnamon, mate, lxqt
EOF
}

# -----------------------------
# Main
# -----------------------------
main() {
    require_root
    detect_pkg_manager

    case "$1" in
        status) show_status ;;
        install) install_de "$2" ;;
        switch) switch_dm_for_de "$2" ;;
        --version) echo "switchdesk v1.0 by zengmax68" ;;
        --help|"") usage ;;
        *) usage ;;
    esac
}

main "$@"
