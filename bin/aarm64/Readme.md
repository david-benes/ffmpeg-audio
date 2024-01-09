# Make ffmpeg for mac-silicon
1. Fetch sources:

`curl -L "https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.xz"`

2. Install dependencies:

`brew install fdk-aac`

3. Configure
```bash
./configure \
  --disable-everything \
  --enable-demuxer=mov,mp3,wav \
  --enable-decoder=aac,mp3,pcm_s16le \
  --enable-parser=aac,mpegaudio \
  --enable-protocol=file \
  --enable-bsf=aac_adtstoasc \
  --enable-libfdk-aac \
  --enable-nonfree \
  --extra-cflags="-I/opt/homebrew/include" \
  --extra-ldflags="-L/opt/homebrew/lib"
```

4. Make

`make`
