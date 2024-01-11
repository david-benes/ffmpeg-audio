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
LIB_INSTALL_PREFIX := $(CURDIR)/build/libs
FFMPEG_EXTRA_CFLAGS := -I$(LIB_INSTALL_PREFIX)/include
FFMPEG_EXTRA_LDFLAGS := -L$(LIB_INSTALL_PREFIX)/lib

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
	curl -L "https://github.com/mstorsjo/fdk-aac/archive/refs/tags/v2.0.3.tar.gz" -o $(FETCH_DIR)/fdk-aac-2.0.3.tar.gz
	tar -xf $(FETCH_DIR)/fdk-aac-2.0.3.tar.gz -C $(FETCH_DIR)
	curl -L "https://deac-riga.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz" -o $(FETCH_DIR)/lame-3.100.tar.gz
	tar -xf $(FETCH_DIR)/lame-3.100.tar.gz -C $(FETCH_DIR)

# Lib targets
.PHONY: build-lame build-fdk-aac

build-lame-arm64:
	echo "*** Building mp3lame for macOS ***"
	cd $(FETCH_DIR) && cd `ls -d lame* | head -n 1` && \
	make distclean || true && \
	[ ! -f config.status ] && ./configure --prefix=$(LIB_INSTALL_PREFIX) --enable-nasm --disable-shared --build=arm-linux && \
	make && make install

# Build mp3lame s automatickou detekcí architektury
build-lame:
	echo "*** Building mp3lame ***"
	cd $(FETCH_DIR) && cd `ls -d lame* | head -n 1` && \
	make distclean || true && \
	[ ! -f config.status ] && ./configure --prefix=$(LIB_INSTALL_PREFIX) --enable-nasm --disable-shared && \
	make && make install


# Build fdk-aac
build-fdk-aac:
	echo "*** Building fdk-aac ***"
	cd $(FETCH_DIR) && cd `ls -d fdk-aac* | head -n 1` && \
	make distclean || true && \
	autoreconf -fiv && \
	[ ! -f config.status ] && ./configure --prefix=$(LIB_INSTALL_PREFIX) --disable-shared && \
	make -j $$jval && make install

configure-linux: build-lame build-fdk-aac
	echo "linux" > $(CONFIG_FILE)
	cd $(SRC_DIR) && ./configure \
	$(COMMON_CONFIGURE_OPTIONS) \
	--extra-cflags="$(FFMPEG_EXTRA_CFLAGS)" \
	--extra-ldflags="$(FFMPEG_EXTRA_LDFLAGS)"

configure-macos: build-lame-arm64 build-fdk-aac
	echo "macos" > $(CONFIG_FILE)
	cd $(SRC_DIR) && ./configure \
	--extra-cflags="$(MACOS_EXTRA_CFLAGS) $(FFMPEG_EXTRA_CFLAGS)" \
	--extra-ldflags="$(MACOS_EXTRA_LDFLAGS) $(FFMPEG_EXTRA_LDFLAGS)" \
	$(COMMON_CONFIGURE_OPTIONS)

# Configure and build for MacOS with Brew
macos-build: fetch build-lame build-fdk-aac configure-macos
	cd $(SRC_DIR) && make

# Configure and build for Linux
linux-build: configure-linux build-lame build-fdk-aac
	cd $(SRC_DIR) && make

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
