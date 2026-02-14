# switchdesk  
Universal Desktop Environment Installer & Switcher (CLI)

`switchdesk` is a lightweight command‑line tool that installs and switches between desktop environments on any **systemd‑based Linux distribution**. It automatically detects your package manager, installs the desktop environment you choose, and switches to the correct display manager — all from a simple terminal command.

Ideal for minimal installations, netinstall ISOs, and users who want full control over their Linux environment.

---

## ✨ Features

- Detects installed desktop sessions  
- Installs popular desktop environments:
  - GNOME  
  - KDE Plasma  
  - XFCE  
  - Cinnamon  
  - MATE  
  - LXQt  
- Automatically switches to the correct display manager (GDM, SDDM, LightDM)  
- Works on:
  - Fedora / RHEL / CentOS (dnf)  
  - Ubuntu / Debian (apt)  
  - Arch Linux (pacman)  
  - openSUSE (zypper)  
- Pure CLI — no graphical tools required  
- Simple, predictable behavior  

---

## 🚀 Quick Install

Install switchdesk with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/zengmax68/switchdesk/main/installer.sh | bash


After installation:

sudo switchdesk status


---

📦 Manual Installation

git clone https://github.com/zengmax68/switchdesk.git
cd switchdesk
chmod +x switchdesk.sh
sudo mv switchdesk.sh /usr/local/bin/switchdesk


---

🧩 Usage

Check installed desktop sessions

sudo switchdesk status


Install a desktop environment

sudo switchdesk install kde


Supported values:
gnome, kde, xfce, cinnamon, mate, lxqt

Switch to a desktop environment

sudo switchdesk switch gnome


This updates the system’s display manager to match the selected desktop environment.

---

❌ Uninstall

Remove switchdesk using the uninstaller:

curl -fsSL https://raw.githubusercontent.com/zengmax68/switchdesk/main/uninstaller.sh | bash


Or manually:

sudo rm /usr/local/bin/switchdesk


---

📁 Project Structure

switchdesk/
├── switchdesk.sh
├── installer.sh
├── uninstaller.sh
└── README.md


---

📝 License

MIT License

---

💡 About

Created by zengmax68
A simple, universal tool for Linux users who want full control over their desktop environment.


---