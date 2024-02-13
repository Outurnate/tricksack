#!/bin/bash
python3 -m pip install --user gnureadline==8.1.2
python3 -m pip install --user netifaces==0.11.0

curl -L https://github.com/t3l3machus/Synergy-httpx/raw/main/synergy_httpx.py > ~/.local/bin/synergy_httpx
chmod +x ~/.local/bin/*