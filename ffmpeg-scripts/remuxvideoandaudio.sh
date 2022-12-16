ffmpeg -i cooking_with_max.mkv -i cooking_with_max.wav -c:v copy -c:a aac -b:a 384k -map 0:v:0 -map 1:a:0 2020_04_cooking_with_max_final-h264-vaapi-qp15-aac-ab384k.mkv
