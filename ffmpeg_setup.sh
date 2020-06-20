#!/bin/bash

sudo yum install -y autoconf automake gcc gcc-c++ libtool make nasm zlib-devel \
libass libass-devel cmake freetype freetype-devel gnutls gnutls-devel SDL SDL-devel \
SDL2 SDL2-devel openssl openssl-devel libva libva-devel libvdpau libvorbis libxcb libxcb-devel nasm \
libvmaf libvmaf-devel libva libva-devel libvarlink-devel libvarlink-util

if $(rpm -q yasm &>/dev/null) ; then
  :
else
  sudo yum install -y https://cbs.centos.org/kojifiles/packages/yasm/1.3.0/10.el8/x86_64/yasm-1.3.0-10.el8.x86_64.rpm
fi
if $(rpm -q yasm-devel &>/dev/null) ; then
  :
else
  sudo yum install -y https://cbs.centos.org/kojifiles/packages/yasm/1.3.0/10.el8/x86_64/yasm-devel-1.3.0-10.el8.x86_64.rpm
fi

mkdir -p ${HOME}/ffmpeg/sources ${HOME}/ffmpeg/build ${HOME}/bin

FFMPEG_BUILD="${HOME}/ffmpeg/build"
FFMPEG_SOURCES="${HOME}/ffmpeg/sources"
FFMPEG_VERSION="n4.3"
FDK_VERSION="v2.0.1"

#cd ~/ffmpeg/sources
#git clone https://github.com/yasm/yasm.git
#cd yasm
#autoreconf -fiv
#./configure --prefix="${HOME}/ffmpeg/build" --bindir="${HOME}/bin"
#make
#make install
#make distclean

#libx264
cd ${FFMPEG_SOURCES} && \
git clone https://code.videolan.org/videolan/x264.git && \
cd x264 && \
PATH="${HOME}/bin:${PATH}" PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig" ./configure \
--prefix="${FFMPEG_BUILD}" --bindir="${FFMPEG_BUILD}/bin" --enable-static --enable-pic && \
PATH="${HOME}/bin:${PATH}" make && \
make install
make distclean

#libx265
sudo yum install -y numad numactl numactl-devel mercurial && \
cd ${FFMPEG_SOURCES} && \
if cd x265 2> /dev/null; then
  hg pull && hg update && cd ..
else
  hg clone https://bitbucket.org/multicoreware/x265
fi && \
cd x265/build/linux && \
PATH="${HOME}/bin:${PATH}" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${FFMPEG_BUILD}" -DENABLE_SHARED:bool=off ../../source && \
PATH="${HOME}/bin:${PATH}" make && \
make install
make clean

#libvpx インストール
cd ${FFMPEG_SOURCES} && \
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git && \
cd libvpx && \
PATH="${HOME}/bin:${PATH}" ./configure --prefix="${FFMPEG_BUILD}" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm && \
PATH="${HOME}/bin:${PATH}" make && \
make install
make clean

#libaom インストール
cd ${FFMPEG_SOURCES} && \
git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="${HOME}/bin:${PATH}" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${FFMPEG_BUILD}" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
PATH="${HOME}/bin:${PATH}" make && \
make install
make clean

#fdk-aac
cd ${FFMPEG_SOURCES} && \
git clone https://git.code.sf.net/p/opencore-amr/fdk-aac && \
cd fdk-aac && \
git checkout -b ${FDK_VERSION} ${FDK_VERSION} && \
autoreconf -fiv && \
./configure --prefix="${FFMPEG_BUILD}" --disable-shared && \
make
make install
make distclean

#lame-mp3
cd ${FFMPEG_SOURCES} && \
curl -L -O https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz && \
tar xzvf lame-3.100.tar.gz && \
cd lame-3.100 && \
PATH="${HOME}/bin:${PATH}" ./configure --prefix="${FFMPEG_BUILD}" --bindir="${FFMPEG_BUILD}/bin" --disable-shared --enable-nasm && \
PATH="${HOME}/bin:${PATH}" make && \
make install
make clean

#ffmpeg
cd ${FFMPEG_SOURCES} && \
git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg && \
cd ffmpeg && \
git checkout -b ${FFMPEG_VERSION} ${FFMPEG_VERSION} && \
PATH="${HOME}/bin:${PATH}" PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig" ./configure \
  --prefix="${FFMPEG_BUILD}" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I${FFMPEG_BUILD}/include" --extra-ldflags="-L${FFMPEG_BUILD}/lib" --extra-libs="-lpthread -lm" \
  --bindir="${HOME}/bin" \
  --enable-openssl --enable-gpl --enable-nonfree --enable-version3 --enable-libass --enable-libfreetype \
  --enable-libfdk_aac --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx \
  --enable-static --enable-libvmaf && \
PATH="${HOME}/bin:${PATH}" make && \
make install
make distclean
hash -r
