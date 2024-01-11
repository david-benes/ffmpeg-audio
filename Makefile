# Variable settings
FFMPEG_VERSION := ffmpeg-6.1.1
FFMPEG_ARCHIVE := $(FFMPEG_VERSION).tar.xz
FFMPEG_DIR := $(FFMPEG_VERSION)
BUILD_DIR := ./build
FETCH_DIR := $(BUILD_DIR)/fetch
SRC_DIR := $(FETCH_DIR)/$(FFMPEG_DIR)
CONFIG_FILE := $(BUILD_DIR)/last_config

# Optional extra flags for MacOS with Brew
MACOS_EXTRA_CFLAGS := -I/opt/homebrew/include
MACOS_EXTRA_LDFLAGS := -L/opt/homebrew/lib

# Target directories for installation
PREFIX_LINUX := $(CURDIR)/bin/linux/x64
PREFIX_MAC := $(CURDIR)/bin/darwin/arm64

# Common configuration commands
COMMON_CONFIGURE_OPTIONS := \
    --disable-everything \
    --enable-demuxer=aac,flac,mp3,mp4,mov,wav \
    --enable-muxer=aac,flac,mp3,mp4,mov,wav,segment \
    --enable-decoder=aac,alac,flac,mp3,pcm* \
    --enable-parser=aac,mpegaudio,flac \
    --enable-encoder=libmp3lame \
    --enable-libmp3lame \
    --enable-protocol=file \
    --enable-bsf=aac_adtstoasc \
    --enable-libfdk-aac \
    --enable-nonfree \
    --enable-filter=aresample,silencedetect \
    --enable-static

# Default target
all: linux-build

# Prepare directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(FETCH_DIR): $(BUILD_DIR)
	mkdir -p $(FETCH_DIR)

# Fetch target for downloading ffmpeg source code
fetch: $(FETCH_DIR)
	curl -L "https://ffmpeg.org/releases/$(FFMPEG_ARCHIVE)" -o $(FETCH_DIR)/$(FFMPEG_ARCHIVE)
	tar -xf $(FETCH_DIR)/$(FFMPEG_ARCHIVE) -C $(FETCH_DIR)

# Configure and build for Linux
linux-build: configure-linux
	cd $(SRC_DIR) && make

configure-linux: fetch
	echo "linux" > $(CONFIG_FILE)
	cd $(SRC_DIR) && ./configure \
	$(COMMON_CONFIGURE_OPTIONS)

# Configure and build for MacOS with Brew
macos-build: configure-macos
	cd $(SRC_DIR) && make

configure-macos: fetch
	echo "macos" > $(CONFIG_FILE)
	cd $(SRC_DIR) && ./configure \
	--extra-cflags="$(MACOS_EXTRA_CFLAGS)" \
	--extra-ldflags="$(MACOS_EXTRA_LDFLAGS)" \
	$(COMMON_CONFIGURE_OPTIONS)

# Install target
install:
	@if [ -f $(CONFIG_FILE) ]; then \
		if [ `cat $(CONFIG_FILE)` = "linux" ]; then \
			cp $(FETCH_DIR)/$(FFMPEG_DIR)/ffmpeg $(PREFIX_LINUX)/ffmpeg; \
			cp $(FETCH_DIR)/$(FFMPEG_DIR)/ffprobe $(PREFIX_LINUX)/ffprobe; \
		elif [ `cat $(CONFIG_FILE)` = "macos" ]; then \
			cp $(FETCH_DIR)/$(FFMPEG_DIR)/ffmpeg $(PREFIX_MAC)/ffmpeg; \
			cp $(FETCH_DIR)/$(FFMPEG_DIR)/ffprobe $(PREFIX_MAC)/ffprobe; \
		else \
			echo "Unknown configuration. Please run 'make linux-build' or 'make macos-build' first."; \
		fi \
	else \
		echo "No configuration found. Please run 'make linux-build' or 'make macos-build' first."; \
	fi

# Clean target for removing downloaded and built files
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all fetch configure-linux configure-macos linux-build macos-build install clean
