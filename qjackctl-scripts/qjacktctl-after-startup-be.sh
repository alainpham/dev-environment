#!/bin/sh
pactl load-module module-jack-source client_name=from-jack-mic1-to-pulse channels=2 connect=0
pactl load-module module-jack-source client_name=from-jack-for-pulse-caller channels=2 connect=0
pactl load-module module-jack-source client_name=to-obs-mic1 channels=1 connect=0
pactl load-module module-jack-source client_name=to-obs-mic2 channels=1 connect=0
pactl load-module module-jack-source client_name=to-obs-desktop channels=2 connect=0
pactl load-module module-jack-source client_name=to-obs-caller channels=2 connect=0
pactl load-module module-jack-source client_name=pulse-vis channels=2 connect=0
pactl load-module module-jack-sink sink_name=from-pulse-caller-to-jack client_name=from-pulse-caller-to-jack channels=2 connect=0
pactl load-module module-jack-sink sink_name=from-pulse-desktop-to-jack client_name=from-pulse-desktop-to-jack channels=2 connect=0
pacmd set-default-sink from-pulse-desktop-to-jack
pacmd set-default-source from-jack-mic1-to-pulse
# nohup alsa_out -dhw:dock -j'speaker' -p2048 -n4 &
#nohup alsa_out -dhw:Speaker -j'speaker' -p1024 -n4 &
 #nohup zita-j2a -S  -r 48000 -p 1024 -d hw:Speaker >/dev/null 2>&1 &
 #nohup zita-j2a -S  -r 48000 -p 1024 -d hw:dockr >/dev/null 2>&1 &
#nohup zita-j2a -S  -r 48000 -p 2048 -d hw:sofhdadsp  >/dev/null 2>&1 &
sleep 4
nohup ardour /home/workdrive/tazone/dev-environment/ardour-project/headset/live-audio>/dev/null 2>&1 &
