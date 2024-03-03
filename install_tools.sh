#!/bin/bash
TMPFILE=$(mktemp)
curl -L https://www.nirsoft.net/utils/nircmd.zip > "$TMPFILE"
unzip -p "$TMPFILE" nircmd.exe > ~/.local/bin/nircmd.exe
rm "$TMPFILE"

curl -L https://github.com/internetwache/GitTools/raw/master/Dumper/gitdumper.sh > ~/.local/bin/gitdumper
curl -L http://www.mamachine.org/mslink/mslink_v1.3.sh -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0" > ~/.local/bin/mslink
chmod +x ~/.local/bin/*