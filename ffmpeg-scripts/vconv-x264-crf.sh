#!/bin/bash
extension="${1##*.}"
filename="${1%.*}"
#1080p 4000k
#720p  2264k
crf=${2:-17}
ab=${3:-384}
format=${4:-mp4}

echo "ffmpeg -y -i $1 -preset veryslow -pix_fmt yuv420p -c:v libx264 -b:v ${bitrate}k -x264-params cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -an -pass 1 -f ${format} /dev/null"


ffmpeg -y -i $1 -preset ultrafast -pix_fmt yuv420p -c:v libx264 -crf ${crf} -c:a aac -b:a ${ab}k -f ${format} ${filename}-x264-crf${crf}k-aac-ab${ab}k.${format}
