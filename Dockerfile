FROM dockcross/windows-static-x86

ENV COMPILEDIR /compile
ENV INSTALLDIR /usr/src/mxe/usr/${CROSS_TRIPLE}
ENV WINDRES /usr/src/mxe/usr/bin/${CROSS_TRIPLE}-windres

# Add BOOST and NSIS packages to MXE
WORKDIR /usr/src/mxe
RUN sed -i 's/LOCAL_PKG_LIST := .*/LOCAL_PKG_LIST := boost nsis/' settings.mk
RUN make boost nsis

# OpenSSL installation
#RUN cd /compile && curl https://www.openssl.org/source/openssl-1.1.1c.tar.gz | tar xz
#WORKDIR /compile/openssl-1.1.1c
#RUN ./Configure no-shared --prefix=/usr/i686-w64-mingw32/ mingw
#RUN make install

# Thrift installation
# Make some symlinks as workaround for Linux filename case sensitivity vs Windows
RUN    ln -s /usr/src/mxe/usr/${CROSS_TRIPLE}/include/winsock2.h /usr/src/mxe/usr/${CROSS_TRIPLE}/include/Winsock2.h \
    && ln -s /usr/src/mxe/usr/${CROSS_TRIPLE}/include/shlwapi.h /usr/src/mxe/usr/${CROSS_TRIPLE}/include/Shlwapi.h   \
    && ln -s /usr/src/mxe/usr/${CROSS_TRIPLE}/include/windows.h /usr/src/mxe/usr/${CROSS_TRIPLE}/include/Windows.h   \
    && ln -s /usr/src/mxe/usr/${CROSS_TRIPLE}/include/accctrl.h /usr/src/mxe/usr/${CROSS_TRIPLE}/include/AccCtrl.h   \
    && ln -s /usr/src/mxe/usr/${CROSS_TRIPLE}/include/aclapi.h /usr/src/mxe/usr/${CROSS_TRIPLE}/include/Aclapi.h     \
    && ln -s /usr/src/mxe/usr/${CROSS_TRIPLE}/include/ws2tcpip.h /usr/src/mxe/usr/${CROSS_TRIPLE}/include/WS2tcpip.h
RUN mkdir -p ${COMPILEDIR} && cd ${COMPILEDIR} && curl http://archive.apache.org/dist/thrift/0.12.0/thrift-0.12.0.tar.gz | tar xz
WORKDIR ${COMPILEDIR}/thrift-0.12.0
RUN mkdir build_${CROSS_TRIPLE} \
    && cd build_${CROSS_TRIPLE} \
    && cmake -DBUILD_COMPILER=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBoost_INCLUDE_DIRS=/usr/src/mxe/usr/${CROSS_TRIPLE}/include/ .. \
    && make install

#RUN curl http://archive.apache.org/dist/thrift/0.9.3/thrift-0.9.3.tar.gz | tar xz
#./configure --prefix=/usr --with-lua=no --with-java=no --disable-tests --build i686-pc-linux-gnu --host i586-mingw32msvc --with-boost=/usr/i686-w64-mingw32/ --enable-static
#cmake -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBOOST_ROOT=/usr/i686-w64-mingw32/ -DBOOST_LIBRARYDIR=/usr/i686-w64-mingw32/lib/ ..
#cmake -DCMAKE_FIND_ROOT_PATH=/usr/src/mxe/usr/x86_64-w64-mingw32.static/ -DBUILD_TESTING=OFF -DBUILD_TUTORIALS=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF ..
#cmake -DCMAKE_FIND_ROOT_PATH=/usr/src/mxe/usr/x86_64-w64-mingw32.static/ -DBUILD_COMPILER=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBoost_INCLUDE_DIRS=/usr/src/mxe/usr/x86_64-w64-mingw32.static/include/ ..
#cmake -DCMAKE_FIND_ROOT_PATH=/usr/src/mxe/usr/x86_64-w64-mingw32.static/ -DBUILD_COMPILER=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TUTORIALS=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=OFF -DWITH_SHARED_LIB=OFF -DWITH_STATIC_LIB=ON -DWITH_JAVA=OFF -DWITH_PYTHON=OFF -DWITH_PERL=OFF -DBoost_INCLUDE_DIRS=/usr/src/mxe/usr/x86_64-w64-mingw32.static/include/ ..

# Install THRIFT compiler
RUN apt install -y libboost-dev
RUN ./configure --prefix=/usr/src/mxe/usr --disable-libs --disable-tests --disable-tutorial CC=gcc CXX=g++
RUN make install

# Install a recent LLVM
# We want to llvm-dlltool which is able to generate MSVC-compatible import libs from def files
RUN apt install -y llvm-6.0
ENV LLVM_DLLTOOL /usr/bin/llvm-dlltool-6.0


# compile thrift client
# cmake -DCMAKE_CXX_STANDARD=11 -DCMAKE_MODULE_PATH=/sources/cmake_modules/ ..
# -D_GLIBCXX_USE_CXX11_ABI=0
