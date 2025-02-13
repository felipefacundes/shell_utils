rife_ncnn_vulkan() {
    cat <<'EOF'
# rife_ncnn_vulkan interpolation video

https://github.com/nihui/rife-ncnn-vulkan

mkdir input_frames
mkdir output_frames

# find the source fps and format with ffprobe, for example 24fps, AAC
ffprobe input.mp4

# extract audio
ffmpeg -i input.mp4 -vn -acodec copy audio.m4a

# decode all frames
ffmpeg -i input.mp4 input_frames/frame_%08d.png

# interpolate 2x frame count
./rife-ncnn-vulkan -i input_frames -o output_frames

# interpolate 3x frame count
rife-ncnn-vulkan -m rife-v4 -n frames*3 -i input_frames -o output_frames

# Anime
rife-ncnn-vulkan.exe -m models/rife-anime -0 0.png -1 1.png -o out.png

# encode interpolated frames in 48fps with audio
ffmpeg -framerate 48 -i output_frames/%08d.png -i audio.m4a -c:a copy -crf 20 -c:v libx264 -pix_fmt yuv420p output.mp4
EOF
}