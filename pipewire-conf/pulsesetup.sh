#!/bin/bash

#######################
## Microphone choice ##
#######################

mics=($(pacmd list-sources | grep -oP 'name: <\K[^>]+' | grep -E 'alsa_input|bluez_source'))

nb_mics=${#mics[@]}


while [[ $choosen_mic_index != +([0-9]) ]] || [[ $choosen_mic_index < 0 ]] || [[ ${choosen_mic_index} -ge ${nb_mics} ]]  ; do
    echo Choose your mic
    
    for i in "${!mics[@]}"; do 
        printf "%s\t%s\n" "$i" "${mics[$i]}"
    done

    read choosen_mic_index
    echo index choosen $choosen_mic_index
done

mic=${mics[$choosen_mic_index]}

echo your chosen mic $mic

#######################
## Speaker choice    ##
#######################

speakers=($(pacmd list-sinks | grep -oP 'name: <\K[^>]+'| grep -E 'alsa_output|bluez_sink'))

nb_speakers=${#speakers[@]}

while [[ $choosen_speaker_index != +([0-9]) ]] || [[ $choosen_speaker_index < 0 ]] || [[ ${choosen_speaker_index} -ge ${nb_speakers} ]]  ; do
    echo Choose your speaker
    
    for i in "${!speakers[@]}"; do 
        printf "%s\t%s\n" "$i" "${speakers[$i]}"
    done

    read choosen_speaker_index
    echo index choosen $choosen_speaker_index
done

speaker=${speakers[$choosen_speaker_index]}

echo your chosen speaker $speaker

pulseaudio -k
# audio sink from desktop
# pactl load-module module-null-sink sink_name=from-desktop sink_properties=device.description="from-desktop">>/tmp/pulsemodule.log
# pacmd set-default-sink from-desktop

# audio sink from caller
# pactl load-module module-null-sink sink_name=from-caller sink_properties=device.description="from-caller">>/tmp/pulsemodule.log

# audio sink mix to caller
# pactl load-module module-null-sink sink_name=to-caller-sink sink_properties=device.description="to-caller-sink">>/tmp/pulsemodule.log
# pactl load-module module-remap-source  source_name=to-caller master=to-caller-sink.monitor source_properties=device.description="to-caller"

# pacmd set-default-source to-caller

# connect from-desktop to to-caller-sink
# pactl load-module module-loopback adjust_time=0 format=s16le rate=48000 channels=2 remix=false source=from-desktop.monitor sink=to-caller-sink latency_msec=50 source_dont_move=true sink_dont_move=true >> /tmp/pulsemodule.log

### CONNECT PHYSICAL DEVICES

# connect from-desktop to speakers
pactl load-module module-loopback adjust_time=0 format=s16le rate=48000 channels=2 remix=false source="from-desktop.monitor" sink="${speaker}" latency_msec=40 >>/tmp/pulsemodule.log

# connect from-caller to speakers
pactl load-module module-loopback adjust_time=0 format=s16le rate=48000 channels=2 remix=false  source="from-caller.monitor" sink="${speaker}" latency_msec=40>>/tmp/pulsemodule.log

# split mic into 2
pactl load-module module-remap-source source_name=mic01-processed master=${mic} master_channel_map="front-left" channel_map="mono" source_properties=device.description="mic01-processed"
pactl load-module module-remap-source source_name=mic02-processed master=${mic} master_channel_map="front-right" channel_map="mono" source_properties=device.description="mic02-processed"
pactl load-module module-remap-source source_name=mics-raw master=${mic} source_properties=device.description="mics-raw"

# connect microphone to to-caller-sink

pactl load-module module-loopback adjust_time=0 format=s16le rate=48000  remix=true source="mic01-processed" sink=to-caller-sink latency_msec=40 source_dont_move=true sink_dont_move=true  >> /tmp/pulsemodule.log
pactl load-module module-loopback adjust_time=0 format=s16le rate=48000  remix=true source="mic02-processed" sink=to-caller-sink latency_msec=40 source_dont_move=true sink_dont_move=true  >> /tmp/pulsemodule.log

# set proper mic volume
pactl set-source-volume mic01-processed 120%
pactl set-source-volume mic02-processed 0%
pactl set-sink-volume from-desktop 95%
pactl set-sink-volume from-caller 95%
