#!/bin/bash

# INSTALL MIRRORLIST AND KEYRINGS

echo 'allow-weak-key-signatures' >> /etc/pacman.d/gnupg/gpg.conf
pacman-key --init
pacman --noconfirm -U 'https://www.blackarch.org/keyring/blackarch-keyring.pkg.tar.xz'
pacman-key --populate
curl -s "https://blackarch.org/blackarch-mirrorlist" -o "/etc/pacman.d/blackarch-mirrorlist"
cat >> "/etc/pacman.conf" << EOF
[blackarch]
Include = /etc/pacman.d/blackarch-mirrorlist
EOF

# INSTALL ALL PACKAGES

pacman --noconfirm -Syyu - < packages.txt
useradd --create-home --btrfs-subvolume --home-dir /opt/aur --system aur
groupadd --system --users aur root_equiv
echo "%root_equiv ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00_root_equiv
sudo --user aur /bin/bash -c "RUSTUP_TOOLCHAIN=stable cargo install --force rua"
sudo --user aur /opt/aur/.cargo/bin/rua install $(xargs < /root/aur.txt)

# CONFIGURE THE SYSTEM

systemctl enable sddm.service nginx.service sshd.service docker.socket
setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip /usr/bin/nmap
cp nginx.conf /etc/nginx/nginx.conf
wordlistctl fetch \* -g usernames passwords discovery fuzzing misc
mkdir -p /srv/{webdav,http,upload}
chown -R http:http /srv/upload