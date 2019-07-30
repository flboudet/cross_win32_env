FROM dockcross/windows-static-x64

ENV COMPILEDIR /compile
ENV INSTALLDIR /usr/src/mxe/usr/${CROSS_TRIPLE}
ENV WINDRES /usr/src/mxe/usr/bin/${CROSS_TRIPLE}-windres

RUN mkdir -p ${COMPILEDIR} && cd ${COMPILEDIR} && wget -O -  https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz  | tar xz
#RUN mkdir -p /boost_compile && cd /boost_compile && curl https://netix.dl.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.tar.gz | tar xz
#WORKDIR /compile/boost_1_49_0
WORKDIR ${COMPILEDIR}/boost_1_70_0
#RUN echo "using gcc : mingw32 : i686-w64-mingw32.static-g++ ;"  > user-config.jam
RUN echo "using gcc : mingw32 : ${CROSS_TRIPLE}-g++ ;"  > user-config.jam
RUN ./bootstrap.sh
#RUN ./b2 --user-config=user-config.jam toolset=gcc-mingw32 target-os=windows binary-format=pe threadapi=win32 threading=multi link=static --build-type=complete --prefix=${INSTALLDIR} --layout=tagged --without-python -sNO_BZIP2=1 -sNO_ZLIB=1 install
RUN ./b2 --user-config=user-config.jam toolset=gcc-mingw32 cxxstd=11 target-os=windows binary-format=pe threadapi=win32 threading=multi link=static --build-type=complete --prefix=${INSTALLDIR} --layout=tagged --without-python -sNO_BZIP2=1 -sNO_ZLIB=1 install


# OpenSSL installation
#RUN cd /compile && curl https://www.openssl.org/source/openssl-1.1.1c.tar.gz | tar xz
#WORKDIR /compile/openssl-1.1.1c
#RUN ./Configure no-shared --prefix=/usr/i686-w64-mingw32/ mingw
#RUN make install

# Thrift installation
# Make some symlinks as workaround for Linux filename case sensitivity vs Windows
RUN    ln -s /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/winsock2.h /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/Winsock2.h \
    && ln -s /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/shlwapi.h /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/Shlwapi.h   \
    && ln -s /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/windows.h /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/Windows.h   \
    && ln -s /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/accctrl.h /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/AccCtrl.h   \
    && ln -s /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/aclapi.h /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/Aclapi.h     \
    && ln -s /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/ws2tcpip.h /usr/src/mxe/usr/x86_64-w64-mingw32.static/include/WS2tcpip.h
RUN cd ${COMPILEDIR} && curl http://archive.apache.org/dist/thrift/0.12.0/thrift-0.12.0.tar.gz | tar xz
WORKDIR ${COMPILEDIR}/thrift-0.12.0
RUN mkdir build_${CROSS_TRIPLE} \
    && cd build_${CROSS_TRIPLE} \
    && cmake -DBUILD_COMPILER=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBoost_INCLUDE_DIRS=/usr/src/mxe/usr/x86_64-w64-mingw32.static/include/ .. \
    && make install

#RUN curl http://archive.apache.org/dist/thrift/0.9.3/thrift-0.9.3.tar.gz | tar xz
#./configure --prefix=/usr --with-lua=no --with-java=no --disable-tests --build i686-pc-linux-gnu --host i586-mingw32msvc --with-boost=/usr/i686-w64-mingw32/ --enable-static
#cmake -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBOOST_ROOT=/usr/i686-w64-mingw32/ -DBOOST_LIBRARYDIR=/usr/i686-w64-mingw32/lib/ ..
#cmake -DCMAKE_FIND_ROOT_PATH=/usr/src/mxe/usr/x86_64-w64-mingw32.static/ -DBUILD_TESTING=OFF -DBUILD_TUTORIALS=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF ..
#cmake -DCMAKE_FIND_ROOT_PATH=/usr/src/mxe/usr/x86_64-w64-mingw32.static/ -DBUILD_COMPILER=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBoost_INCLUDE_DIRS=/usr/src/mxe/usr/x86_64-w64-mingw32.static/include/ ..
#cmake -DCMAKE_FIND_ROOT_PATH=/usr/src/mxe/usr/x86_64-w64-mingw32.static/ -DBUILD_COMPILER=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBoost_INCLUDE_DIRS=/usr/src/mxe/usr/x86_64-w64-mingw32.static/include/ ..

#install THRIFT compiler
RUN apt install -y libboost-dev
RUN ./configure --prefix=/usr/src/mxe/usr --disable-libs --disable-tests --disable-tutorial CC=gcc CXX=g++
RUN make install

# compile thrift client
# cmake -DCMAKE_CXX_STANDARD=11 -DCMAKE_MODULE_PATH=/sources/cmake_modules/ ..
# -D_GLIBCXX_USE_CXX11_ABI=0
