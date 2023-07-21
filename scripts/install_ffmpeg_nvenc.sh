#!/bin/bash

mkdir vendor
cd vendor

# Clone and install ffnvcodec
git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers && make install && cd –

# Install necessary packages
apt-get update && apt-get install -y build-essential yasm cmake gcc-9 ninja-build autoconf automake git-core libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson pkg-config texinfo zlib1g-dev libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev nasm libx264-dev libx265-dev libvpx-dev libfdk-aac-dev libopus-dev libdav1d-dev


# Clone and install ffmpeg with nvenc
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg-custom/
cd ffmpeg-custom
# configure with cuda
./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --enable-gpl --enable-gnutls --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis--enable-libx264 --enable-libx265 --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 --extra-libs="-lpthread -lm" --disable-static --enable-shared
# compile
make -j$(nproc)
# install
make install

# Clean up
# cd .. && rm -rf nv-codec-headers && rm -rf ffmpeg-custom && rm -rf ffmpeg_sources