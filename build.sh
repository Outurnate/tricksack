#!/bin/bash
OUTPUT=/srv/http

rm "${OUTPUT:?}"/* -rf

mkdir -p $OUTPUT/{lin,win}/{32,64,shell} $OUTPUT/win/msil/{2,3,4}
pushd src || exit
DOCKER_BUILDKIT=1 docker build --build-arg docker_image=i386/alpine:latest --output type=local,dest=$OUTPUT/lin/32 .
DOCKER_BUILDKIT=1 docker build --build-arg docker_image=alpine:latest      --output type=local,dest=$OUTPUT/lin/64 .
popd || exit

fetch() {
  wget -q --show-progress -O "$1" "$2"
}

fetch_from_zip() {
  TMPFILE=$(mktemp)
  fetch "$TMPFILE" "$2"
  unzip -p "$TMPFILE" "$3" > "$1"
  rm "$TMPFILE"
}

pushd $OUTPUT/lin/64 > /dev/null || exit
fetch pwnkit https://github.com/ly4k/PwnKit/raw/main/PwnKit
fetch linpeas https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
popd > /dev/null || exit

pushd $OUTPUT/lin/32 > /dev/null || exit
fetch pwnkit https://github.com/ly4k/PwnKit/raw/main/PwnKit32
fetch linpeas https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_386
popd > /dev/null || exit

pushd $OUTPUT/lin/shell > /dev/null || exit
fetch linpeas.sh https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
popd > /dev/null || exit

pushd $OUTPUT/win/64 > /dev/null || exit
fetch winpeas.exe https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
fetch mimikatz.exe "https://gitlab.com/kalilinux/packages/mimikatz/-/raw/kali/master/x64/mimikatz.exe?ref_type=heads&inline=false"
fetch_from_zip psexec.exe https://download.sysinternals.com/files/PSTools.zip PsExec64.exe
fetch_from_zip ligolo.exe https://github.com/nicocha30/ligolo-ng/releases/download/v0.5.2/ligolo-ng_agent_0.5.2_windows_amd64.zip agent.exe
popd > /dev/null || exit

pushd $OUTPUT/win/32 > /dev/null || exit
fetch winpeas.exe https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
fetch mimikatz.exe "https://gitlab.com/kalilinux/packages/mimikatz/-/raw/kali/master/Win32/mimikatz.exe?ref_type=heads&inline=false"
fetch_from_zip psexec.exe https://download.sysinternals.com/files/PSTools.zip PsExec.exe
popd > /dev/null || exit

pushd $OUTPUT/win/shell > /dev/null || exit
fetch winpeas.bat https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
fetch powerview.ps1 https://github.com/PowerShellMafia/PowerSploit/raw/master/Recon/PowerView.ps1
fetch powerup.ps1 https://github.com/PowerShellMafia/PowerSploit/raw/master/Privesc/PowerUp.ps1
fetch powercat.ps1 https://github.com/besimorhino/powercat/raw/master/powercat.ps1
popd > /dev/null || exit

pushd $OUTPUT/win/msil/2 > /dev/null || exit
fetch godpotato.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET2.exe
popd > /dev/null || exit

pushd $OUTPUT/win/msil/3 > /dev/null || exit
fetch godpotato.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET35.exe
fetch rubeus.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v3.5%20compiled%20binaries/Rubeus.exe
fetch seatbelt.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v3.5%20compiled%20binaries/Seatbelt.exe
popd > /dev/null || exit

pushd $OUTPUT/win/msil/4 > /dev/null || exit
fetch godpotato.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe
fetch rubeus.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v4.5%20compiled%20binaries/Rubeus.exe
fetch seatbelt.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v4.5%20compiled%20binaries/Seatbelt.exe
popd > /dev/null || exit

cp src/PwnKit.sh $OUTPUT/lin/shell/pwnkit.sh
cp src/gameoverlay.sh $OUTPUT/lin/shell/gameoverlay.sh
cp /usr/lib/bloodhound/resources/app/Collectors/SharpHound.ps1 $OUTPUT/win/shell/sharphound.ps1

chmod -R +x $OUTPUT/lin

for ARCH in 64 32
do
  for PLATFORM in lin win
  do
    for f in "$OUTPUT"/"$PLATFORM"/shell/*
    do
      ln -T "$f" "$OUTPUT/$PLATFORM/$ARCH/$(basename "$f")"
    done
  done

  for VERSION in 2 3 4
  do
    for f in "$OUTPUT"/win/msil/"$VERSION"/*.exe
    do
      ln -T "$f" "$OUTPUT/win/$ARCH/$(basename "$f" .exe)-msil$VERSION.exe"
    done
  done

  cd $OUTPUT/lin/$ARCH && tar -zcf $OUTPUT/lin$ARCH.tar.gz ./*
  zip -j $OUTPUT/win$ARCH.zip $OUTPUT/win/$ARCH/*
done

tree $OUTPUT -h
du -hd0 $OUTPUT