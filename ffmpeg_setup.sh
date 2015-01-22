sudo yum install -y autoconf automake gcc gcc-c++ git libtool make nasm pkgconfig zlib-devel

mkdir -p ~/ffmpeg/sources

cd ~/ffmpeg/sources
git clone git://github.com/yasm/yasm.git
cd yasm
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg/build" --bindir="$HOME/ffmpeg/bin"
make
make install
make distclean

cd ~/ffmpeg/sources
git clone git://git.videolan.org/x264
cd x264
./configure --prefix="$HOME/ffmpeg/build" --bindir="$HOME/ffmpeg/bin" --enable-static
make
make install
make distclean

cd ~/ffmpeg/sources
git clone git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg/build" --disable-shared
make
make install
make distclean

cd ~/ffmpeg/sources
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg/build" --bindir="$HOME/ffmpeg/bin" --disable-shared --enable-nasm
make
make install
make distclean

cd ~/ffmpeg/sources
git clone git://source.ffmpeg.org/ffmpeg
git checkout -b tag2.5.3 n2.5.3
cd ffmpeg
PKG_CONFIG_PATH="$HOME/ffmpeg/build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg/build" --extra-cflags="-I$HOME/ffmpeg/build/include" --extra-ldflags="-L$HOME/ffmpeg/build/lib" --bindir="$HOME/ffmpeg/bin" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libmp3lame --enable-libx264
make
make install
make distclean
hash -r
