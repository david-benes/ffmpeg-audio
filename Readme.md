# ffmpeg - audio
Compiled, minimal ffmpeg binaries for macOS and Linux with audio only support.
These binaries are meant to be used in lambda functions or anywhere, where size matters.

Size of each binary (ffmpeg, ffprobe) is `~2.5MB`.  

Supported formats are: aac, flac, mp3, mp4, mov, wav
Supported filters are: aresample, silencedetect

## Preparing
Install dependencies.

### macOS
`brew install fdk-aac`

`brew install lame`

## Building

`make build` - configure and build binaries on linux

`make macos-build` - configure and build binaries on macOS

## Installing
`make install` - copy binaries to the right directory in this project

## Cleaning
`make clean` - remove build directories
