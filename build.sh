#!/bin/bash
OUTPUT=$HOME/paylods

rm $OUTPUT -rf

mkdir -p $OUTPUT/{lin,win}/{32,64,shell} $OUTPUT/win/msil/{2,3,4}
pushd src
DOCKER_BUILDKIT=1 docker build --build-arg docker_image=i386/alpine:latest --output type=local,dest=$OUTPUT/lin/32 .
DOCKER_BUILDKIT=1 docker build --build-arg docker_image=alpine:latest      --output type=local,dest=$OUTPUT/lin/64 .
popd

fetch() {
  wget -q --show-progress -O $1 $2
}

pushd $OUTPUT/lin/64 > /dev/null
fetch pwnkit https://github.com/ly4k/PwnKit/raw/main/PwnKit
fetch linpeas https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
popd > /dev/null

pushd $OUTPUT/lin/32 > /dev/null
fetch pwnkit https://github.com/ly4k/PwnKit/raw/main/PwnKit32
fetch linpeas https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_386
popd > /dev/null

pushd $OUTPUT/lin/shell > /dev/null
fetch linpeas.sh https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
popd > /dev/null

pushd $OUTPUT/win/64 > /dev/null
fetch winpeas.exe https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
fetch mimidrv.sys https://github.com/ParrotSec/mimikatz/raw/master/x64/mimidrv.sys
fetch mimikatz.exe https://github.com/ParrotSec/mimikatz/raw/master/x64/mimikatz.exe
fetch mimilib.dll https://github.com/ParrotSec/mimikatz/raw/master/x64/mimilib.dll
popd > /dev/null

pushd $OUTPUT/win/32 > /dev/null
fetch winpeas.exe https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
fetch mimidrv.exe https://github.com/ParrotSec/mimikatz/raw/master/Win32/mimidrv.sys
fetch mimikatz.exe https://github.com/ParrotSec/mimikatz/raw/master/Win32/mimikatz.exe
fetch mimilib.dll https://github.com/ParrotSec/mimikatz/raw/master/Win32/mimilib.dll
popd > /dev/null

pushd $OUTPUT/win/shell > /dev/null
fetch winpeas.bat https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
fetch powerview.ps1 https://github.com/PowerShellMafia/PowerSploit/raw/master/Recon/PowerView.ps1
fetch powerup.ps1 https://github.com/PowerShellMafia/PowerSploit/raw/master/Privesc/PowerUp.ps1
popd > /dev/null

pushd $OUTPUT/win/msil/2 > /dev/null
fetch godpotato.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET2.exe
popd > /dev/null

pushd $OUTPUT/win/msil/3 > /dev/null
fetch godpotato.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET35.exe
fetch rubeus.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v3.5%20compiled%20binaries/Rubeus.exe
fetch seatbelt.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v3.5%20compiled%20binaries/Seatbelt.exe
popd > /dev/null

pushd $OUTPUT/win/msil/4 > /dev/null
fetch godpotato.exe https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe
fetch rubeus.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v4.5%20compiled%20binaries/Rubeus.exe
fetch seatbelt.exe https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/dotnet%20v4.5%20compiled%20binaries/Seatbelt.exe
popd > /dev/null

cp src/PwnKit.sh $OUTPUT/lin/shell/pwnkit.sh
cp src/gameoverlay.sh $OUTPUT/lin/shell/gameoverlay.sh

chmod -R +x $OUTPUT/lin

for ARCH in 64 32
do
  for PLATFORM in lin win
  do
    for f in $(ls $OUTPUT/$PLATFORM/shell)
    do
      ln -T $OUTPUT/$PLATFORM/shell/$f $OUTPUT/$PLATFORM/$ARCH/$f
    done
  done

  for VERSION in 2 3 4
  do
    for f in $(ls $OUTPUT/win/msil/$VERSION/*.exe)
    do
      ln -T $OUTPUT/win/msil/$VERSION/$(basename "$f") $OUTPUT/win/$ARCH/$(basename "$f" .exe)-msil$VERSION.exe
    done
  done

  cd $OUTPUT/lin/$ARCH && tar -zcf $OUTPUT/lin$ARCH.tar.gz *
  zip -j $OUTPUT/win$ARCH.zip $OUTPUT/win/$ARCH/*
done

tree $OUTPUT -h
du -hd0 $OUTPUT