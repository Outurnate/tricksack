# syntax=docker/dockerfile:latest
ARG docker_image
FROM ${docker_image}
RUN apk add --no-cache alpine-sdk perl go linux-headers curl

RUN <<EOF
# GET SOURCES
set -eux

mkdir -p /sources

curl -L https://github.com/jpillora/chisel/archive/refs/tags/v1.9.1.tar.gz | tar -xzf - -C /sources
curl -L https://invisible-island.net/datafiles/release/ncurses.tar.gz | tar -xzf - -C /sources
curl -L https://ftp.gnu.org/pub/gnu/readline/readline-8.2.tar.gz | tar -xzf - -C /sources
curl -L https://www.openssl.org/source/openssl-3.2.0.tar.gz | tar -xzf - -C /sources
curl -L http://www.dest-unreach.org/socat/download/socat-1.8.0.0.tar.gz | tar -xzf - -C /sources
curl -L http://zlib.net/zlib-1.3.1.tar.gz | tar -xzf - -C /sources
curl -L https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.6p1.tar.gz | tar -xzf - -C /sources
curl -L https://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.gz/download | tar -xzf - -C /sources
curl -L https://github.com/DominicBreuker/pspy/archive/refs/tags/v1.2.1.tar.gz | tar -xzf - -C /sources
curl -L https://github.com/nicocha30/ligolo-ng/archive/refs/tags/v0.5.1.tar.gz | tar -xzf - -C /sources

ln -sT /sources/chisel-1.9.1 /sources/chisel
ln -sT /sources/ncurses-6.3 /sources/ncurses
ln -sT /sources/readline-8.2 /sources/readline
ln -sT /sources/openssl-3.2.0 /sources/openssl
ln -sT /sources/socat-1.8.0.0 /sources/socat
ln -sT /sources/zlib-1.3.1 /sources/zlib
ln -sT /sources/openssh-9.6p1 /sources/openssh
ln -sT /sources/netcat-0.7.1 /sources/netcat
ln -sT /sources/pspy-1.2.1 /sources/pspy
ln -sT /sources/ligolo-ng-0.5.1 /sources/ligolo

EOF

RUN <<EOF
# NCURSES
set -eux

cd /sources/ncurses
CFLAGS="-fPIC -static" ./configure --disable-shared --enable-static
make -j24

EOF

RUN <<EOF
# READLINE
set -eux

cd /sources/readline
CFLAGS="-fPIC -static" ./configure --disable-shared --enable-static
make -j24

EOF

RUN <<EOF
# ZLIB
set -eux

cd /sources/zlib
CC="gcc -static -fPIC" ./configure --static
make -j24

EOF

RUN <<EOF
# OPENSSL
set -eux

cd /sources/openssl
if [ "$(cat /etc/apk/arch)" = "x86" ]
then
  export OPENSSL_ARCH="linux-generic32"
else
  export OPENSSL_ARCH="linux-generic64"
fi
CC="gcc -static" ./Configure $OPENSSL_ARCH no-shared no-async no-module no-comp no-zlib enable-ssl2 enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers enable-des -DOPENSSL_TLS_SECURITY_LEVEL=0 --with-zlib-include=/sources/zlib --with-zlib-lib=/sources/zlib -fPIC
make -j24

EOF

RUN <<EOF
# SOCAT
set -eux

cd /sources/socat
CFLAGS="-fPIC -static -flto" CPPFLAGS="-I/sources -I/sources/openssl/include -DNETDB_INTERNAL=-1 -static -flto" LDFLAGS="-L/sources/readline -L/sources/ncurses/lib -L/sources/openssl -static -flto" ./configure
make -j24

EOF

RUN <<EOF
# OPENSSH
set -eux

cd /sources/openssh
CFLAGS="-static -flto" CPPFLAGS="-I/sources/openssl/include -I/sources/zlib -static -flto" LDFLAGS="-L/sources/openssl -L/sources/zlib -static -flto" ./configure
make -j24

EOF

RUN <<EOF
# NETCAT
set -eux

cd /sources/netcat
CFLAGS="-flto" CPPFLAGS="-flto" CXXFLAGS="-flto" LDFLAGS="-static -flto" DFLAGS="-DGAPING_SECURITY_HOLE -DTELNET" ./configure
make -j24

EOF

RUN <<EOF
# CHISEL
set -eux

cd /sources/chisel
CGO_ENABLED=1 go build --ldflags '-linkmode external -extldflags "-static"'

EOF

RUN <<EOF
# PSPY
set -eux

cd /sources/pspy
CGO_ENABLED=1 go build --ldflags '-linkmode external -extldflags "-static"'

EOF

RUN <<EOF
# LIGOLO
set -eux

cd /sources/ligolo
go build --ldflags '-linkmode external -extldflags "-static"' -o ligolo cmd/agent/main.go

EOF

RUN <<EOF
# INSTALL
set -eux

mkdir -p /output
cp /sources/chisel/chisel /output
cp /sources/socat/socat /output
cp /sources/openssl/apps/openssl /output
cp /sources/openssh/ssh /output
cp /sources/netcat/src/netcat /output
cp /sources/pspy/pspy /output
cp /sources/ligolo/ligolo /output
strip /output/*

EOF

FROM scratch
COPY --from=0 /output/* /