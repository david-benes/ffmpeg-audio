# ffmpeg - audio
Compiled, minimal ffmpeg binaries for macOS and Linux with audio only support.
These binaries are meant to be used in lambda functions or anywhere, where size matters.

Size of each binary (ffmpeg, ffprobe) is `~2.5MB`.  

Supported formats are: aac, flac, mp3, mp4, mov, wav
Supported filters are: aresample, silencedetect

The build scripts are based on:
https://github.com/zimbatm/ffmpeg-static


## How to update ffmpeg and ffprobe binaries
`make build` - configure and build binaries

`make install` - copies binaries to `./bin` directory

`make clean` - cleanups the build directory
