#!/bin/bash

mkdir vendor
cd vendor

# Clone and install ffnvcodec
git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers && make install && cd –

# Install necessary packages
apt-get update && apt-get install -y build-essential yasm cmake gcc-9 ninja-build autoconf automake git-core libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson pkg-config texinfo zlib1g-dev libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev nasm libx264-dev libx265-dev libvpx-dev libfdk-aac-dev libopus-dev libdav1d-dev

# Compile further libraries
mkdir ffmpeg_sources

# Install libaom
cd ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make && \
make install

# Install libsvtav1
cd .. && \
git -C SVT-AV1 pull 2> /dev/null || git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git && \
mkdir -p SVT-AV1/build && \
cd SVT-AV1/build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF .. && \
PATH="$HOME/bin:$PATH" make && \
make install

# Install libvmaf
cd .. && \
wget https://github.com/Netflix/vmaf/archive/v2.1.1.tar.gz && \
tar xvf v2.1.1.tar.gz && \
mkdir -p vmaf-2.1.1/libvmaf/build &&\
cd vmaf-2.1.1/libvmaf/build && \
meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static .. --prefix "$HOME/ffmpeg_build" --bindir="$HOME/bin" --libdir="$HOME/ffmpeg_build/lib" && \
ninja && \
ninja install
cd ../..

# Clone and install ffmpeg with nvenc
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg-custom/
cd ffmpeg-custom
# configure with cuda
./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --enable-gpl --enable-gnutls --enable-libaom --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libsvtav1 --enable-libdav1d --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 --extra-libs="-lpthread -lm" --disable-static --enable-shared
# compile
make -j$(nproc)
# install
make install

# Clean up
# cd .. && rm -rf nv-codec-headers && rm -rf ffmpeg-custom && rm -rf ffmpeg_sources
