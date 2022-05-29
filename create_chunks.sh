NAME=$1
FILE=$2
CMD=Bento4-SDK-1-6-0-637.x86_64-unknown-linux/bin

mkdir -p chunks/${NAME}
if [[ ! -d tmp ]]; then mkdir tmp; mkdir tmp/video; mkdir tmp/audio; fi

COUNT=$(ffprobe -loglevel error -select_streams a -show_entries stream=codec_type -of default=nw=1 $FILE | wc -l)
AS=$(($COUNT - 1))
echo $AS

for i in $(seq 0 ${AS}); do
	ffmpeg -hide_banner -loglevel error -i ${FILE} -map 0:a:${i} -c copy tmp/audio/audio-${i}.mp4
	${CMD}/mp4fragment --fragment-duration 2000 tmp/audio/audio-${i}.mp4 tmp/audio/f-audio-${i}.mp4
        echo $i
done

for i in {0..2}; do
        ffmpeg -hide_banner -loglevel error -i ${FILE} -map 0:v:${i} -an -sn -c copy tmp/video/video-${i}.mp4
        ${CMD}/mp4fragment tmp/video/video-${i}.mp4 tmp/video/f-video-${i}.mp4
        echo $i
done

${CMD}/mp4dash -f \
	--hls \
	--output-dir=chunks/${NAME} \
	--mpd-name=manifest.mpd tmp/video/f-video-*.mp4 tmp/audio/f-audio-*.mp4

rm -rf tmp/video/*
rm -rf tmp/audio/*

