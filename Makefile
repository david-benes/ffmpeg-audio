# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    TARGET_DIR=bin/linux/x64
endif
ifeq ($(UNAME_S),Darwin)
    TARGET_DIR=bin/darwin/arm64
endif

# Default target
.PHONY: all
all: build

# Build
.PHONY: build
build:
	cd ffmpeg-static && ./build-targets.sh

# Clean
.PHONY: clean
clean:
	rm -rf ffmpeg-static/bin ffmpeg-static/build ffmpeg-static/dl ffmpeg-static/target

# Install
.PHONY: install
install:
	cp ffmpeg-static/bin/ffmpeg $(TARGET_DIR)/ffmpeg
	cp ffmpeg-static/bin/ffprobe $(TARGET_DIR)/ffprobe

