FROM centos

RUN yum -y update 
RUN yum-config-manager --add-repo http://www.nasm.us/nasm.repo 
RUN yum -y install git gcc-c++ glibc-headers openssl-devel readline libyaml-devel readline-devel zlib zlib-devel libffi-devel libxml2 libxslt libxml2-devel libxslt-devel sqlite-devel bzip2 diffutils 
RUN yum -y install autoconf automake cmake freetype-devel gcc libtool make mercurial nasm pkgconfig which 

# rbenvのインストール
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ./root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
 
# rubyのインストール
ENV CONFIGURE_OPTS --disable-install-doc
RUN rbenv install -v 2.4.0 
RUN rbenv rehash 
RUN rbenv global 2.4.0 
# FFMPEGインストール
RUN mkdir /usr/local/src/ffmpeg_sources 
RUN git clone --depth 1 git://github.com/yasm/yasm.git /usr/local/src/ffmpeg_sources/yasm
WORKDIR /usr/local/src/ffmpeg_sources/yasm 
RUN autoreconf -fiv 
RUN ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin"
RUN make
RUN make install 
ENV PATH $PATH:/usr/local/bin
WORKDIR /usr/local/src/ffmpeg_sources 
RUN git clone --depth 1 git://git.videolan.org/x264 
WORKDIR x264 
RUN PKG_CONFIG_PATH="/usr/local/ffmpeg_build/lib/pkgconfig" ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --enable-static 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac 
WORKDIR fdk-aac 
RUN autoreconf -fiv 
RUN ./configure --prefix="/usr/local/ffmpeg_build" --disable-shared 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz 
RUN tar xzvf lame-3.99.5.tar.gz 
WORKDIR lame-3.99.5 
RUN ./configure --prefix="/usr/local/ffmpeg_build" --bindir="/usr/local/bin" --disable-shared --enable-nasm 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN git clone http://git.opus-codec.org/opus.git 
WORKDIR opus 
RUN autoreconf -fiv 
RUN PKG_CONFIG_PATH="/usr/local/ffmpeg_build/lib/pkgconfig" ./configure --prefix="/usr/local/ffmpeg_build" --disable-shared 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz 
RUN tar xzvf libogg-1.3.2.tar.gz 
WORKDIR libogg-1.3.2 
RUN ./configure --prefix="/usr/local/ffmpeg_build" --disable-shared 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz 
RUN tar xzvf libvorbis-1.3.4.tar.gz 
WORKDIR libvorbis-1.3.4 
RUN ./configure --prefix="/usr/local/ffmpeg_build" --with-ogg="/usr/local/ffmpeg_build" --disable-shared 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git 
WORKDIR libvpx 
RUN ./configure --prefix="/usr/local/ffmpeg_build" --disable-examples 
RUN make 
RUN make install 
WORKDIR /usr/local/src/ffmpeg_sources 
RUN curl -O http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 
RUN tar xjvf ffmpeg-snapshot.tar.bz2 
WORKDIR ffmpeg 
RUN PKG_CONFIG_PATH="/usr/local/ffmpeg_build/lib/pkgconfig" ./configure --prefix="/usr/local/ffmpeg_build" --extra-cflags="-I/usr/local/ffmpeg_build/include" --extra-ldflags="-L/usr/local/ffmpeg_build/lib -ldl" --bindir="/usr/local/bin" --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 
RUN make 
RUN make install 
RUN hash -r 
# SOXインストール
RUN yum install -y libmad libmad-devel libid3tag libid3tag-devel lame-devel flac-devel libpng-devel libjpeg-devel 
RUN yum install -y gcc-c++ libmad libmad-devel libid3tag libid3tag-devel lame lame-devel flac-devel libvorbis-devel 
RUN yum install -y fribidi-devel libbluray-devel flite-devel gsm-devel openjpeg-devel 
RUN yum install -y opus-devel pulseaudio-libs-devel libssh-devel 
RUN yum install -y speex-devel libtheora-devel libvorbis-devel libvpx-devel wavpack-devel 
WORKDIR /usr/local/src 
RUN rm -fr sox 
RUN git clone git://git.code.sf.net/p/sox/code sox 
WORKDIR sox 
RUN ./configure 
RUN make all 
RUN make install 
RUN cp -p /usr/share/zoneinfo/Japan /etc/localtime 
RUN date 
RUN echo "LANG=ja_JP.UTF-8" > /etc/sysconfig/i18n 

RUN gem install bundler