#!/usr/bin/env bash
#
# switchdesk - Universal Desktop Environment Installer & Switcher
# Works on systemd-based distros with dnf/apt/pacman/zypper.
#
# Features:
#   - Detect installed desktop sessions
#   - Install common DEs (GNOME, KDE, XFCE, Cinnamon, MATE, LXQt)
#   - Switch display manager to match target DE

set -e

require_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root (use sudo)."
        exit 1
    fi
}

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
        echo "Unsupported distro: no known package manager found."
        exit 1
    fi
}

install_de() {
    local de="$1"
    echo "Installing desktop environment: $de"
    echo

    case "$PKG_MGR" in
        dnf)
            case "$de" in
                gnome)    dnf groupinstall -y "GNOME Desktop Environment" ;;
                kde)      dnf groupinstall -y "KDE Plasma Workspaces" ;;
                xfce)     dnf groupinstall -y "Xfce Desktop" ;;
                cinnamon) dnf groupinstall -y "Cinnamon Desktop" ;;
                mate)     dnf groupinstall -y "MATE Desktop" ;;
                lxqt)     dnf groupinstall -y "LXQt Desktop" ;;
                *) echo "Unknown DE: $de"; exit 1 ;;
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
                *) echo "Unknown DE: $de"; exit 1 ;;
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
                *) echo "Unknown DE: $de"; exit 1 ;;
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
                *) echo "Unknown DE: $de"; exit 1 ;;
            esac
            ;;
    esac

    echo
    echo "Install complete for: $de"
}

detect_installed_des() {
    echo "Detected desktop sessions:"
    if [ -d /usr/share/xsessions ]; then
        ls /usr/share/xsessions | sed 's/\.desktop$//' | sed 's/^/- /'
    fi
    if [ -d /usr/share/wayland-sessions ]; then
        ls /usr/share/wayland-sessions | sed 's/\.desktop$//' | sed 's/^/- /'
    fi
}

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
                echo "No dedicated DM chosen for $de; keeping current display manager."
                return
            fi
            ;;
        *)
            echo "Unknown DE for DM switch: $de"
            return
            ;;
    esac

    echo "Switching display manager to: $target_dm"
    echo

    # Disable common DMs
    for dm in gdm sddm lightdm; do
        if systemctl is-enabled "$dm" >/dev/null 2>&1; then
            systemctl disable "$dm" >/dev/null 2>&1 || true
        fi
    done

    systemctl enable "$target_dm" >/dev/null 2>&1 || {
        echo "Failed to enable $target_dm. Is it installed?"
        exit 1
    }

    systemctl set-default graphical.target >/dev/null 2>&1 || true

    echo "Desktop switched, please save your work and reboot."
    echo
    read -p "Reboot now? [y/n] " answer

    case "$answer" in
        [Yy]* )
            echo "Rebooting"
            sleep 1
            reboot
            ;;
        * )
            echo "Okay. Please reboot later to apply the changes."
            ;;
    esac
}

show_status() {
    echo "=== Desktop Sessions ==="
    detect_installed_des
    echo
    echo "=== Display Manager ==="
    if systemctl status display-manager >/dev/null 2>&1; then
        systemctl status display-manager | grep -E 'Loaded:|Active:'
    else
        echo "No active display-manager service detected."
    fi
}

usage() {
    cat <<EOF
switchdesk - Universal Desktop Environment Manager

Usage:
  switchdesk status
      Show installed desktop sessions and display manager status.

  switchdesk install <de>
      Install a desktop environment.
      Supported: gnome, kde, xfce, cinnamon, mate, lxqt

  switchdesk switch <de>
      Switch display manager to match the target DE.
      Prompts for reboot.
      Supported: gnome, kde, xfce, cinnamon, mate, lxqt

Examples:
  sudo switchdesk status
  sudo switchdesk install kde
  sudo switchdesk switch kde

EOF
}

main() {
    require_root
    detect_pkg_manager

    case "$1" in
        status)
            show_status
            ;;
        install)
            [ -z "$2" ] && usage && exit 1
            install_de "$2"
            ;;
        switch)
            [ -z "$2" ] && usage && exit 1
            switch_dm_for_de "$2"
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
