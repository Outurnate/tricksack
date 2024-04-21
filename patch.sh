#/bin/bash
for tool in $(pacman -Ql impacket | cut -d' ' -f2 | grep "/usr/bin/." | sed -e "s/\/usr\/bin\///g" -e "s/\.py//g")
do
  ln -sT /usr/bin/$tool.py /usr/bin/impacket-$tool
done
echo "net.ipv4.ip_unprivileged_port_start=0" > /etc/sysctl.d/00-low-ports.conf
echo "fs.file-max=500000" > /etc/sysctl.d/00-file-limit.conf
echo "* soft nofile 500000" > /etc/security/limits.conf
echo "* hard nofile 500000" >> /etc/security/limits.conf
tar xvf /usr/share/wordlists/passwords/rockyou.txt.tar.gz -C /usr/share/wordlists/passwords/