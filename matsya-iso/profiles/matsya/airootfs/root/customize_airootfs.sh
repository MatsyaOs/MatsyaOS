#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# nsswitch.conf settings
# * Avahi : add 'mdns_minimal'
# * Winbind : add 'wins'
sed -i '/^hosts:/ {
        s/\(resolve\)/mdns_minimal \[NOTFOUND=return\] \1/
        s/\(dns\)$/\1 wins/ }' /etc/nsswitch.conf

# Nvidia/Optimus display setup
if [ -f /etc/lightdm/lightdm.conf ] && grep -q 'nvidia' /version 2>/dev/null; then
    sed -i 's|^#\(display-setup-script=\)$|\1/etc/lightdm/display_setup.sh|' /etc/lightdm/lightdm.conf
elif grep -q 'optimus' /version 2>/dev/null; then
    rm -f /etc/lightdm/display_setup.sh
else
    rm -f /etc/lightdm/display_setup.sh /etc/modprobe.d/nvidia-drm.conf
fi

# Lightdm display-manager
# * live user autologin
# * Matsya theme
# * background color
if [ -f /etc/lightdm/lightdm.conf ]; then
    sed -i 's/^#\(autologin-user=\)$/\1live/
            s/^#\(autologin-session=\)$/\1matsya-xsession/' /etc/lightdm/lightdm.conf
fi
if [ -f /etc/lightdm/lightdm-gtk-greeter.conf ]; then
    sed -i 's/^#\(background=\)$/\1#1a1a2e/
            s/^#\(theme-name-\)$/\1Matsya/
            s/^#\(icon-theme-name=\)$/\1Matsya/' /etc/lightdm/lightdm-gtk-greeter.conf
fi

# Enable service when available
{ [[ -e /usr/lib/systemd/system/acpid.service                ]] && systemctl enable acpid.service;
  [[ -e /usr/lib/systemd/system/avahi-dnsconfd.service       ]] && systemctl enable avahi-dnsconfd.service;
  [[ -e /usr/lib/systemd/system/bluetooth.service            ]] && systemctl enable bluetooth.service;
  [[ -e /usr/lib/systemd/system/NetworkManager.service       ]] && systemctl enable NetworkManager.service;
  [[ -e /usr/lib/systemd/system/nmb.service                  ]] && systemctl enable nmb.service;
  [[ -e /usr/lib/systemd/system/cups.service                 ]] && systemctl enable cups.service;
  [[ -e /usr/lib/systemd/system/smb.service                  ]] && systemctl enable smb.service;
  [[ -e /usr/lib/systemd/system/systemd-timesyncd.service    ]] && systemctl enable systemd-timesyncd.service;
  [[ -e /usr/lib/systemd/system/winbind.service              ]] && systemctl enable winbind.service;
} > /dev/null 2>&1

# Set display-manager (sddm or lightdm)
if [ -f /usr/lib/systemd/system/sddm.service ]; then
    systemctl enable sddm.service
    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=live
Session=matsya-xsession

[Theme]
Current=matsya
EOF
elif [ -f /usr/lib/systemd/system/lightdm.service ]; then
    ln -s /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service || true
fi

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G 'wheel' -s /bin/zsh live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers

# Create autologin group
# add live to autologin group
groupadd -r autologin
gpasswd -a live autologin

# Update schemas
glib-compile-schemas /usr/share/glib-2.0/schemas/

# Default background fix
mkdir -p /usr/share/backgrounds
ln -sf /usr/share/sources/1.png /usr/share/backgrounds/default_background.jpg || true

# disable systemd-networkd.service
# we have NetworkManager for managing network interfaces
[[ -e /etc/systemd/system/multi-user.target.wants/systemd-networkd.service ]] && rm /etc/systemd/system/multi-user.target.wants/systemd-networkd.service
[[ -e /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service ]] && rm /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
[[ -e /etc/systemd/system/sockets.target.wants/systemd-networkd.socket ]] && rm /etc/systemd/system/sockets.target.wants/systemd-networkd.socket
