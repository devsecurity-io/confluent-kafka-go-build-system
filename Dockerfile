FROM golang:1.15.6-alpine3.12

# add dev dependencies
RUN apk add --no-cache      \
      bash                  \
      build-base            \
      coreutils             \
      gcc                   \
      git                   \
      make                  \
      musl-dev              \
      openssl-dev           \
      openssl-libs-static   \
      rpm                   \
      lz4-dev               \
      lz4-static            \
      zlib-dev              \
      zlib-static           \
      zstd-dev              \
      zstd-static           \
      wget          &&      \
    # download libsasl to a temp location and build
    # enable/disable features as needed with configure
    cd $(mktemp -d) && \
    wget -nv -O cyrus-sasl-2.1.27.tar.gz https://github.com/cyrusimap/cyrus-sasl/releases/download/cyrus-sasl-2.1.27/cyrus-sasl-2.1.27.tar.gz && \
    tar -xz --strip-components=1 -f cyrus-sasl-2.1.27.tar.gz && \
    rm -f cyrus-sasl-2.1.27.tar.gz && \
    ./configure --prefix=/usr --disable-sample --disable-obsolete_cram_attr --disable-obsolete_digest_attr --enable-static --disable-shared \
        --disable-checkapop --disable-cram --disable-digest --enable-scram --disable-otp --disable-gssapi --with-dblib=none --with-pic && \
    make && \
    make install && \
    cd $(mktemp -d) && \
    wget -nv -O v1.5.3.tar.gz https://github.com/edenhill/librdkafka/archive/v1.5.3.tar.gz && \
    tar -xz --strip-components=1 -f v1.5.3.tar.gz && \
    rm -f v1.5.3.tar.gz && \
    ./configure --prefix=/usr   \
        --enable-zlib           \
        --enable-zstd           \
        --enable-ssl            \
        --disable-gssapi        \
        --enable-sasl           \
        --enable-lz4-ext &&     \
    make -j && \
    make install

CMD [ "/bin/bash" ]
