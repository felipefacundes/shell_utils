# ffmpeg
MY_X265_TEST_FLAGS='-c:a copy -ar 16000 -c:v libx265 -preset fast -tune zerolatency -maxrate 2M -bufsize 1M -pix_fmt yuv420p -framerate15 -g 52 -max_muxing_queue_size 400 -f mp4 -movflags frag_keyframe+empty_moov -crf 23 -b:v 2M'
MY_X264_TEST_FLAGS='-c:a copy -ar 16000 -c:v libx264 -preset fast -tune zerolatency -maxrate 2M -bufsize 1M -pix_fmt yuv420p -framerate15 -g 52 -max_muxing_queue_size 400 -f mp4 -bsf:v h264_mp4toannexb -movflags frag_keyframe+empty_moov -crf 23 -b:v 2M'
